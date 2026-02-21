import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/user_role.dart';
import '../client_companies/client_companies_page.dart';
import '../companies/companies_page.dart';
import '../users/users_page.dart';

/// Pantalla de perfil de usuario.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final user = state.user;

              return Column(
                children: [
                  const SizedBox(height: AppDefaults.marginMedium),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.gold,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: AppDefaults.margin),
                  Text(
                    user.name.isNotEmpty ? user.name : 'Usuario',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Badge de rol
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _roleColor(user.role).withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _roleColor(user.role).withAlpha(128),
                      ),
                    ),
                    child: Text(
                      user.role.shortLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _roleColor(user.role),
                      ),
                    ),
                  ),

                  // Tarjeta de empresa
                  if (user.company.isNotEmpty) ...[
                    const SizedBox(height: AppDefaults.margin),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.grey.withAlpha(51)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.company.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (user.company.nit != null)
                                    Text(
                                      'NIT: ${user.company.nit}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Tarjeta de empresa cliente
                  if (user.clientCompany.isNotEmpty) ...[
                    const SizedBox(height: AppDefaults.margin),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.grey.withAlpha(51)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withAlpha(26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: AppColors.gold,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.clientCompany.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Text(
                                    'Empresa Cliente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  if (user.clientCompany.nit != null)
                                    Text(
                                      'NIT: ${user.clientCompany.nit}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDefaults.marginBig),

                  // Opciones de administración (solo super_admin)
                  if (user.role == UserRole.superAdmin) ...[
                    _buildProfileOption(
                      icon: Icons.business,
                      title: 'Administrar Compañías',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CompaniesPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildProfileOption(
                      icon: Icons.storefront,
                      title: 'Administrar Empresas Cliente',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ClientCompaniesPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],

                  // Administrar usuarios (super_admin, admin, clientAdmin)
                  if (user.role == UserRole.superAdmin ||
                      user.role == UserRole.admin ||
                      user.role == UserRole.clientAdmin) ...[
                    _buildProfileOption(
                      icon: Icons.people,
                      title: 'Administrar Usuarios',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const UsersPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],

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
                    onTap: () => _showLogoutDialog(context),
                    isDestructive: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Color por rol para el badge.
  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => AppColors.error,
      UserRole.admin => AppColors.primaryAccent,
      UserRole.supervisor => AppColors.gold,
      UserRole.driver => AppColors.success,
      UserRole.finance => AppColors.warning,
      UserRole.clientAdmin => AppColors.primaryAccent,
      UserRole.clientUser => AppColors.grey,
    };
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthenticationBloc>().add(
                const AuthenticationLogoutRequested(),
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
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
