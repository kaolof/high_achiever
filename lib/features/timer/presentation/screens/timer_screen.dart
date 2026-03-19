import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/timer_notifier.dart';
import '../widgets/current_task_badge.dart';
import '../widgets/timer_display.dart';
import '../widgets/session_stats.dart';
import '../widgets/daily_goal_sheet.dart';
import 'fullscreen_timer_screen.dart';

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
      // isBreak ya cambió a la nueva fase, así que chequeamos la fase actual
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
                justStartedBreak ? 'Pomodoro completado!' : 'Break terminado!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmResetSession(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset session?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'This will reset your completed pomodoros to 0 and stop the current timer.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<TimerNotifier>().resetSession();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 24,
        title: const Text(
          'Focus',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmResetSession(context),
            icon: const Icon(
              Icons.restart_alt_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            tooltip: 'Reset session',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => FullscreenTimerScreen.show(context),
              child: const Icon(
                Icons.fullscreen_rounded,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Selector<TimerNotifier, bool>(
              selector: (_, t) => t.isBreak,
              builder: (_, isBreak, __) => CurrentTaskBadge(
                taskName: isBreak ? 'Break' : TimerNotifier.defaultTaskName,
              ),
            ),
            const SizedBox(height: 24),
            Selector<TimerNotifier, (int, int)>(
              selector: (_, t) => (t.minutes, t.seconds),
              builder: (_, time, __) =>
                  TimerDisplay(minutes: time.$1, seconds: time.$2),
            ),
            const Spacer(flex: 2),
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
                    const SizedBox(height: 12),
                    _SkipBreakButton(
                      onTap: () => context.read<TimerNotifier>().skipBreak(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            Selector<TimerNotifier, (int, int)>(
              selector: (_, t) => (t.completedToday, t.dailyGoal),
              builder: (_, stats, __) => SessionStats(
                completedSessions: stats.$1,
                totalSessions: stats.$2,
              ),
            ),
            const Spacer(flex: 3),
            _SetDailyGoalButton(
              onTap: () => showDailyGoalSheet(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SetDailyGoalButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SetDailyGoalButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.track_changes_rounded,
              color: AppColors.accent,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'SET DAILY GOAL',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SkipBreakButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipBreakButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.skip_next_rounded, color: AppColors.textSecondary, size: 18),
            SizedBox(width: 8),
            Text(
              'SKIP BREAK',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final bool isRunning;
  final bool isBreak;
  final VoidCallback onTap;

  const _StartButton({
    required this.isRunning,
    required this.isBreak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              color: AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isRunning
                  ? (isBreak ? 'Pause Break' : 'Pause Session')
                  : (isBreak ? 'Start Break' : 'Start Session'),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
