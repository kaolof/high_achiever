import 'package:flutter/foundation.dart';
import 'token_date.dart';
import 'token_models.dart';
import 'token_repository.dart';

/// Holds the token system's state and business logic. Talks to a
/// [TokenRepository], never to storage directly, so the UI is decoupled from
/// where the data lives.
class TokenSystemNotifier extends ChangeNotifier {
  final TokenRepository _repo;

  TokenSystemNotifier(this._repo) {
    _init();
  }

  bool _loading = true;
  bool get isLoading => _loading;

  late TokenTemplate _template;
  TokenTemplate get template => _template;

  // Current week's logs, keyed by day ("YYYY-MM-DD") -> completed task ids.
  final Map<String, Set<String>> _weekLogs = {};
  late DateTime _today;
  late DateTime _weekStart;
  bool _rewardClaimed = false;

  static const _weekdayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  Future<void> _init() async {
    _template = await _repo.loadTemplate();
    await _reloadWeek();
    _loading = false;
    notifyListeners();
  }

  Future<void> _reloadWeek() async {
    _today = dayOnly(DateTime.now());
    _weekStart = weekStartFor(_today, _template.weekStartDay);
    final logs = await _repo.logsForWeek(_weekStart);
    _weekLogs
      ..clear()
      ..addEntries(
        logs.map((l) => MapEntry(dayKey(l.date), {...l.completedTaskIds})),
      );
    // Claim state is keyed by week, so a new week starts unclaimed for free.
    _rewardClaimed = await _repo.isRewardClaimed(_weekStart);
  }

  // ── Derived state for the UI ──────────────────────────────────────────────
  String get todayLabel => _weekdayNames[_today.weekday - 1];

  Set<String> get _todayCompleted => _weekLogs[dayKey(_today)] ?? const {};
  bool isDoneToday(String taskId) => _todayCompleted.contains(taskId);
  int get todayDoneCount => _todayCompleted.length;

  int get weeklyEarned =>
      _weekLogs.values.fold(0, (sum, ids) => sum + ids.length);
  int get weeklyMax => _template.maxTokens;
  int get weeklyGoal => _template.weeklyGoal;
  String get reward => _template.reward;
  bool get rewardUnlocked => weeklyEarned >= weeklyGoal;
  bool get rewardClaimed => _rewardClaimed;
  int get toGo => (weeklyGoal - weeklyEarned).clamp(0, weeklyGoal);

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Toggles a task for today. Returns true if this toggle just crossed into
  /// the "reward unlocked" state, so the UI can trigger the celebration.
  Future<bool> toggleTask(String taskId) async {
    final wasUnlocked = rewardUnlocked;
    final set = _weekLogs.putIfAbsent(dayKey(_today), () => <String>{});
    final nowCompleted = !set.contains(taskId);
    if (nowCompleted) {
      set.add(taskId);
    } else {
      set.remove(taskId);
    }
    notifyListeners();
    await _repo.setTaskCompleted(_today, taskId, nowCompleted);
    return !wasUnlocked && rewardUnlocked;
  }

  /// Marks this week's reward as claimed. Idempotent and persisted, so the
  /// celebration won't nag again this week.
  Future<void> claimReward() async {
    if (_rewardClaimed) return;
    _rewardClaimed = true;
    notifyListeners();
    await _repo.setRewardClaimed(_weekStart);
  }

  Future<void> updateTemplate(TokenTemplate template) async {
    _template = template;
    await _reloadWeek(); // week window may shift if weekStartDay changed
    notifyListeners();
    await _repo.saveTemplate(template);
  }
}
