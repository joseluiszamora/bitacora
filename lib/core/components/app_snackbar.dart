import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';

/// Snackbar reutilizable para mostrar mensajes al usuario.
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDefaults.radiusSmall),
          ),
          duration: duration,
        ),
      );
  }
}
