import 'token_backup.dart';
import 'token_models.dart';

/// The contract between the token system's logic and its storage.
///
/// The UI and [TokenSystemNotifier] depend only on this interface, so the
/// backing store is swappable — currently [DriftTokenRepository]
/// (Drift/SQLite, Fase B2) — with zero UI changes.
abstract class TokenRepository {
  Future<TokenTemplate> loadTemplate();
  Future<void> saveTemplate(TokenTemplate template);

  /// Day logs whose date falls in the 7-day window starting at [weekStart].
  Future<List<DayLog>> logsForWeek(DateTime weekStart);

  /// Marks [taskId] complete/incomplete for [day].
  Future<void> setTaskCompleted(DateTime day, String taskId, bool completed);

  /// Whether the reward for the week starting at [weekStart] has been claimed.
  Future<bool> isRewardClaimed(DateTime weekStart);

  /// Marks the reward for the week starting at [weekStart] as claimed.
  Future<void> setRewardClaimed(DateTime weekStart);

  // ── Advanced reward tiers: week-end settlement ─────────────────────────────

  /// The most recent week already settled (tiered mode), or null if never. The
  /// settlement watermark, so a rolled-over week is granted exactly once.
  Future<DateTime?> lastSettledWeek();

  /// Advances the settlement watermark to [weekStart].
  Future<void> setLastSettledWeek(DateTime weekStart);

  /// Records that the week starting at [weekStart] earned the tier at
  /// [tierIndex] in the ladder, whose text is [reward] (denormalized so the
  /// record survives later template edits).
  Future<void> saveWeekResult(DateTime weekStart, int tierIndex, String reward);

  /// Every distinct reward text granted in a past week. A one-time tier whose
  /// text is in here is "consumed" and must not be granted again.
  Future<Set<String>> grantedRewardTexts();

  /// A full snapshot of every stored value: template (incl. reward tiers),
  /// complete completion history, claimed weeks, settled week results and the
  /// settlement watermark. Powers the "export backup" flow.
  Future<TokenBackup> exportAll();

  /// Replaces ALL stored data with [backup]. Destructive and atomic — used to
  /// restore a backup on a fresh install.
  Future<void> importAll(TokenBackup backup);
}
