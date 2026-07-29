import 'package:drift/drift.dart';
import '../domain/token_backup.dart';
import '../domain/token_date.dart';
import '../domain/token_models.dart';
import '../domain/token_repository.dart';
import 'token_database.dart';

/// SQLite-backed [TokenRepository] (Fase B2). Wired in main.dart.
/// Data survives app restarts.
class DriftTokenRepository implements TokenRepository {
  final TokenDatabase _db;
  DriftTokenRepository(this._db);

  @override
  Future<TokenTemplate> loadTemplate() async {
    final settings = await (_db.select(
      _db.templateSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (settings == null) return _defaultTemplate();

    final rows = await (_db.select(
      _db.taskRows,
    )..orderBy([(t) => OrderingTerm(expression: t.position)])).get();
    final tasks = rows.isEmpty
        ? _defaultTemplate().tasks
        : [
            for (final r in rows)
              Task(
                id: r.id,
                name: r.name,
                minPerWeek: r.minPerWeek,
                maxPerWeek: r.maxPerWeek,
              ),
          ];

    final tierRows = await (_db.select(
      _db.rewardTierRows,
    )..orderBy([(t) => OrderingTerm(expression: t.position)])).get();

    return TokenTemplate(
      tasks: tasks,
      daysPerWeek: settings.daysPerWeek,
      weekStartDay: settings.weekStartDay,
      weeklyGoal: settings.weeklyGoal,
      reward: settings.reward,
      rewardTiers: [
        for (final r in tierRows)
          RewardTier(
            threshold: r.threshold,
            reward: r.reward,
            repeatable: r.repeatable,
          ),
      ],
    );
  }

  @override
  Future<void> saveTemplate(TokenTemplate template) async {
    await _db.transaction(() => _writeTemplate(template));
  }

  /// Writes the single settings row and replaces the task list wholesale.
  /// Must run inside a transaction — see [saveTemplate] and [importAll].
  Future<void> _writeTemplate(TokenTemplate template) async {
    await _db
        .into(_db.templateSettings)
        .insertOnConflictUpdate(
          TemplateSettingsCompanion.insert(
            id: const Value(1),
            daysPerWeek: Value(template.daysPerWeek),
            weekStartDay: Value(template.weekStartDay),
            weeklyGoal: Value(template.weeklyGoal),
            reward: Value(template.reward),
          ),
        );
    await _db.delete(_db.taskRows).go();
    for (var i = 0; i < template.tasks.length; i++) {
      final t = template.tasks[i];
      await _db
          .into(_db.taskRows)
          .insert(
            TaskRowsCompanion.insert(
              id: t.id,
              name: t.name,
              position: i,
              minPerWeek: Value(t.minPerWeek),
              maxPerWeek: Value(t.maxPerWeek),
            ),
          );
    }
    // Reward ladder is replaced wholesale too; empty in basic mode.
    await _db.delete(_db.rewardTierRows).go();
    for (var i = 0; i < template.rewardTiers.length; i++) {
      final tier = template.rewardTiers[i];
      await _db
          .into(_db.rewardTierRows)
          .insert(
            RewardTierRowsCompanion.insert(
              position: Value(i),
              threshold: tier.threshold,
              reward: tier.reward,
              repeatable: Value(tier.repeatable),
            ),
          );
    }
  }

  @override
  Future<List<DayLog>> logsForWeek(DateTime weekStart) async {
    final startKey = dayKey(weekStart);
    // Calendar arithmetic so a DST-length day doesn't drop the last day.
    final endKey = dayKey(
      DateTime(weekStart.year, weekStart.month, weekStart.day + 7),
    );
    final rows =
        await (_db.select(_db.completions)..where(
              (c) =>
                  c.day.isBiggerOrEqualValue(startKey) &
                  c.day.isSmallerThanValue(endKey),
            ))
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
    DateTime day,
    String taskId,
    bool completed,
  ) async {
    final key = dayKey(day);
    if (completed) {
      await _db
          .into(_db.completions)
          .insert(
            CompletionsCompanion.insert(day: key, taskId: taskId),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (_db.delete(
        _db.completions,
      )..where((c) => c.day.equals(key) & c.taskId.equals(taskId))).go();
    }
  }

  @override
  Future<bool> isRewardClaimed(DateTime weekStart) async {
    final row = await (_db.select(
      _db.weekClaims,
    )..where((c) => c.weekStart.equals(dayKey(weekStart)))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> setRewardClaimed(DateTime weekStart) async {
    await _db
        .into(_db.weekClaims)
        .insert(
          WeekClaimsCompanion.insert(weekStart: dayKey(weekStart)),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<DateTime?> lastSettledWeek() async {
    final row = await (_db.select(
      _db.settlementState,
    )..where((s) => s.id.equals(1))).getSingleOrNull();
    final key = row?.lastSettledWeek;
    return key == null ? null : parseDayKey(key);
  }

  @override
  Future<void> setLastSettledWeek(DateTime weekStart) async {
    await _db
        .into(_db.settlementState)
        .insertOnConflictUpdate(
          SettlementStateCompanion.insert(
            id: const Value(1),
            lastSettledWeek: Value(dayKey(weekStart)),
          ),
        );
  }

  @override
  Future<void> saveWeekResult(
    DateTime weekStart,
    int tierIndex,
    String reward,
  ) async {
    await _db
        .into(_db.weekResults)
        .insertOnConflictUpdate(
          WeekResultsCompanion.insert(
            weekStart: dayKey(weekStart),
            tierIndex: tierIndex,
            reward: reward,
          ),
        );
  }

  @override
  Future<Set<String>> grantedRewardTexts() async {
    final rows = await _db.select(_db.weekResults).get();
    return {for (final r in rows) r.reward};
  }

  @override
  Future<TokenBackup> exportAll() async {
    final template = await loadTemplate();
    final comps = await _db.select(_db.completions).get();
    final claims = await _db.select(_db.weekClaims).get();
    final results = await _db.select(_db.weekResults).get();
    final settlement = await (_db.select(
      _db.settlementState,
    )..where((s) => s.id.equals(1))).getSingleOrNull();
    return TokenBackup(
      template: template,
      completions: [
        for (final c in comps) CompletionEntry(day: c.day, taskId: c.taskId),
      ],
      claimedWeeks: [for (final c in claims) c.weekStart],
      weekResults: [
        for (final r in results)
          WeekResultEntry(
            weekStart: r.weekStart,
            tierIndex: r.tierIndex,
            reward: r.reward,
          ),
      ],
      lastSettledWeek: settlement?.lastSettledWeek,
    );
  }

  @override
  Future<void> importAll(TokenBackup backup) async {
    await _db.transaction(() async {
      // Wipe the append-only logs + settlement, then reset the template
      // (settings + tasks + reward tiers, via _writeTemplate).
      await _db.delete(_db.completions).go();
      await _db.delete(_db.weekClaims).go();
      await _db.delete(_db.weekResults).go();
      await _db.delete(_db.settlementState).go();
      await _writeTemplate(backup.template);
      for (final c in backup.completions) {
        await _db
            .into(_db.completions)
            .insert(
              CompletionsCompanion.insert(day: c.day, taskId: c.taskId),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final w in backup.claimedWeeks) {
        await _db
            .into(_db.weekClaims)
            .insert(
              WeekClaimsCompanion.insert(weekStart: w),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final r in backup.weekResults) {
        await _db
            .into(_db.weekResults)
            .insert(
              WeekResultsCompanion.insert(
                weekStart: r.weekStart,
                tierIndex: r.tierIndex,
                reward: r.reward,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      if (backup.lastSettledWeek != null) {
        await _db
            .into(_db.settlementState)
            .insertOnConflictUpdate(
              SettlementStateCompanion.insert(
                id: const Value(1),
                lastSettledWeek: Value(backup.lastSettledWeek),
              ),
            );
      }
    });
  }

  /// Inserts the default template on first launch (no settings row yet).
  Future<void> seedIfEmpty() async {
    final settings = await (_db.select(
      _db.templateSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
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
