import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/config.dart';

/// Pantalla de splash al iniciar la app.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 80, color: AppColors.gold),
            SizedBox(height: 24),
            Text(
              Config.appName,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
