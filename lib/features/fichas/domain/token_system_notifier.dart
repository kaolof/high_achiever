import 'package:flutter/foundation.dart';
import 'token_backup.dart';
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
  // Reward texts already granted in past weeks. A non-repeatable tier whose text
  // is in here is "consumed" and won't be granted again.
  Set<String> _pastGrantedTexts = {};

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Safe defaults used only if storage fails at startup, so the UI renders a
  // usable empty week instead of a spinner that never resolves.
  static const _fallbackTemplate = TokenTemplate(
    tasks: [],
    daysPerWeek: 5,
    weekStartDay: DateTime.monday,
    weeklyGoal: 1,
    reward: '',
  );

  Future<void> _init() async {
    try {
      _template = await _repo.loadTemplate();
      await _reloadWeek();
    } catch (e, st) {
      // A storage failure must not hang the UI on an infinite spinner.
      debugPrint('TokenSystemNotifier init failed: $e\n$st');
      _template = _fallbackTemplate;
      _today = dayOnly(DateTime.now());
      _weekStart = weekStartFor(_today, _template.weekStartDay);
      _weekLogs.clear();
      _rewardClaimed = false;
    }
    // Settling the just-ended week is best-effort: a failure here must never
    // break startup, so it gets its own guard.
    try {
      await _settleIfNeeded();
    } catch (e, st) {
      debugPrint('TokenSystemNotifier settle failed: $e\n$st');
    }
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
    // Consumed one-time rewards: texts granted in every already-recorded week.
    // (All recorded weeks are earlier than the current one.)
    _pastGrantedTexts = await _repo.grantedRewardTexts();
  }

  // ── Derived state for the UI ──────────────────────────────────────────────
  String get todayLabel => _weekdayNames[_today.weekday - 1];

  // Ids of the tasks currently in the template. Completions for tasks the user
  // has since deleted still live in storage, but must not count toward the week
  // — otherwise they inflate the totals and can unlock the reward in false.
  Set<String> get _activeTaskIds => {for (final t in _template.tasks) t.id};

  Set<String> get _todayCompleted => _weekLogs[dayKey(_today)] ?? const {};
  bool isDoneToday(String taskId) => _todayCompleted.contains(taskId);
  int get todayDoneCount =>
      _todayCompleted.where(_activeTaskIds.contains).length;

  Task? _taskById(String id) {
    for (final t in _template.tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ── Weekly evaluation (pure over a given week's logs) ──────────────────────
  // These take the logs explicitly so the current week AND a just-ended week
  // (at settlement) run through the exact same math.

  // Distinct days each active task was completed in [logs]. A task can be marked
  // at most once per day, so this is exactly its weekly completion count.
  Map<String, int> _countsFor(Map<String, Set<String>> logs) {
    final active = _activeTaskIds;
    final counts = <String, int>{};
    for (final ids in logs.values) {
      for (final id in ids) {
        if (active.contains(id)) counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    return counts;
  }

  // Tokens count per task only up to its weekly cap, so a task can never earn
  // more than its max and the total never exceeds weeklyMax.
  int _weeklyEarnedFor(Map<String, Set<String>> logs) {
    final counts = _countsFor(logs);
    final days = _template.daysPerWeek;
    var sum = 0;
    for (final t in _template.tasks) {
      final c = counts[t.id] ?? 0;
      final cap = t.effectiveMax(days);
      sum += c < cap ? c : cap;
    }
    return sum;
  }

  // Active tasks still short of their weekly minimum in [logs].
  List<Task> _tasksBelowMinFor(Map<String, Set<String>> logs) {
    final counts = _countsFor(logs);
    return [
      for (final t in _template.tasks)
        if ((counts[t.id] ?? 0) < t.effectiveMin) t,
    ];
  }

  // A tier is available unless it's a one-time reward already granted before.
  bool _isAvailable(RewardTier t) =>
      t.repeatable || !_pastGrantedTexts.contains(t.reward);

  // The best tier earned for [logs]: the highest AVAILABLE tier whose threshold
  // is met, but only once the per-task minimum gate is clear. null when no tier
  // is earned (or basic mode). Encodes "the minimum is always checked" — a tier
  // can't be earned below the lowest threshold or with any task under its min.
  // Consumed one-time tiers are skipped, so a repeat of a spent threshold falls
  // through to the best still-available lower tier.
  RewardTier? _earnedTierFor(Map<String, Set<String>> logs) {
    if (!_template.isTiered) return null;
    if (_tasksBelowMinFor(logs).isNotEmpty) return null;
    final earned = _weeklyEarnedFor(logs);
    RewardTier? best;
    for (final t in _template.rewardTiers) {
      if (earned < t.threshold) break; // tiers are sorted ascending
      if (_isAvailable(t)) best = t; // skip consumed one-time tiers
    }
    return best;
  }

  /// How many days this week [taskId] was completed (active tasks only).
  int weekCount(String taskId) => _activeTaskIds.contains(taskId)
      ? (_countsFor(_weekLogs)[taskId] ?? 0)
      : 0;

  /// The weekly cap for [taskId] (advanced max, or daysPerWeek by default).
  int maxFor(String taskId) =>
      _taskById(taskId)?.effectiveMax(_template.daysPerWeek) ?? 0;

  /// The weekly minimum for [taskId] (advanced min, or 1 by default).
  int minFor(String taskId) => _taskById(taskId)?.effectiveMin ?? 0;

  int get weeklyEarned => _weeklyEarnedFor(_weekLogs);
  int get weeklyMax => _template.maxTokens;
  int get weeklyGoal => _template.weeklyGoal;
  String get reward => _template.reward;

  /// Whether the aggregate token goal alone is met (before the per-task gate).
  bool get goalReached => weeklyEarned >= weeklyGoal;

  /// Active tasks that haven't reached their weekly minimum yet. Non-empty means
  /// the reward stays locked even if [goalReached] is true.
  List<Task> get tasksBelowMin => _tasksBelowMinFor(_weekLogs);

  // ── Reward tiers (advanced) ────────────────────────────────────────────────

  /// True when the template uses a reward ladder instead of a single reward.
  bool get isTiered => _template.isTiered;

  /// The template's reward ladder (empty in basic mode), sorted ascending.
  List<RewardTier> get rewardTiers => _template.rewardTiers;

  /// The best tier earned this week so far, or null if none (basic mode, below
  /// the lowest threshold, a task still under its minimum, or every reached tier
  /// is a spent one-time reward).
  RewardTier? get earnedTier => _earnedTierFor(_weekLogs);

  /// Whether [t] is a one-time reward already earned in a past week (so it won't
  /// be granted again). Repeatable tiers are never consumed.
  bool isTierConsumed(RewardTier t) =>
      !t.repeatable && _pastGrantedTexts.contains(t.reward);

  /// The next, not-yet-reached AND still-available tier — powers the "N tokens
  /// to go" hint. Skips consumed one-time tiers (no point aiming at them). null
  /// when nothing better is left to earn (or in basic mode).
  RewardTier? get nextTier {
    for (final t in _template.rewardTiers) {
      if (weeklyEarned < t.threshold && _isAvailable(t)) return t;
    }
    return null;
  }

  /// Tokens still needed to reach [nextTier]. 0 when there is no next tier.
  int get tokensToNext {
    final n = nextTier;
    return n == null ? 0 : (n.threshold - weeklyEarned).clamp(0, n.threshold);
  }

  // The reward unlocks when the token goal is met AND every task has reached its
  // weekly minimum. In tiered mode that's exactly "some tier is earned".
  bool get rewardUnlocked =>
      isTiered ? earnedTier != null : (goalReached && tasksBelowMin.isEmpty);
  bool get rewardClaimed => _rewardClaimed;
  int get toGo => (weeklyGoal - weeklyEarned).clamp(0, weeklyGoal);

  /// Hard cap: [taskId] can't be completed today once it has hit its weekly max
  /// on other days. An already-done day is never blocked, so it can be undone.
  bool isBlockedToday(String taskId) {
    if (isDoneToday(taskId)) return false;
    return weekCount(taskId) >= maxFor(taskId);
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Toggles a task for today. Returns true if this toggle just crossed into
  /// the "reward unlocked" state, so the UI can trigger the celebration.
  ///
  /// Completing a task that has already reached its weekly max is a no-op (hard
  /// cap); undoing an existing completion is always allowed.
  Future<bool> toggleTask(String taskId) async {
    final set = _weekLogs.putIfAbsent(dayKey(_today), () => <String>{});
    final nowCompleted = !set.contains(taskId);
    if (nowCompleted && isBlockedToday(taskId)) return false;

    final wasUnlocked = rewardUnlocked;
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

  // ── Week-end settlement (tiered mode) ──────────────────────────────────────

  // The reward the just-ended week earned, staged to show once as a "last week"
  // summary then consumed. null when there's nothing new to surface.
  ({String reward, int earned})? _pendingResult;
  ({String reward, int earned})? get pendingResult => _pendingResult;

  /// Clears the pending "last week" result once the UI has shown it.
  void consumePendingResult() => _pendingResult = null;

  // Grants the best tier the previous week earned (tiered mode only), records it
  // per week and stages a one-time summary. The [lastSettledWeek] watermark
  // makes this run exactly once per ended week. The past week is judged with the
  // CURRENT template — a fair simplification, since templates aren't versioned.
  Future<void> _settleIfNeeded() async {
    if (!_template.isTiered) return;
    final last = await _repo.lastSettledWeek();
    if (last == null) {
      // First tiered run: adopt the current week; nothing earlier to settle.
      await _repo.setLastSettledWeek(_weekStart);
      return;
    }
    if (!last.isBefore(_weekStart)) return; // still within the settled week

    final logs = await _repo.logsForWeek(last);
    final weekLogs = {
      for (final l in logs) dayKey(l.date): {...l.completedTaskIds},
    };
    final tier = _earnedTierFor(weekLogs);
    if (tier != null) {
      await _repo.saveWeekResult(
        last,
        _template.rewardTiers.indexOf(tier),
        tier.reward,
      );
      // Consume it now so the current week's live view already reflects a spent
      // one-time reward.
      _pastGrantedTexts = {..._pastGrantedTexts, tier.reward};
      _pendingResult = (reward: tier.reward, earned: _weeklyEarnedFor(weekLogs));
    }
    await _repo.setLastSettledWeek(_weekStart);
  }

  Future<void> updateTemplate(TokenTemplate template) async {
    _template = template;
    await _reloadWeek(); // week window may shift if weekStartDay changed
    notifyListeners();
    await _repo.saveTemplate(template);
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  /// A full snapshot for the "export backup" flow.
  Future<TokenBackup> exportBackup() => _repo.exportAll();

  /// Restores [backup], replacing all current data, then reloads state so the
  /// UI reflects the imported template and week immediately.
  Future<void> importBackup(TokenBackup backup) async {
    // [importAll] is atomic: it either commits fully or rolls back and throws,
    // so a throw here leaves storage untouched and the caller's state valid.
    await _repo.importAll(backup);
    // The import is committed. From here on the data is already persisted, so a
    // failure while refreshing in-memory state must NOT surface as "import
    // failed" (that would mislead the UI into a data-losing re-save). Reuse the
    // template we just wrote instead of re-querying it, and degrade a failed
    // week reload to an empty week rather than propagating.
    _template = backup.template;
    try {
      await _reloadWeek();
    } catch (e, st) {
      debugPrint('importBackup: week reload failed after commit: $e\n$st');
      _today = dayOnly(DateTime.now());
      _weekStart = weekStartFor(_today, _template.weekStartDay);
      _weekLogs.clear();
      _rewardClaimed = false;
    }
    notifyListeners();
  }
}
