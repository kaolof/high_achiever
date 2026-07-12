import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_notifier.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
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

  Future<void> _confirmResetSession(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset session?',
      message:
          'This will reset your completed pomodoros to 0 and stop the current timer.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<TimerNotifier>().resetSession();
    }
  }

  void _onTimerChanged() {
    if (!mounted) return;
    if (_timer.justCompleted) {
      final justStartedBreak = _timer.isBreak;
      ScaffoldMessenger.of(context).showSnackBar(
        appSnackBar(
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
              } else if (value == 'set_goal') {
                showDailyGoalSheet(context);
              } else if (value == 'reset_session') {
                _confirmResetSession(context);
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
              const PopupMenuItem<String>(
                value: 'set_goal',
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Set daily goal',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'reset_session',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded,
                        color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Reset session',
                      style: TextStyle(
                        color: Colors.red,
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
            const SizedBox(height: 32),
            // ── Progress bar ───────────────────────────────────────────────
            Selector<TimerNotifier, (int, int)>(
              selector: (_, t) => (t.completedToday, t.dailyGoal),
              builder: (_, stats, __) => _ProgressBar(
                completed: stats.$1,
                total: stats.$2,
              ),
            ),
            const SizedBox(height: 20),
            // ── Motivational quote ─────────────────────────────────────────
            const _QuoteCard(),
            const SizedBox(height: 24),
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

// ── Progress bar ───────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Text(
              '$completed/$total Sessions Today',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerLow,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
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

// ── Motivational quote card ────────────────────────────────────────────────
const _quotes = [
  ("'Focus is a superpower.'", 'NAVAL RAVIKANT'),
  ("'The secret of getting ahead is getting started.'", 'MARK TWAIN'),
  ("'Discipline is choosing what you want most.'", 'ABRAHAM LINCOLN'),
  ("'Improvement is better than delayed perfection.'", 'MARK TWAIN'),
  ("'Do only one thing at once.'", 'SAMUEL SMILES'),
  ("'Consistency trumps intensity.'", 'BRUCE LEE'),
  ("'Done is better than perfect.'", 'SHERYL SANDBERG'),
  ("'Your focus determines your reality.'", 'GEORGE LUCAS'),
];

class _QuoteCard extends StatefulWidget {
  const _QuoteCard();

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  late final ({String quote, String source}) _entry;

  @override
  void initState() {
    super.initState();
    final r = Random();
    final pick = _quotes[r.nextInt(_quotes.length)];
    _entry = (quote: pick.$1, source: pick.$2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u201C',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _entry.quote,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 28,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                _entry.source,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
