import 'package:flutter_test/flutter_test.dart';
import 'package:high_achiever/features/fichas/domain/token_backup.dart';
import 'package:high_achiever/features/fichas/domain/token_date.dart';
import 'package:high_achiever/features/fichas/domain/token_models.dart';
import 'package:high_achiever/features/fichas/domain/token_repository.dart';
import 'package:high_achiever/features/fichas/domain/token_system_notifier.dart';

/// Deterministic in-memory repo: only holds what the test seeds, so weekly
/// numbers don't depend on the real calendar date.
class _TestRepo implements TokenRepository {
  TokenTemplate _template;
  final Map<String, Set<String>> _logs;
  _TestRepo(this._template, this._logs);

  @override
  Future<TokenTemplate> loadTemplate() async => _template;

  @override
  Future<void> saveTemplate(TokenTemplate t) async => _template = t;

  @override
  Future<List<DayLog>> logsForWeek(DateTime weekStart) async {
    final end = weekStart.add(const Duration(days: 7));
    return [
      for (final e in _logs.entries)
        if (!parseDayKey(e.key).isBefore(weekStart) &&
            parseDayKey(e.key).isBefore(end))
          DayLog(date: parseDayKey(e.key), completedTaskIds: {...e.value}),
    ];
  }

  @override
  Future<void> setTaskCompleted(
    DateTime day,
    String taskId,
    bool completed,
  ) async {
    final s = _logs.putIfAbsent(dayKey(day), () => <String>{});
    if (completed) {
      s.add(taskId);
    } else {
      s.remove(taskId);
    }
  }

  final Set<String> claims = {};

  @override
  Future<bool> isRewardClaimed(DateTime weekStart) async =>
      claims.contains(dayKey(weekStart));

  @override
  Future<void> setRewardClaimed(DateTime weekStart) async =>
      claims.add(dayKey(weekStart));

  @override
  Future<TokenBackup> exportAll() async => TokenBackup(
    template: _template,
    completions: [
      for (final e in _logs.entries)
        for (final id in e.value) CompletionEntry(day: e.key, taskId: id),
    ],
    claimedWeeks: claims.toList(),
  );

  @override
  Future<void> importAll(TokenBackup backup) async {
    _template = backup.template;
    _logs
      ..clear()
      ..addAll({
        for (final c in backup.completions)
          c.day: {
            ...?_logs[c.day],
            c.taskId,
          },
      });
    claims
      ..clear()
      ..addAll(backup.claimedWeeks);
  }
}

/// Every read fails — models storage that's unavailable at startup.
class _ThrowingRepo implements TokenRepository {
  @override
  Future<TokenTemplate> loadTemplate() async => throw Exception('storage down');
  @override
  Future<List<DayLog>> logsForWeek(DateTime weekStart) async => [];
  @override
  Future<void> saveTemplate(TokenTemplate t) async {}
  @override
  Future<void> setTaskCompleted(
    DateTime day,
    String taskId,
    bool completed,
  ) async {}
  @override
  Future<bool> isRewardClaimed(DateTime weekStart) async => false;
  @override
  Future<void> setRewardClaimed(DateTime weekStart) async {}
  @override
  Future<TokenBackup> exportAll() async => throw Exception('storage down');
  @override
  Future<void> importAll(TokenBackup backup) async =>
      throw Exception('storage down');
}

/// An in-week day that isn't today, so a test can seed prior-day completions
/// without depending on which weekday the suite runs on.
DateTime _otherWeekDay(DateTime today, int weekStartDay) {
  final ws = weekStartFor(today, weekStartDay);
  for (var i = 0; i < 7; i++) {
    final d = DateTime(ws.year, ws.month, ws.day + i);
    if (d != today) return d;
  }
  return today; // unreachable: a 7-day week always has another day
}

