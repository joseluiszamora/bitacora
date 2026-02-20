import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

/// Pantalla de perfil de usuario.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              const SizedBox(height: AppDefaults.marginMedium),
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.gold,
                child: Icon(Icons.person, size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: AppDefaults.margin),
              const Text(
                'Nombre del Usuario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'usuario@correo.com',
                style: TextStyle(fontSize: 14, color: AppColors.grey),
              ),
              const SizedBox(height: AppDefaults.marginBig),
              _buildProfileOption(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () {
                  // TODO: Navegar a configuración
                },
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Ayuda',
                onTap: () {
                  // TODO: Navegar a ayuda
                },
              ),
              _buildProfileOption(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                onTap: () {
                  // TODO: Dispatch AuthenticationLogoutRequested
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? AppColors.error : null),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
