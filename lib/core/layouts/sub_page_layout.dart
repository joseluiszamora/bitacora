import 'package:flutter/material.dart';

import '../constants/app_defaults.dart';

/// Layout base para sub-páginas con AppBar y botón de retroceso.
class SubPageLayout extends StatelessWidget {
  const SubPageLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
