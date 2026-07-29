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

/// Advanced settings: one entry of a reward ladder. Reaching [threshold] tokens
/// in the week earns [reward]. Tiers are always kept sorted by ascending
/// [threshold]; the lowest tier's threshold is the week's minimum (== the
/// template's [TokenTemplate.weeklyGoal]).
///
/// [repeatable] tiers can be earned every week they're reached (an ice cream, a
/// lazy weekend). A non-repeatable ("one-time") tier — a specific gift — is
/// granted at most once: once a past week earned it, it's "consumed" and future
/// weeks fall through to the best still-available lower tier. Identity for
/// consumption is the [reward] text, so renaming a reward makes it new again.
class RewardTier {
  final int threshold; // tokens needed for this tier
  final String reward; // free-text description
  final bool repeatable; // false → one-time (earned at most once, ever)

  const RewardTier({
    required this.threshold,
    required this.reward,
    this.repeatable = true,
  });

  RewardTier copyWith({int? threshold, String? reward, bool? repeatable}) =>
      RewardTier(
        threshold: threshold ?? this.threshold,
        reward: reward ?? this.reward,
        repeatable: repeatable ?? this.repeatable,
      );
}

/// The user's configuration ("the template"): which tasks, how often, the goal
/// and the reward. [maxTokens] is the sum of each task's effective weekly max
/// (which equals tasks × daysPerWeek when no task is customized).
///
/// Rewards come in two modes:
/// - **Basic** (default): [rewardTiers] empty → a single [reward] unlocked at
///   [weeklyGoal].
/// - **Tiered** (advanced): [rewardTiers] non-empty → a ladder of rewards, one
///   per token threshold. The best tier reached is granted at week's end.
class TokenTemplate {
  final List<Task> tasks;
  final int daysPerWeek;
  final int weekStartDay; // 1 = Mon … 7 = Sun
  final int weeklyGoal; // minimum tokens to unlock the reward
  final String reward;
  final List<RewardTier> rewardTiers; // empty → basic mode

  const TokenTemplate({
    required this.tasks,
    required this.daysPerWeek,
    required this.weekStartDay,
    required this.weeklyGoal,
    required this.reward,
    this.rewardTiers = const [],
  });

  int get maxTokens =>
      tasks.fold(0, (sum, t) => sum + t.effectiveMax(daysPerWeek));

  /// True when the user configured a reward ladder instead of a single reward.
  bool get isTiered => rewardTiers.isNotEmpty;

  TokenTemplate copyWith({
    List<Task>? tasks,
    int? daysPerWeek,
    int? weekStartDay,
    int? weeklyGoal,
    String? reward,
    List<RewardTier>? rewardTiers,
  }) {
    return TokenTemplate(
      tasks: tasks ?? this.tasks,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      reward: reward ?? this.reward,
      rewardTiers: rewardTiers ?? this.rewardTiers,
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
