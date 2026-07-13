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

  // Distinct days this week each active task was completed. A task can be marked
  // at most once per day, so this is exactly its weekly completion count.
  Map<String, int> get _weekCounts {
    final active = _activeTaskIds;
    final counts = <String, int>{};
    for (final ids in _weekLogs.values) {
      for (final id in ids) {
        if (active.contains(id)) counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// How many days this week [taskId] was completed (active tasks only).
  int weekCount(String taskId) =>
      _activeTaskIds.contains(taskId) ? (_weekCounts[taskId] ?? 0) : 0;

  /// The weekly cap for [taskId] (advanced max, or daysPerWeek by default).
  int maxFor(String taskId) =>
      _taskById(taskId)?.effectiveMax(_template.daysPerWeek) ?? 0;

  /// The weekly minimum for [taskId] (advanced min, or 1 by default).
  int minFor(String taskId) => _taskById(taskId)?.effectiveMin ?? 0;

  // Tokens count per task only up to its weekly cap, so a task can never earn
  // more than its max and weeklyEarned never exceeds weeklyMax.
  int get weeklyEarned {
    final counts = _weekCounts;
    final days = _template.daysPerWeek;
    var sum = 0;
    for (final t in _template.tasks) {
      final c = counts[t.id] ?? 0;
      final cap = t.effectiveMax(days);
      sum += c < cap ? c : cap;
    }
    return sum;
  }

  int get weeklyMax => _template.maxTokens;
  int get weeklyGoal => _template.weeklyGoal;
  String get reward => _template.reward;

  /// Whether the aggregate token goal alone is met (before the per-task gate).
  bool get goalReached => weeklyEarned >= weeklyGoal;

  /// Active tasks that haven't reached their weekly minimum yet. Non-empty means
  /// the reward stays locked even if [goalReached] is true.
  List<Task> get tasksBelowMin {
    final counts = _weekCounts;
    return [
      for (final t in _template.tasks)
        if ((counts[t.id] ?? 0) < t.effectiveMin) t,
    ];
  }

  // The reward unlocks only when BOTH the token goal is met AND every task has
  // reached its weekly minimum (default 1, or the advanced min for customized
  // tasks).
  bool get rewardUnlocked => goalReached && tasksBelowMin.isEmpty;
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
