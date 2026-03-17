import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/timer_notifier.dart';

class FullscreenTimerScreen extends StatelessWidget {
  const FullscreenTimerScreen({super.key});

  static Future<void> show(BuildContext context) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (!context.mounted) return;
    try {
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const FullscreenTimerScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } finally {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNotifier>();
    final timeText =
        '${timer.minutes.toString().padLeft(2, '0')}:${timer.seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.fullscreen_exit_rounded,
                  color: Color(0xFF4A5450),
                  size: 30,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    TimerNotifier.defaultTaskName,
                    style: TextStyle(
                      color: Color(0xFF4A5450),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 120,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -4,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () => context.read<TimerNotifier>().toggle(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            timer.isRunning ? Icons.pause : Icons.play_arrow,
                            color: AppColors.accent,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timer.isRunning ? 'Pause' : 'Start',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
