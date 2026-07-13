// Domain models for the token system. Plain Dart — no persistence concerns.

/// A fixed daily task from the user's template. Completing it earns 1 token.
///
/// Advanced settings: [minPerWeek]/[maxPerWeek] are optional weekly limits. When
/// `null` they fall back to the template's defaults — min 1 (every task must be
/// done at least once) and max [TokenTemplate.daysPerWeek] (the nominal active
/// days). A task is "customized" only when at least one of them is set.
class Task {
  final String id;
  final String name;
  final int? minPerWeek; // null → default 1
  final int? maxPerWeek; // null → default daysPerWeek

  const Task({
    required this.id,
    required this.name,
    this.minPerWeek,
    this.maxPerWeek,
  });

  /// True when the user overrode either weekly limit for this task.
  bool get isCustomized => minPerWeek != null || maxPerWeek != null;

  /// Minimum times/week this task must be completed to count toward the reward.
  int get effectiveMin => minPerWeek ?? 1;

  /// Maximum times/week this task can be completed / earn tokens. Defaults to
  /// the template's nominal active days.
  int effectiveMax(int daysPerWeek) => maxPerWeek ?? daysPerWeek;

  Task copyWith({String? id, String? name, int? minPerWeek, int? maxPerWeek}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      minPerWeek: minPerWeek ?? this.minPerWeek,
      maxPerWeek: maxPerWeek ?? this.maxPerWeek,
    );
  }
}

/// The user's configuration ("the template"): which tasks, how often, the goal
/// and the reward. [maxTokens] is the sum of each task's effective weekly max
/// (which equals tasks × daysPerWeek when no task is customized).
class TokenTemplate {
  final List<Task> tasks;
  final int daysPerWeek;
  final int weekStartDay; // 1 = Mon … 7 = Sun
  final int weeklyGoal; // minimum tokens to unlock the reward
  final String reward;

  const TokenTemplate({
    required this.tasks,
    required this.daysPerWeek,
    required this.weekStartDay,
    required this.weeklyGoal,
    required this.reward,
  });

  int get maxTokens =>
      tasks.fold(0, (sum, t) => sum + t.effectiveMax(daysPerWeek));

  TokenTemplate copyWith({
    List<Task>? tasks,
    int? daysPerWeek,
    int? weekStartDay,
    int? weeklyGoal,
    String? reward,
  }) {
    return TokenTemplate(
      tasks: tasks ?? this.tasks,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      reward: reward ?? this.reward,
    );
  }
}

/// Which tasks were completed on a given day. Tokens earned that day equals the
/// number of completed tasks.
class DayLog {
  final DateTime date; // day-normalized
  final Set<String> completedTaskIds;
  const DayLog({required this.date, required this.completedTaskIds});

  int get tokens => completedTaskIds.length;
}
