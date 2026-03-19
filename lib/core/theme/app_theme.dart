import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    // Space Grotesk — brutalist display voice
    final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.onSecondaryFixed,
        letterSpacing: -2,
        height: 1,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.onSecondaryFixed,
      ),
    );

    // Manrope — humanist body voice
    final manropeBase = GoogleFonts.manropeTextTheme();

    final textTheme = manropeBase.merge(spaceGrotesk);

    return ThemeData(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSecondaryFixed,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: textTheme,
      useMaterial3: true,
    );
  }
}
