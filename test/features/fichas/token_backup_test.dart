import 'package:drift/drift.dart' hide isNull;
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

    test('encode → decode preserves advanced per-task limits', () {
      const b = TokenBackup(
        template: TokenTemplate(
          tasks: [
            Task(id: 'a', name: 'A', minPerWeek: 2, maxPerWeek: 3),
            Task(id: 'b', name: 'B'), // defaults
          ],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 4,
          reward: 'x',
        ),
        completions: [],
        claimedWeeks: [],
      );
      final out = decodeTokenBackup(
        encodeTokenBackup(b, exportedAt: DateTime(2026, 7, 11)),
      );
      expect(out.template.tasks[0].minPerWeek, 2);
      expect(out.template.tasks[0].maxPerWeek, 3);
      expect(out.template.tasks[1].minPerWeek, isNull);
      expect(out.template.tasks[1].maxPerWeek, isNull);
    });

    test('an older backup without per-task limits decodes to defaults', () {
      const json =
          '{"format":"$kTokenBackupFormat","version":1,'
          '"template":{"daysPerWeek":5,"weekStartDay":1,"weeklyGoal":3,'
          '"reward":"x","tasks":[{"id":"a","name":"A"}]},'
          '"completions":[],"claimedWeeks":[]}';
      final out = decodeTokenBackup(json);
      expect(out.template.tasks.single.minPerWeek, isNull);
      expect(out.template.tasks.single.maxPerWeek, isNull);
    });

    test('encode → decode preserves reward tiers, results and watermark', () {
      const b = TokenBackup(
        template: TokenTemplate(
          tasks: [Task(id: 'a', name: 'A'), Task(id: 'b', name: 'B')],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 3,
          reward: '',
          rewardTiers: [
            RewardTier(threshold: 3, reward: 'Bronze'),
            RewardTier(threshold: 6, reward: 'Silver'),
          ],
        ),
        completions: [],
        claimedWeeks: [],
        weekResults: [
          WeekResultEntry(
            weekStart: '2026-07-06',
            tierIndex: 1,
            reward: 'Silver',
          ),
        ],
        lastSettledWeek: '2026-07-13',
      );
      final out = decodeTokenBackup(
        encodeTokenBackup(b, exportedAt: DateTime(2026, 7, 14)),
      );
      expect(out.template.isTiered, isTrue);
      expect(out.template.rewardTiers.map((t) => t.threshold).toList(), [3, 6]);
      expect(out.template.rewardTiers.map((t) => t.reward).toList(), [
        'Bronze',
        'Silver',
      ]);
      expect(out.weekResults.single.weekStart, '2026-07-06');
      expect(out.weekResults.single.tierIndex, 1);
      expect(out.weekResults.single.reward, 'Silver');
      expect(out.lastSettledWeek, '2026-07-13');
    });

    test('a basic-mode backup omits the new fields and decodes empty', () {
      const b = TokenBackup(
        template: TokenTemplate(
          tasks: [Task(id: 'a', name: 'A')],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 1,
          reward: 'Solo',
        ),
        completions: [],
        claimedWeeks: [],
      );
      final json = encodeTokenBackup(b, exportedAt: DateTime(2026, 7, 11));
      expect(json.contains('rewardTiers'), isFalse);
      expect(json.contains('weekResults'), isFalse);
      expect(json.contains('lastSettledWeek'), isFalse);

      final out = decodeTokenBackup(json);
      expect(out.template.isTiered, isFalse);
      expect(out.weekResults, isEmpty);
      expect(out.lastSettledWeek, isNull);
    });

    test('reward tiers decode sorted ascending even if listed out of order', () {
      const json =
          '{"format":"$kTokenBackupFormat","version":1,'
          '"template":{"daysPerWeek":5,"weekStartDay":1,"weeklyGoal":3,'
          '"reward":"","tasks":[{"id":"a","name":"A"}],'
          '"rewardTiers":[{"threshold":9,"reward":"Gold"},'
          '{"threshold":3,"reward":"Bronze"}]},'
          '"completions":[],"claimedWeeks":[]}';
      final out = decodeTokenBackup(json);
      expect(out.template.rewardTiers.map((t) => t.threshold).toList(), [3, 9]);
      expect(out.template.rewardTiers.first.reward, 'Bronze');
    });

    test('throws on a malformed reward tier', () {
      const json =
          '{"format":"$kTokenBackupFormat","version":1,'
          '"template":{"tasks":[{"id":"a","name":"A"}],'
          '"rewardTiers":[{"threshold":"lots","reward":"Gold"}]},'
          '"completions":[],"claimedWeeks":[]}';
      expect(
        () => decodeTokenBackup(json),
        throwsA(isA<TokenBackupFormatException>()),
      );
    });

    test('the one-time flag round-trips; repeatable tiers stay compact', () {
      const b = TokenBackup(
        template: TokenTemplate(
          tasks: [Task(id: 'a', name: 'A')],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 2,
          reward: '',
          rewardTiers: [
            RewardTier(threshold: 2, reward: 'Ice cream'), // repeatable
            RewardTier(threshold: 4, reward: 'Gift', repeatable: false),
          ],
        ),
        completions: [],
        claimedWeeks: [],
      );
      final json = encodeTokenBackup(b, exportedAt: DateTime(2026, 7, 11));
      // Only the one-time tier writes the flag; the default stays implicit.
      expect(json.contains('"repeatable": false'), isTrue);
      final out = decodeTokenBackup(json);
      expect(out.template.rewardTiers[0].repeatable, isTrue);
      expect(out.template.rewardTiers[1].repeatable, isFalse);
    });

    test('a tiered backup without the repeatable key decodes to repeatable', () {
      const json =
          '{"format":"$kTokenBackupFormat","version":1,'
          '"template":{"daysPerWeek":5,"weekStartDay":1,"weeklyGoal":2,'
          '"reward":"","tasks":[{"id":"a","name":"A"}],'
          '"rewardTiers":[{"threshold":2,"reward":"X"}]},'
          '"completions":[],"claimedWeeks":[]}';
      final out = decodeTokenBackup(json);
      expect(out.template.rewardTiers.single.repeatable, isTrue);
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

    test('tiers, week results and watermark survive the reinstall', () async {
      await repo.saveTemplate(
        const TokenTemplate(
          tasks: [Task(id: 't1', name: 'Write'), Task(id: 't2', name: 'Run')],
          daysPerWeek: 5,
          weekStartDay: DateTime.monday,
          weeklyGoal: 3,
          reward: '',
          rewardTiers: [
            RewardTier(threshold: 3, reward: 'Bronze'),
            RewardTier(threshold: 5, reward: 'Silver'),
          ],
        ),
      );
      final wk = weekStartFor(DateTime(2026, 7, 6), DateTime.monday);
      await repo.saveWeekResult(wk, 1, 'Silver');
      await repo.setLastSettledWeek(wk);

      final decoded = decodeTokenBackup(
        encodeTokenBackup(
          await repo.exportAll(),
          exportedAt: DateTime(2026, 7, 14),
        ),
      );
      final freshDb = TokenDatabase.forTesting(NativeDatabase.memory());
      final freshRepo = DriftTokenRepository(freshDb);
      addTearDown(() async => freshDb.close());
      await freshRepo.importAll(decoded);

      final t = await freshRepo.loadTemplate();
      expect(t.rewardTiers.map((e) => e.reward).toList(), ['Bronze', 'Silver']);
      expect(await freshRepo.lastSettledWeek(), wk);
      final reexport = await freshRepo.exportAll();
      expect(reexport.weekResults.single.reward, 'Silver');
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
