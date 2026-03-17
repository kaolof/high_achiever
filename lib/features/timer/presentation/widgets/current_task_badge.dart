import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CurrentTaskBadge extends StatelessWidget {
  final String taskName;

  const CurrentTaskBadge({super.key, required this.taskName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Current Task',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          taskName,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
