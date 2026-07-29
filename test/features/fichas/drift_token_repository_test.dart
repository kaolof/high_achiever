import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_achiever/features/fichas/data/drift_token_repository.dart';
import 'package:high_achiever/features/fichas/data/token_database.dart';
import 'package:high_achiever/features/fichas/domain/token_date.dart';
import 'package:high_achiever/features/fichas/domain/token_models.dart';

void main() {
  late TokenDatabase db;
  late DriftTokenRepository repo;

  setUp(() {
    db = TokenDatabase.forTesting(NativeDatabase.memory());
    repo = DriftTokenRepository(db);
  });

  tearDown(() async => db.close());

  test('seedIfEmpty inserts a default template that loads back', () async {
    await repo.seedIfEmpty();
    final t = await repo.loadTemplate();
    expect(t.tasks.length, 5);
    expect(t.weeklyGoal, 18);
    expect(t.maxTokens, 25);
    expect(t.reward, 'Dinner out 🍽️');
  });

  test('saveTemplate round-trips through SQLite', () async {
    await repo.saveTemplate(
      const TokenTemplate(
        tasks: [
          Task(id: 'a', name: 'Alpha'),
          Task(id: 'b', name: 'Beta'),
        ],
        daysPerWeek: 6,
        weekStartDay: DateTime.sunday,
        weeklyGoal: 9,
        reward: 'Movie night',
      ),
    );
    final t = await repo.loadTemplate();
    expect(t.tasks.map((e) => e.name).toList(), ['Alpha', 'Beta']);
    expect(t.daysPerWeek, 6);
    expect(t.weekStartDay, DateTime.sunday);
    expect(t.weeklyGoal, 9);
    expect(t.reward, 'Movie night');
  });

  test('advanced per-task limits round-trip through SQLite', () async {
    await repo.saveTemplate(
      const TokenTemplate(
        tasks: [
          Task(id: 'a', name: 'A', minPerWeek: 2, maxPerWeek: 3),
          Task(id: 'b', name: 'B'), // defaults (null/null)
        ],
        daysPerWeek: 5,
        weekStartDay: DateTime.monday,
        weeklyGoal: 4,
        reward: 'x',
      ),
    );
    final t = await repo.loadTemplate();
    expect(t.tasks[0].minPerWeek, 2);
    expect(t.tasks[0].maxPerWeek, 3);
    expect(t.tasks[1].minPerWeek, isNull);
    expect(t.tasks[1].maxPerWeek, isNull);
    expect(t.maxTokens, 3 + 5); // a caps at 3, b defaults to 5 days
  });

  test(
    'completions count only within the week window, no double count',
    () async {
      // 2026-07-06 is the Monday of the week containing today (2026-07-09).
      final weekStart = weekStartFor(DateTime(2026, 7, 6), DateTime.monday);

      await repo.setTaskCompleted(DateTime(2026, 7, 6), 't1', true);
      await repo.setTaskCompleted(DateTime(2026, 7, 6), 't2', true);
      await repo.setTaskCompleted(DateTime(2026, 7, 7), 't1', true);
      await repo.setTaskCompleted(
        DateTime(2026, 7, 13),
        't1',
        true,
      ); // next week

      int total(List<DayLog> l) => l.fold(0, (s, d) => s + d.tokens);

      expect(total(await repo.logsForWeek(weekStart)), 3);

      // Re-completing the same (day, task) must not double count.
      await repo.setTaskCompleted(DateTime(2026, 7, 7), 't1', true);
      expect(total(await repo.logsForWeek(weekStart)), 3);

      // Toggling off removes it.
      await repo.setTaskCompleted(DateTime(2026, 7, 6), 't1', false);
      expect(total(await repo.logsForWeek(weekStart)), 2);
    },
  );

  test('reward claim persists per week and is idempotent', () async {
    final wk = weekStartFor(DateTime(2026, 7, 6), DateTime.monday);
    final otherWk = weekStartFor(DateTime(2026, 7, 13), DateTime.monday);

    expect(await repo.isRewardClaimed(wk), isFalse);
    await repo.setRewardClaimed(wk);
    expect(await repo.isRewardClaimed(wk), isTrue);

    // A different week is independent.
    expect(await repo.isRewardClaimed(otherWk), isFalse);

    // Claiming twice doesn't throw (insertOrIgnore).
    await repo.setRewardClaimed(wk);
    expect(await repo.isRewardClaimed(wk), isTrue);
  });

  test('reward tiers round-trip through SQLite in order', () async {
    await repo.saveTemplate(
      const TokenTemplate(
        tasks: [Task(id: 'a', name: 'A'), Task(id: 'b', name: 'B')],
        daysPerWeek: 5,
        weekStartDay: DateTime.monday,
        weeklyGoal: 3,
        reward: '',
        rewardTiers: [
          RewardTier(threshold: 3, reward: 'Bronze'),
          RewardTier(threshold: 6, reward: 'Silver'),
          RewardTier(threshold: 9, reward: 'Gold'),
        ],
      ),
    );
    final t = await repo.loadTemplate();
    expect(t.isTiered, isTrue);
    expect(t.rewardTiers.map((e) => e.threshold).toList(), [3, 6, 9]);
    expect(t.rewardTiers.map((e) => e.reward).toList(), [
      'Bronze',
      'Silver',
      'Gold',
    ]);

    // Re-saving a basic template clears the ladder wholesale.
    await repo.saveTemplate(
      const TokenTemplate(
        tasks: [Task(id: 'a', name: 'A')],
        daysPerWeek: 5,
        weekStartDay: DateTime.monday,
        weeklyGoal: 1,
        reward: 'Solo',
      ),
    );
    expect((await repo.loadTemplate()).rewardTiers, isEmpty);
  });

  test('settlement watermark and week results persist and export', () async {
    final wk = weekStartFor(DateTime(2026, 7, 6), DateTime.monday);
    expect(await repo.lastSettledWeek(), isNull);

    await repo.setLastSettledWeek(wk);
    expect(await repo.lastSettledWeek(), wk);

    await repo.saveWeekResult(wk, 1, 'Silver');
    // saveWeekResult is an upsert: re-settling the same week overwrites.
    await repo.saveWeekResult(wk, 2, 'Gold');

    await repo.seedIfEmpty(); // give exportAll a template
    final backup = await repo.exportAll();
    expect(backup.lastSettledWeek, dayKey(wk));
    expect(backup.weekResults.length, 1);
    expect(backup.weekResults.single.tierIndex, 2);
    expect(backup.weekResults.single.reward, 'Gold');
  });

  test('tier repeatable flag round-trips and grantedRewardTexts works', () async {
    await repo.saveTemplate(
      const TokenTemplate(
        tasks: [Task(id: 'a', name: 'A')],
        daysPerWeek: 5,
        weekStartDay: DateTime.monday,
        weeklyGoal: 2,
        reward: '',
        rewardTiers: [
          RewardTier(threshold: 2, reward: 'Ice cream'), // repeatable (default)
          RewardTier(threshold: 4, reward: 'Big gift', repeatable: false),
        ],
      ),
    );
    final t = await repo.loadTemplate();
    expect(t.rewardTiers[0].repeatable, isTrue);
    expect(t.rewardTiers[1].repeatable, isFalse);

    expect(await repo.grantedRewardTexts(), isEmpty);
    await repo.saveWeekResult(
      weekStartFor(DateTime(2026, 7, 6), DateTime.monday),
      1,
      'Big gift',
    );
    expect(await repo.grantedRewardTexts(), {'Big gift'});
  });
}
