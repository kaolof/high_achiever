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
}
