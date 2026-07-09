import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Fase A4 — Reward celebration.
///
/// The emotional peak of the token economy: shown the moment the weekly goal is
/// reached. UI-first, no persistence — later Bloque B triggers it from the real
/// notifier when `tokensEarned` crosses `weeklyGoal`.
class RewardCelebrationScreen extends StatefulWidget {
  final String reward;
  final int earned;
  final int max;
  final VoidCallback? onClaim;

  const RewardCelebrationScreen({
    super.key,
    required this.reward,
    required this.earned,
    required this.max,
    this.onClaim,
  });

  static Future<void> show(
    BuildContext context, {
    required String reward,
    required int earned,
    required int max,
    VoidCallback? onClaim,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => RewardCelebrationScreen(
          reward: reward,
          earned: earned,
          max: max,
          onClaim: onClaim,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<RewardCelebrationScreen> createState() =>
      _RewardCelebrationScreenState();
}

class _RewardCelebrationScreenState extends State<RewardCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _pop;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _pop = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              ScaleTransition(scale: _pop, child: const _Medal()),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const Text(
                      'GOAL REACHED',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Reward\nunlocked! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RewardPill(reward: widget.reward),
                    const SizedBox(height: 18),
                    Text(
                      '${widget.earned} / ${widget.max} tokens this week',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 4),
              FadeTransition(
                opacity: _fade,
                child: _ClaimButton(
                  onTap: () {
                    widget.onClaim?.call();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _fade,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trophy medallion with glow + sparkles ────────────────────────────────────
class _Medal extends StatelessWidget {
  const _Medal();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.45),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.surfaceContainerLowest,
              size: 68,
            ),
          ),
          const Positioned(
            top: 4,
            right: 18,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primaryContainer,
              size: 26,
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 20,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primaryFixedDim,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  final String reward;
  const _RewardPill({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.primaryFixedDim, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            reward,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClaimButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: Offset.zero,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Claim reward',
            style: TextStyle(
              color: AppColors.surfaceContainerLowest,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
