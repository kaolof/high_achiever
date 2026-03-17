import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SessionStats extends StatelessWidget {
  final int completedSessions;
  final int totalSessions;
  final int streakDays;

  const SessionStats({
    super.key,
    required this.completedSessions,
    required this.totalSessions,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatItem(label: 'TODAY', value: '$completedSessions/$totalSessions'),
        const SizedBox(width: 40),
        _StatItem(label: 'STREAK', value: '$streakDays Days'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
