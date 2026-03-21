import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      style: GoogleFonts.spaceGrotesk(
        color: AppColors.onSecondaryFixed,
        fontSize: 96,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1,
      ),
    );
  }
}
