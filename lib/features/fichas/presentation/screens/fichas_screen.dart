import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/token_models.dart';
import '../../domain/token_system_notifier.dart';
import 'reward_celebration_screen.dart';
import 'token_config_screen.dart';

/// Fase A1 (now wired to real state in Fase B1).
///
/// Reads everything from [TokenSystemNotifier] via provider. The widgets are
/// unchanged from the mock version — only the data source moved.
class FichasScreen extends StatelessWidget {
  const FichasScreen({super.key});

  Future<void> _toggle(BuildContext context, String taskId) async {
    final notifier = context.read<TokenSystemNotifier>();
    final justUnlocked = await notifier.toggleTask(taskId);
    // Basic mode celebrates the moment the reward unlocks. Tiered mode has no
    // mid-week claim — the best tier is granted at week's end — so it never pops
    // the celebration here.
    if (justUnlocked &&
        !notifier.isTiered &&
        !notifier.rewardClaimed &&
        context.mounted) {
      _showCelebration(context);
    }
  }

  void _showCelebration(BuildContext context) {
    final n = context.read<TokenSystemNotifier>();
    RewardCelebrationScreen.show(
      context,
      reward: n.reward,
      earned: n.weeklyEarned,
      max: n.weeklyMax,
      onClaim: n.claimReward,
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<TokenSystemNotifier>();
    // Tiered mode: surface last week's granted reward once, after this frame.
    final pending = n.pendingResult;
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        // Consume first so a rebuild can't re-open the summary.
        context.read<TokenSystemNotifier>().consumePendingResult();
        RewardCelebrationScreen.show(
          context,
          reward: pending.reward,
          earned: pending.earned,
          max: n.weeklyMax,
          eyebrow: 'LAST WEEK',
          headline: 'You earned 🎉',
          claimLabel: 'Nice!',
        );
      });
    }
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Token System',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Configure',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TokenConfigScreen()),
            ),
          ),
        ],
      ),
      body: n.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              children: [
                _WeeklySummaryCard(
                  earned: n.weeklyEarned,
                  max: n.weeklyMax,
                  goal: n.weeklyGoal,
                  toGo: n.toGo,
                  unlocked: n.rewardUnlocked,
                  goalReached: n.goalReached,
                  belowMinCount: n.tasksBelowMin.length,
                ),
                const SizedBox(height: 16),
                if (n.isTiered)
                  _TierProgressCard(
                    tiers: n.rewardTiers,
                    earned: n.weeklyEarned,
                    earnedTier: n.earnedTier,
                    nextTier: n.nextTier,
                    tokensToNext: n.tokensToNext,
                    belowMinCount: n.tasksBelowMin.length,
                    isConsumed: n.isTierConsumed,
                  )
                else
                  GestureDetector(
                    onTap: (n.rewardUnlocked || n.rewardClaimed)
                        ? () => _showCelebration(context)
                        : null,
                    child: _RewardCard(
                      reward: n.reward,
                      unlocked: n.rewardUnlocked,
                      claimed: n.rewardClaimed,
                    ),
                  ),
                const SizedBox(height: 28),
                _SectionHeader(
                  label: 'TODAY · ${n.todayLabel}',
                  trailing: '${n.todayDoneCount}/${n.template.tasks.length}',
                ),
                const SizedBox(height: 12),
                _TaskList(
                  tasks: n.template.tasks,
                  isDone: n.isDoneToday,
                  weekCount: n.weekCount,
                  maxFor: n.maxFor,
                  minFor: n.minFor,
                  isBlocked: n.isBlockedToday,
                  onToggle: (id) => _toggle(context, id),
                ),
              ],
            ),
    );
  }
}

// ── Shared uppercase label style ─────────────────────────────────────────────
const TextStyle _labelStyle = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.4,
);

// ── Weekly summary — the hero card ───────────────────────────────────────────
class _WeeklySummaryCard extends StatelessWidget {
  final int earned;
  final int max;
  final int goal;
  final int toGo;
  final bool unlocked;
  final bool goalReached;
  final int belowMinCount;

  const _WeeklySummaryCard({
    required this.earned,
    required this.max,
    required this.goal,
    required this.toGo,
    required this.unlocked,
    required this.goalReached,
    required this.belowMinCount,
  });

  // The token goal is met but some task hasn't hit its weekly minimum, so the
  // reward stays locked until those tasks are finished.
  bool get _blockedByMin => goalReached && !unlocked && belowMinCount > 0;

