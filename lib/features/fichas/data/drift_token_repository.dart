import 'package:drift/drift.dart';
import '../domain/token_date.dart';
import '../domain/token_models.dart';
import '../domain/token_repository.dart';
import 'token_database.dart';

/// SQLite-backed [TokenRepository] (Fase B2). Same contract as
/// [FakeTokenRepository], so swapping it in is a one-line change in main.dart.
/// Data now survives app restarts.
class DriftTokenRepository implements TokenRepository {
  final TokenDatabase _db;
  DriftTokenRepository(this._db);

  @override
  Future<TokenTemplate> loadTemplate() async {
    final settings = await (_db.select(_db.templateSettings)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (settings == null) return _defaultTemplate();

    final rows = await (_db.select(_db.taskRows)
          ..orderBy([(t) => OrderingTerm(expression: t.position)]))
        .get();
    final tasks = rows.isEmpty
        ? _defaultTemplate().tasks
        : [for (final r in rows) Task(id: r.id, name: r.name)];

    return TokenTemplate(
      tasks: tasks,
      daysPerWeek: settings.daysPerWeek,
      weekStartDay: settings.weekStartDay,
      weeklyGoal: settings.weeklyGoal,
      reward: settings.reward,
    );
  }

  @override
  Future<void> saveTemplate(TokenTemplate template) async {
    await _db.transaction(() async {
      await _db.into(_db.templateSettings).insertOnConflictUpdate(
            TemplateSettingsCompanion.insert(
              id: const Value(1),
              daysPerWeek: Value(template.daysPerWeek),
              weekStartDay: Value(template.weekStartDay),
              weeklyGoal: Value(template.weeklyGoal),
              reward: Value(template.reward),
            ),
          );
      // Replace the task list wholesale.
      await _db.delete(_db.taskRows).go();
      for (var i = 0; i < template.tasks.length; i++) {
        final t = template.tasks[i];
        await _db.into(_db.taskRows).insert(
              TaskRowsCompanion.insert(id: t.id, name: t.name, position: i),
            );
      }
    });
  }

  @override
  Future<List<DayLog>> logsForWeek(DateTime weekStart) async {
    final startKey = dayKey(weekStart);
    final endKey = dayKey(weekStart.add(const Duration(days: 7)));
    final rows = await (_db.select(_db.completions)
          ..where((c) =>
              c.day.isBiggerOrEqualValue(startKey) &
              c.day.isSmallerThanValue(endKey)))
        .get();

    final byDay = <String, Set<String>>{};
    for (final r in rows) {
      byDay.putIfAbsent(r.day, () => <String>{}).add(r.taskId);
    }
    return [
      for (final e in byDay.entries)
        DayLog(date: parseDayKey(e.key), completedTaskIds: e.value),
    ];
  }

  @override
  Future<void> setTaskCompleted(
      DateTime day, String taskId, bool completed) async {
    final key = dayKey(day);
    if (completed) {
      await _db.into(_db.completions).insert(
            CompletionsCompanion.insert(day: key, taskId: taskId),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (_db.delete(_db.completions)
            ..where((c) => c.day.equals(key) & c.taskId.equals(taskId)))
          .go();
    }
  }

  @override
  Future<bool> isRewardClaimed(DateTime weekStart) async {
    final row = await (_db.select(_db.weekClaims)
          ..where((c) => c.weekStart.equals(dayKey(weekStart))))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> setRewardClaimed(DateTime weekStart) async {
    await _db.into(_db.weekClaims).insert(
          WeekClaimsCompanion.insert(weekStart: dayKey(weekStart)),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Inserts the default template on first launch (no settings row yet).
  Future<void> seedIfEmpty() async {
    final settings = await (_db.select(_db.templateSettings)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (settings == null) await saveTemplate(_defaultTemplate());
  }

  static TokenTemplate _defaultTemplate() => const TokenTemplate(
        tasks: [
          Task(id: 't1', name: 'Write 500 words'),
          Task(id: 't2', name: 'Deep work block'),
          Task(id: 't3', name: 'Exercise'),
          Task(id: 't4', name: 'Read 20 min'),
          Task(id: 't5', name: 'Review project'),
        ],
        daysPerWeek: 5,
        weekStartDay: DateTime.monday,
        weeklyGoal: 18,
        reward: 'Dinner out 🍽️',
      );
}
