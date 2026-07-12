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

  /// A full snapshot of every stored value: template, complete completion
  /// history and all claimed weeks. Powers the "export backup" flow.
  Future<TokenBackup> exportAll();

  /// Replaces ALL stored data with [backup]. Destructive and atomic — used to
  /// restore a backup on a fresh install.
  Future<void> importAll(TokenBackup backup);
}
