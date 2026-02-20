import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

/// Pantalla principal de la app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BITACORA')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDefaults.marginMedium),
              _buildQuickActionCard(
                icon: Icons.add_circle_outline,
                title: 'Nueva Bitácora',
                subtitle: 'Registrar un nuevo viaje',
                onTap: () {
                  // TODO: Navegar a nueva bitácora
                },
              ),
              const SizedBox(height: AppDefaults.margin),
              _buildQuickActionCard(
                icon: Icons.list_alt,
                title: 'Mis Bitácoras',
                subtitle: 'Ver historial de viajes',
                onTap: () {
                  // TODO: Navegar a lista de bitácoras
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.cardPadding,
          vertical: 8,
        ),
      ),
    );
  }
}
