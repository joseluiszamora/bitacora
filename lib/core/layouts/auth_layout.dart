import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';

/// Layout base para pantallas de autenticación (login, registro).
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: child,
          ),
        ),
      ),
    );
  }
}
