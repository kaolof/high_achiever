import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'token_database.g.dart';

/// Single-row table (id always 1) holding the user's template config.
class TemplateSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get daysPerWeek => integer().withDefault(const Constant(5))();
  IntColumn get weekStartDay => integer().withDefault(const Constant(1))();
  IntColumn get weeklyGoal => integer().withDefault(const Constant(18))();
  TextColumn get reward => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The fixed daily tasks (the template's task list), ordered by [position].
/// [minPerWeek]/[maxPerWeek] are the advanced weekly limits; `null` means the
/// task follows the template defaults (min 1, max daysPerWeek).
class TaskRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get position => integer()();
  IntColumn get minPerWeek => integer().nullable()();
  IntColumn get maxPerWeek => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Append-only log: one row per completed task per day. Tokens = row count.
/// [day] is a zero-padded "YYYY-MM-DD" string, so lexicographic range queries
/// match calendar range queries.
class Completions extends Table {
  TextColumn get day => text()();
  TextColumn get taskId => text()();

  @override
  Set<Column> get primaryKey => {day, taskId};
}

/// One row per week whose reward has been claimed, keyed by the week's start
/// day ("YYYY-MM-DD"). Presence of a row = claimed. Used by BASIC mode only.
class WeekClaims extends Table {
  TextColumn get weekStart => text()();

  @override
  Set<Column> get primaryKey => {weekStart};
}

/// Advanced reward ladder: one row per tier, ordered by [position] (which also
/// reflects ascending [threshold]). Empty table = basic (single-reward) mode.
/// [repeatable] false means a one-time reward, granted at most once ever.
class RewardTierRows extends Table {
  IntColumn get position => integer()();
  IntColumn get threshold => integer()();
  TextColumn get reward => text()();
  BoolColumn get repeatable => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {position};
}

/// Settled reward for a past week (tiered mode): the best tier that week earned.
/// [reward] is denormalized so the history survives later template edits. Keyed
/// by the week's start day ("YYYY-MM-DD").
class WeekResults extends Table {
  TextColumn get weekStart => text()();
  IntColumn get tierIndex => integer()();
  TextColumn get reward => text()();

  @override
  Set<Column> get primaryKey => {weekStart};
}

/// Single-row (id=1) watermark: the most recent week whose reward has been
/// settled, so rollover settlement runs exactly once per ended week.
class SettlementState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get lastSettledWeek => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    TemplateSettings,
    TaskRows,
    Completions,
    WeekClaims,
    RewardTierRows,
    WeekResults,
    SettlementState,
  ],
)
class TokenDatabase extends _$TokenDatabase {
  TokenDatabase() : super(_open());

  /// For tests: pass an in-memory executor.
  TokenDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 → v2: reward-claim tracking.
      if (from < 2) await m.createTable(weekClaims);
      // v2 → v3: per-task advanced weekly limits (both nullable).
      if (from < 3) {
        await m.addColumn(taskRows, taskRows.minPerWeek);
        await m.addColumn(taskRows, taskRows.maxPerWeek);
      }
      // v3 → v4: advanced reward tiers + week-end settlement bookkeeping.
      if (from < 4) {
        await m.createTable(rewardTierRows);
        await m.createTable(weekResults);
        await m.createTable(settlementState);
      }
      // v4 → v5: per-tier "repeatable" flag. Only a db already at v4 lacks the
      // column — dbs coming from ≤ v3 got the whole RewardTierRows table (with
      // `repeatable`) via createTable in the v3→v4 step above.
      if (from == 4) {
        await m.addColumn(rewardTierRows, rewardTierRows.repeatable);
      }
    },
  );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'high_achiever_tokens.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
