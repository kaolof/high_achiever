import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FichasScreen extends StatelessWidget {
  const FichasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.more_vert, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              'Token system',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
