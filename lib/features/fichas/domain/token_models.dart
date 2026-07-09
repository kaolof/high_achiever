// Domain models for the token system. Plain Dart — no persistence concerns.

/// A fixed daily task from the user's template. Completing it earns 1 token.
class Task {
  final String id;
  final String name;
  const Task({required this.id, required this.name});
}

/// The user's configuration ("the template"): which tasks, how often, the goal
/// and the reward. [maxTokens] = tasks × daysPerWeek.
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

  int get maxTokens => tasks.length * daysPerWeek;

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
