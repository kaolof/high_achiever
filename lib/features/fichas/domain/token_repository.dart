import 'token_models.dart';

/// The contract between the token system's logic and its storage.
///
/// The UI and [TokenSystemNotifier] depend only on this interface, so the
/// backing store is swappable: [FakeTokenRepository] (in-memory, Fase B1) today,
/// a Drift/SQLite implementation (Fase B2) later — with zero UI changes.
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
}