void main() {
  const template = TokenTemplate(
    tasks: [
      Task(id: 't1', name: 'A'),
      Task(id: 't2', name: 'B'),
      Task(id: 't3', name: 'C'),
      Task(id: 't4', name: 'D'),
      Task(id: 't5', name: 'E'),
    ],
    daysPerWeek: 5,
    weekStartDay: DateTime.monday,
    weeklyGoal: 3,
    reward: 'Test reward',
  );

  test(
    'reward stays locked until the goal is met AND every task is done ≥1×',
    () async {
      final n = TokenSystemNotifier(_TestRepo(template, {}));
      await pumpEventQueue();

      expect(n.isLoading, isFalse);
      expect(n.weeklyMax, 25); // 5 tasks × 5 days
      expect(n.weeklyEarned, 0);
      expect(n.rewardUnlocked, isFalse);

      expect(await n.toggleTask('t1'), isFalse); // 1 token, below goal
      expect(await n.toggleTask('t2'), isFalse); // 2 tokens
      expect(n.weeklyEarned, 2);
      expect(n.toGo, 1);

      // The aggregate goal (3) is met here, but t4/t5 are still at 0, so the
      // per-task minimum gate keeps the reward locked — no unlock crossing.
      expect(await n.toggleTask('t3'), isFalse);
      expect(n.goalReached, isTrue);
      expect(n.rewardUnlocked, isFalse);
      expect(n.tasksBelowMin.map((t) => t.id), ['t4', 't5']);

      expect(await n.toggleTask('t4'), isFalse); // still missing t5

      // Completing the last remaining task crosses into unlocked exactly once.
      expect(await n.toggleTask('t5'), isTrue);
      expect(n.rewardUnlocked, isTrue);
      expect(n.tasksBelowMin, isEmpty);

      // A no-op re-toggle path: undoing one drops back to locked.
      expect(await n.toggleTask('t5'), isFalse);
      expect(n.weeklyEarned, 4);
      expect(n.rewardUnlocked, isFalse);
    },
  );

  test('isDoneToday reflects completed tasks', () async {
    final n = TokenSystemNotifier(_TestRepo(template, {}));
    await pumpEventQueue();

    expect(n.isDoneToday('t1'), isFalse);
    await n.toggleTask('t1');
    expect(n.isDoneToday('t1'), isTrue);
    expect(n.todayDoneCount, 1);
  });

  test('claimReward persists and is idempotent', () async {
    final repo = _TestRepo(template, {});
    final n = TokenSystemNotifier(repo);
    await pumpEventQueue();

    expect(n.rewardClaimed, isFalse);
    await n.claimReward();
    expect(n.rewardClaimed, isTrue);
    expect(repo.claims, isNotEmpty);

    // Second claim is a no-op, no crash.
    await n.claimReward();
    expect(n.rewardClaimed, isTrue);
  });

  test('updateTemplate updates max, goal and reward', () async {
    final n = TokenSystemNotifier(_TestRepo(template, {}));
    await pumpEventQueue();

    await n.updateTemplate(
      template.copyWith(daysPerWeek: 6, weeklyGoal: 20, reward: 'New reward'),
    );

    expect(n.weeklyMax, 30); // 5 × 6
    expect(n.weeklyGoal, 20);
    expect(n.reward, 'New reward');
  });

  test('completions for deleted tasks do not count toward the week', () async {
    // 'ghost' is a task the user completed and then removed from the template.
    // Its completion row survives in storage but must be ignored everywhere.
    final today = dayOnly(DateTime.now());
    final n = TokenSystemNotifier(
      _TestRepo(template, {
        dayKey(today): {'t1', 'ghost'},
      }),
    );
    await pumpEventQueue();

    expect(n.weeklyEarned, 1); // only the active 't1' counts, not 'ghost'
    expect(n.todayDoneCount, 1);
  });

  test(
    'a storage failure ends loading instead of hanging the spinner',
    () async {
      final n = TokenSystemNotifier(_ThrowingRepo());
      await pumpEventQueue();

      expect(n.isLoading, isFalse); // no infinite spinner
      expect(n.template.tasks, isEmpty);
      expect(n.weeklyEarned, 0);
    },
  );

  test('a customized task must reach its weekly minimum to unlock', () async {
    final today = dayOnly(DateTime.now());
    final other = _otherWeekDay(today, DateTime.monday);
    const tmpl = TokenTemplate(
      tasks: [
        Task(id: 'a', name: 'A', minPerWeek: 2, maxPerWeek: 3),
        Task(id: 'b', name: 'B'),
        Task(id: 'c', name: 'C'),
      ],
      daysPerWeek: 3,
      weekStartDay: DateTime.monday,
      weeklyGoal: 3,
      reward: 'x',
    );
    final n = TokenSystemNotifier(
      _TestRepo(tmpl, {
        dayKey(other): {'a', 'b', 'c'},
      }),
    );
    await pumpEventQueue();

    // Goal reached and every task done once — but 'a' needs 2×, so still locked.
    expect(n.goalReached, isTrue);
    expect(n.rewardUnlocked, isFalse);
    expect(n.tasksBelowMin.map((t) => t.id), ['a']);

    // Completing 'a' a second day (today) meets its minimum → unlock.
    expect(await n.toggleTask('a'), isTrue);
    expect(n.weekCount('a'), 2);
    expect(n.rewardUnlocked, isTrue);
  });

  test('the weekly max hard-blocks further completions', () async {
    final today = dayOnly(DateTime.now());
    final ws = weekStartFor(today, DateTime.monday);
    final otherDays = [
      for (var i = 0; i < 7; i++) DateTime(ws.year, ws.month, ws.day + i),
    ].where((d) => d != today).take(2).toList();

    const tmpl = TokenTemplate(
      tasks: [Task(id: 'a', name: 'A', maxPerWeek: 2), Task(id: 'b', name: 'B')],
      daysPerWeek: 5,
      weekStartDay: DateTime.monday,
      weeklyGoal: 2,
      reward: 'x',
    );
    final n = TokenSystemNotifier(
      _TestRepo(tmpl, {for (final d in otherDays) dayKey(d): {'a'}}),
    );
    await pumpEventQueue();

    expect(n.weekCount('a'), 2);
    expect(n.maxFor('a'), 2);
    expect(n.isBlockedToday('a'), isTrue);

    // Completing 'a' again today is a no-op: the weekly cap is reached.
    expect(await n.toggleTask('a'), isFalse);
    expect(n.isDoneToday('a'), isFalse);
    expect(n.weekCount('a'), 2);

    // 'b' (uncapped default) is never blocked.
    expect(n.isBlockedToday('b'), isFalse);
  });

  test('weeklyMax and weeklyEarned respect per-task caps', () async {
    final today = dayOnly(DateTime.now());
    final ws = weekStartFor(today, DateTime.monday);
    final days = [
      for (var i = 0; i < 7; i++) DateTime(ws.year, ws.month, ws.day + i),
    ];
    const tmpl = TokenTemplate(
      tasks: [Task(id: 'a', name: 'A', maxPerWeek: 2), Task(id: 'b', name: 'B')],
      daysPerWeek: 5,
      weekStartDay: DateTime.monday,
      weeklyGoal: 2,
      reward: 'x',
    );
    // 'a' completed on 3 distinct days but its weekly cap is 2.
    final n = TokenSystemNotifier(
      _TestRepo(tmpl, {
        dayKey(days[0]): {'a'},
        dayKey(days[1]): {'a'},
        dayKey(days[2]): {'a'},
      }),
    );
    await pumpEventQueue();

    expect(n.weeklyMax, 7); // a caps at 2, b defaults to 5
    expect(n.weekCount('a'), 3);
    expect(n.weeklyEarned, 2); // a's 3 completions count only up to its cap
  });
}
