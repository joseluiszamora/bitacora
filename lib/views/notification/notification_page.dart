import 'package:flutter/material.dart';

import '../../core/constants/app_defaults.dart';

/// Pantalla de notificaciones.
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDefaults.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No tienes notificaciones',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
