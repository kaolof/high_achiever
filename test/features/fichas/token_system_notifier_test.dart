import 'package:flutter_test/flutter_test.dart';
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
      DateTime day, String taskId, bool completed) async {
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

  test('toggling tasks tracks tokens and crosses the unlock threshold',
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

    // Reaching the goal returns true exactly once (the unlock transition).
    expect(await n.toggleTask('t3'), isTrue);
    expect(n.rewardUnlocked, isTrue);
    expect(n.toGo, 0);

    // A further completion does NOT re-fire the unlock.
    expect(await n.toggleTask('t4'), isFalse);
    expect(n.weeklyEarned, 4);

    // Undoing drops back below the goal.
    expect(await n.toggleTask('t4'), isFalse);
    expect(await n.toggleTask('t3'), isFalse);
    expect(n.weeklyEarned, 2);
    expect(n.rewardUnlocked, isFalse);
  });

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
    final n = TokenSystemNotifier(_TestRepo(template, {
      dayKey(today): {'t1', 'ghost'},
    }));
    await pumpEventQueue();

    expect(n.weeklyEarned, 1); // only the active 't1' counts, not 'ghost'
    expect(n.todayDoneCount, 1);
  });
}
