import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surface hierarchy — "stack of fine paper"
  static const Color surface = Color(0xFFF8FAF9);              // Base background
  static const Color surfaceContainerLow = Color(0xFFF2F4F3);  // Layer 1: grouping
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Layer 2: cards

  // Primary palette
  static const Color primary = Color(0xFF006E26);
  static const Color primaryContainer = Color(0xFF50E36B);
  static const Color primaryFixedDim = Color(0xFF4EE16A);      // success / progress bars

  // On-colors
  static const Color onSecondaryFixed = Color(0xFF171B26);     // timer text
  static const Color onSurfaceVariant = Color(0xFF5A5E6A);     // labels / secondary text

  // Secondary
  static const Color secondary = Color(0xFF5A5E6A);

  // Outline
  static const Color outlineVariant = Color(0xFFBCCBB8);

  // Error / destructive feedback
  static const Color error = Color(0xFFB3261E);

  // Legacy aliases used across widgets (kept for compat while migrating)
  static const Color background = surface;
  static const Color accent = primaryContainer;
  static const Color accentLight = Color(0xFFDFF7E4);
  static const Color textPrimary = onSecondaryFixed;
  static const Color textSecondary = secondary;
  static const Color navBackground = surface;

  // Gradient for primary action buttons / active timer
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