  String get _statusText {
    if (unlocked) return 'Reward unlocked! 🎉';
    if (_blockedByMin) {
      return belowMinCount == 1
          ? '1 task left to finish 🔒'
          : '$belowMinCount tasks left to finish 🔒';
    }
    return '$toGo to go 🎁';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = goal > 0 ? (earned / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THIS WEEK', style: _labelStyle),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$earned',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ $max tokens',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: AppColors.surfaceContainerLow,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal $goal',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _statusText,
                style: TextStyle(
                  color: unlocked
                      ? AppColors.primary
                      : (_blockedByMin
                            ? AppColors.textSecondary
                            : AppColors.textPrimary),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reward card — locked until the weekly goal is reached ────────────────────
class _RewardCard extends StatelessWidget {
  final String reward;
  final bool unlocked;
  final bool claimed;

  const _RewardCard({
    required this.reward,
    required this.unlocked,
    required this.claimed,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = unlocked || claimed;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accentLight
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: highlight
            ? Border.all(color: AppColors.primaryFixedDim, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.primary
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              claimed
                  ? Icons.check_rounded
                  : (unlocked
                        ? Icons.celebration_rounded
                        : Icons.card_giftcard_rounded),
              color: highlight
                  ? AppColors.surfaceContainerLowest
                  : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claimed ? 'REWARD CLAIMED' : 'YOUR REWARD',
                  style: _labelStyle,
                ),
                const SizedBox(height: 3),
                Text(
                  reward,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            claimed
                ? Icons.check_circle_rounded
                : (unlocked ? Icons.lock_open_rounded : Icons.lock_rounded),
            color: highlight ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Reward ladder (tiered mode) — a live view of what's earned + what's next ──
class _TierProgressCard extends StatelessWidget {
  final List<RewardTier> tiers;
  final int earned;
  final RewardTier? earnedTier;
  final RewardTier? nextTier;
  final int tokensToNext;
  final int belowMinCount;
  final bool Function(RewardTier) isConsumed;

  const _TierProgressCard({
    required this.tiers,
    required this.earned,
    required this.earnedTier,
    required this.nextTier,
    required this.tokensToNext,
    required this.belowMinCount,
    required this.isConsumed,
  });

  // The reward is gated: enough tokens for a tier, but a task is under its min.
  bool get _gatedByMin =>
      earnedTier == null &&
      tiers.isNotEmpty &&
      earned >= tiers.first.threshold &&
      belowMinCount > 0;

  String get _footer {
    if (_gatedByMin) {
      final n = belowMinCount;
      return n == 1
          ? 'Finish 1 task’s minimum to unlock 🔒'
          : 'Finish $n tasks’ minimums to unlock 🔒';
    }
    if (nextTier != null) {
      final unit = tokensToNext == 1 ? 'token' : 'tokens';
      return '$tokensToNext more $unit → ${nextTier!.reward}';
    }
    return 'Top tier reached — granted at week’s end 🎉';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('REWARD TIERS', style: _labelStyle),
              const Spacer(),
              Text(
                'best by week’s end',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < tiers.length; i++) _tierRow(tiers[i]),
          const SizedBox(height: 6),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.surfaceContainerLow,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _gatedByMin
                    ? Icons.lock_rounded
                    : (nextTier != null
                          ? Icons.trending_up_rounded
                          : Icons.emoji_events_rounded),
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _footer,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tierRow(RewardTier t) {
    final consumed = isConsumed(t);
    // A consumed one-time tier is never "reached" (it grants nothing now).
    final reached = !consumed && earnedTier != null && earned >= t.threshold;
    final isBest = earnedTier != null && t.threshold == earnedTier!.threshold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: reached ? AppColors.primary : AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              consumed
                  ? Icons.redeem_rounded
                  : (reached
                        ? (isBest
                              ? Icons.emoji_events_rounded
                              : Icons.check_rounded)
                        : Icons.lock_outline_rounded),
              size: 16,
              color: reached
                  ? AppColors.surfaceContainerLowest
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.reward,
              style: TextStyle(
                color: reached ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                decoration: consumed ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (consumed)
            _tierTag('ONE-TIME ✓')
          else if (isBest)
            _tierTag('NOW')
          else
            Text(
              '${t.threshold}',
              style: TextStyle(
                color: reached ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tierTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    ),
  );
}

// ── Section header with a trailing counter ───────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final String trailing;

  const _SectionHeader({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _labelStyle),
        Text(
          trailing,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Task list — one grouping card, tap a row to earn/undo a token ───────────
class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final bool Function(String id) isDone;
  final int Function(String id) weekCount;
  final int Function(String id) maxFor;
  final int Function(String id) minFor;
  final bool Function(String id) isBlocked;
  final void Function(String id) onToggle;

  const _TaskList({
    required this.tasks,
    required this.isDone,
    required this.weekCount,
    required this.maxFor,
    required this.minFor,
    required this.isBlocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < tasks.length; i++) ...[
            _TaskRow(
              name: tasks[i].name,
              done: isDone(tasks[i].id),
              count: weekCount(tasks[i].id),
              max: maxFor(tasks[i].id),
              min: minFor(tasks[i].id),
              blocked: isBlocked(tasks[i].id),
              onTap: () => onToggle(tasks[i].id),
            ),
            if (i != tasks.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 60,
                color: AppColors.surfaceContainerLow,
              ),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String name;
  final bool done;
  final int count; // completions this week
  final int max; // weekly cap
  final int min; // weekly minimum for the reward
  final bool blocked; // hit the weekly cap → can't complete today
  final VoidCallback onTap;

  const _TaskRow({
    required this.name,
    required this.done,
    required this.count,
    required this.max,
    required this.min,
    required this.blocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final minMet = count >= min;
    return InkWell(
      // A capped-out task can't be toggled today (but a done one always can, to
      // undo it). onTap stays null only when blocked.
      onTap: blocked ? null : onTap,
      child: Opacity(
        opacity: blocked ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: done
                      ? null
                      : Border.all(color: AppColors.outlineVariant, width: 2),
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.surfaceContainerLowest,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: done
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ),
              _WeekBadge(count: count, max: max, minMet: minMet, blocked: blocked),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trailing per-task weekly progress: "count/max" this week, plus a hint of
/// whether the task still needs completions to meet its minimum or is capped.
class _WeekBadge extends StatelessWidget {
  final int count;
  final int max;
  final bool minMet;
  final bool blocked;

  const _WeekBadge({
    required this.count,
    required this.max,
    required this.minMet,
    required this.blocked,
  });

  @override
  Widget build(BuildContext context) {
    final color = blocked
        ? AppColors.textSecondary
        : (minMet ? AppColors.primary : AppColors.textSecondary);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (blocked) ...[
          const Icon(Icons.lock_rounded, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
        ] else if (!minMet) ...[
          const Icon(
            Icons.priority_high_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 2),
        ],
        Text(
          '$count/$max',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          'wk',
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
