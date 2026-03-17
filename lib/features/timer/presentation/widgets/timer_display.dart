import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final int minutes;
  final int seconds;

  const TimerDisplay({
    super.key,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final String timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      timeText,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 96,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1,
      ),
    );
  }
}
