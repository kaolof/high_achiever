import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_notifier.dart';
import '../../domain/timer_notifier.dart';
import '../widgets/timer_display.dart';
import '../widgets/daily_goal_sheet.dart';
import 'fullscreen_timer_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with WidgetsBindingObserver {
  late final TimerNotifier _timer;

  @override
  void initState() {
    super.initState();
    _timer = context.read<TimerNotifier>();
    WidgetsBinding.instance.addObserver(this);
    _timer.addListener(_onTimerChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timer.reconcileAfterBackground();
    }
  }

  void _onTimerChanged() {
    if (!mounted) return;
    if (_timer.justCompleted) {
      final justStartedBreak = _timer.isBreak;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(
                justStartedBreak ? '🍅' : '☕',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Text(
                justStartedBreak ? 'Pomodoro complete!' : 'Break over!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.removeListener(_onTimerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => FullscreenTimerScreen.show(context),
          icon: const Icon(
            Icons.fit_screen_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
          tooltip: 'Fullscreen',
        ),
        centerTitle: true,
        title: const Text(
          'Focus',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppColors.surfaceContainerLowest,
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                enabled: false,
                height: 32,
                child: Text(
                  'MENU',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                enabled: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<AppSettingsNotifier>(
                  builder: (ctx, settings, _) => Row(
                    children: [
                      const Icon(Icons.military_tech_rounded,
                          color: AppColors.textPrimary, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Token system',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: settings.showTokensTab,
                        onChanged: (v) => settings.showTokensTab = v,
                        activeThumbColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // ── Label ──────────────────────────────────────────────────────
            const Text(
              'CURRENT TASK',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // ── Timer ──────────────────────────────────────────────────────
            Selector<TimerNotifier, (int, int)>(
              selector: (_, t) => (t.minutes, t.seconds),
              builder: (_, time, __) =>
                  TimerDisplay(minutes: time.$1, seconds: time.$2),
            ),
            const SizedBox(height: 16),
            // ── Session badge ──────────────────────────────────────────────
            Selector<TimerNotifier, bool>(
              selector: (_, t) => t.isBreak,
              builder: (_, isBreak, __) => _SessionBadge(isBreak: isBreak),
            ),
            const SizedBox(height: 32),
            // ── Progress + Objective cards ─────────────────────────────────
            Selector<TimerNotifier, (int, int)>(
              selector: (_, t) => (t.completedToday, t.dailyGoal),
              builder: (_, stats, __) => IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        completed: stats.$1,
                        total: stats.$2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ObjectiveCard(
                        onTap: () => showDailyGoalSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // ── Action button + skip ───────────────────────────────────────
            Selector<TimerNotifier, (bool, bool)>(
              selector: (_, t) => (t.isRunning, t.isBreak),
              builder: (_, state, __) => Column(
                children: [
                  _StartButton(
                    isRunning: state.$1,
                    isBreak: state.$2,
                    onTap: () => context.read<TimerNotifier>().toggle(),
                  ),
                  if (state.$2) ...[
                    const SizedBox(height: 14),
                    _SkipBreakText(
                      onTap: () => context.read<TimerNotifier>().skipBreak(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ── Session badge — green dot + label pill ─────────────────────────────────
class _SessionBadge extends StatelessWidget {
  final bool isBreak;

  const _SessionBadge({required this.isBreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryFixedDim,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isBreak ? 'Break session' : 'Focus session',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress card ──────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed/$total',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Today's Sessions",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Objective card (Set Daily Goal) ───────────────────────────────────────
class _ObjectiveCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ObjectiveCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OBJECTIVE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set Daily\nGoal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skip Break — plain text link ───────────────────────────────────────────
class _SkipBreakText extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipBreakText({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Text(
        'Skip Break',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Start Button — pill, gradient, AnimatedScale on press ─────────────────
class _StartButton extends StatefulWidget {
  final bool isRunning;
  final bool isBreak;
  final VoidCallback onTap;

  const _StartButton({
    required this.isRunning,
    required this.isBreak,
    required this.onTap,
  });

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isRunning ? Icons.pause : Icons.play_arrow,
                color: AppColors.surfaceContainerLowest,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                widget.isRunning
                    ? (widget.isBreak ? 'Pause Break' : 'Pause Session')
                    : (widget.isBreak ? 'Start Break' : 'Start Session'),
                style: const TextStyle(
                  color: AppColors.surfaceContainerLowest,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
