import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_achiever/features/fichas/data/drift_token_repository.dart';
import 'package:high_achiever/features/fichas/data/token_database.dart';
import 'package:high_achiever/features/fichas/domain/token_backup.dart';
import 'package:high_achiever/features/fichas/domain/token_date.dart';
import 'package:high_achiever/features/fichas/domain/token_models.dart';

void main() {
  // The reinstall round-trip test intentionally holds two in-memory databases
  // open at once (old + fresh); they use separate executors, so silence Drift's
  // multiple-database warning.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('TokenBackup JSON codec', () {
    const backup = TokenBackup(
      template: TokenTemplate(
        tasks: [Task(id: 'a', name: 'Alpha'), Task(id: 'b', name: 'Beta')],
        daysPerWeek: 6,
        weekStartDay: DateTime.sunday,
        weeklyGoal: 9,
        reward: 'Movie night 🎬',
      ),
      completions: [
        CompletionEntry(day: '2026-07-06', taskId: 'a'),
        CompletionEntry(day: '2026-07-07', taskId: 'b'),
      ],
      claimedWeeks: ['2026-07-06'],
    );

    test('encode → decode preserves every field', () {
      final json = encodeTokenBackup(backup, exportedAt: DateTime(2026, 7, 11));
      final out = decodeTokenBackup(json);

      expect(out.template.tasks.map((t) => t.id).toList(), ['a', 'b']);
      expect(out.template.tasks.map((t) => t.name).toList(), ['Alpha', 'Beta']);
      expect(out.template.daysPerWeek, 6);
      expect(out.template.weekStartDay, DateTime.sunday);
      expect(out.template.weeklyGoal, 9);
      expect(out.template.reward, 'Movie night 🎬');
      expect(
        out.completions.map((c) => '${c.day}/${c.taskId}').toList(),
        ['2026-07-06/a', '2026-07-07/b'],
      );
      expect(out.claimedWeeks, ['2026-07-06']);
    });

    test('rejects non-JSON', () {
      expect(
        () => decodeTokenBackup('not json'),
        throwsA(isA<TokenBackupFormatException>()),
      );
    });

    test('rejects a foreign JSON file', () {
      expect(
        () => decodeTokenBackup('{"format":"something_else"}'),
        throwsA(isA<TokenBackupFormatException>()),
      );
    });

    test('rejects a backup from a newer version', () {
      final json =
          '{"format":"$kTokenBackupFormat","version":${kTokenBackupVersion + 1}}';
      expect(
        () => decodeTokenBackup(json),
        throwsA(isA<TokenBackupFormatException>()),
      );
    });

    test('rejects a backup with a missing or non-positive version', () {
      // Missing version.
      expect(
        () => decodeTokenBackup(
          '{"format":"$kTokenBackupFormat","template":{"tasks":[{"id":"a","name":"A"}]}}',
        ),
        throwsA(isA<TokenBackupFormatException>()),
      );
      // Negative version must not slip through as if it were v1.
      expect(
        () => decodeTokenBackup(
          '{"format":"$kTokenBackupFormat","version":-5,"template":{"tasks":[{"id":"a","name":"A"}]}}',
        ),
        throwsA(isA<TokenBackupFormatException>()),
      );
    });

    test('accepts numeric fields written as JSON doubles', () {
      // A hand-edited or third-party file may serialise ints as 6.0 etc.
      const json =
          '{"format":"$kTokenBackupFormat","version":1.0,'
          '"template":{"daysPerWeek":6.0,"weekStartDay":7.0,"weeklyGoal":9.0,'
          '"reward":"X","tasks":[{"id":"a","name":"Alpha"}]},'
          '"completions":[],"claimedWeeks":[]}';
      final out = decodeTokenBackup(json);
      expect(out.template.daysPerWeek, 6);
      expect(out.template.weekStartDay, DateTime.sunday);
      expect(out.template.weeklyGoal, 9);
    });

    test('throws on a malformed completion entry instead of dropping it', () {
      const json =
          '{"format":"$kTokenBackupFormat","version":1,'
          '"template":{"tasks":[{"id":"a","name":"Alpha"}]},'
          '"completions":[{"day":20260706,"taskId":"a"}]}'; // day is a number
      expect(
        () => decodeTokenBackup(json),
        throwsA(isA<TokenBackupFormatException>()),
      );
    });

    test('deduplicates repeated completions and claimed weeks', () {
      const json =
          '{"format":"$kTokenBackupFormat","version":1,'
          '"template":{"tasks":[{"id":"a","name":"Alpha"}]},'
          '"completions":[{"day":"2026-07-06","taskId":"a"},'
          '{"day":"2026-07-06","taskId":"a"}],'
          '"claimedWeeks":["2026-07-06","2026-07-06"]}';
      final out = decodeTokenBackup(json);
      expect(out.completions.length, 1);
      expect(out.claimedWeeks, ['2026-07-06']);
    });
  });

  group('DriftTokenRepository export/import', () {
    late TokenDatabase db;
    late DriftTokenRepository repo;

    setUp(() {
      db = TokenDatabase.forTesting(NativeDatabase.memory());
      repo = DriftTokenRepository(db);
    });

    tearDown(() async => db.close());

    test('exportAll → importAll into a fresh DB restores everything', () async {
      // Seed a realistic state.
      await repo.saveTemplate(
        const TokenTemplate(
          tasks: [Task(id: 't1', name: 'Write'), Task(id: 't2', name: 'Run')],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 7,
          reward: 'Cake',
        ),
      );
      await repo.setTaskCompleted(DateTime(2026, 7, 6), 't1', true);
      await repo.setTaskCompleted(DateTime(2026, 7, 6), 't2', true);
      await repo.setTaskCompleted(DateTime(2026, 7, 7), 't1', true);
      await repo.setRewardClaimed(
        weekStartFor(DateTime(2026, 7, 6), DateTime.monday),
      );

      // Export → serialize → deserialize → import into a brand-new DB, exactly
      // as an uninstall/reinstall round-trip would.
      final exported = await repo.exportAll();
      final decoded = decodeTokenBackup(
        encodeTokenBackup(exported, exportedAt: DateTime(2026, 7, 11)),
      );

      final freshDb = TokenDatabase.forTesting(NativeDatabase.memory());
      final freshRepo = DriftTokenRepository(freshDb);
      addTearDown(() async => freshDb.close());
      await freshRepo.importAll(decoded);

      final template = await freshRepo.loadTemplate();
      expect(template.tasks.map((t) => t.name).toList(), ['Write', 'Run']);
      expect(template.weeklyGoal, 7);
      expect(template.reward, 'Cake');

      final week = weekStartFor(DateTime(2026, 7, 6), DateTime.monday);
      final logs = await freshRepo.logsForWeek(week);
      expect(logs.fold<int>(0, (s, d) => s + d.tokens), 3);
      expect(await freshRepo.isRewardClaimed(week), isTrue);
    });

    test('importAll replaces existing data (no leftovers)', () async {
      // Pre-existing data that must be wiped on import.
      await repo.saveTemplate(
        const TokenTemplate(
          tasks: [Task(id: 'old', name: 'Old task')],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 3,
          reward: 'Old reward',
        ),
      );
      await repo.setTaskCompleted(DateTime(2026, 7, 6), 'old', true);
      await repo.setRewardClaimed(
        weekStartFor(DateTime(2026, 7, 6), DateTime.monday),
      );

      await repo.importAll(
        const TokenBackup(
          template: TokenTemplate(
            tasks: [Task(id: 'new', name: 'New task')],
            daysPerWeek: 4,
            weekStartDay: DateTime.tuesday,
            weeklyGoal: 2,
            reward: 'New reward',
          ),
          completions: [],
          claimedWeeks: [],
        ),
      );

      final template = await repo.loadTemplate();
      expect(template.tasks.map((t) => t.id).toList(), ['new']);
      expect(template.reward, 'New reward');
      // Old completion and claim are gone.
      final oldWeek = weekStartFor(DateTime(2026, 7, 6), DateTime.monday);
      expect(await repo.logsForWeek(oldWeek), isEmpty);
      expect(await repo.isRewardClaimed(oldWeek), isFalse);
    });
  });
}
