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
class TaskRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get position => integer()();

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
/// day ("YYYY-MM-DD"). Presence of a row = claimed.
class WeekClaims extends Table {
  TextColumn get weekStart => text()();

  @override
  Set<Column> get primaryKey => {weekStart};
}

@DriftDatabase(tables: [TemplateSettings, TaskRows, Completions, WeekClaims])
class TokenDatabase extends _$TokenDatabase {
  TokenDatabase() : super(_open());

  /// For tests: pass an in-memory executor.
  TokenDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 → v2: reward-claim tracking.
          if (from < 2) await m.createTable(weekClaims);
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
