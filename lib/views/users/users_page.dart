import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/user_management/user_management_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/user.dart';
import '../../core/data/models/user_role.dart';
import 'user_form_page.dart';

/// Página de administración de usuarios.
///
/// Accesible para `super_admin` y `admin`.
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final currentUser = authState.user;

    return BlocProvider(
      create: (_) => UserManagementBloc(
        currentRole: currentUser.role,
        currentCompanyId: currentUser.company.id,
      )..add(const UserManagementLoadRequested()),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<UserManagementBloc>().add(
                const UserManagementLoadRequested(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.person_add, color: AppColors.white),
      ),
      body: BlocConsumer<UserManagementBloc, UserManagementState>(
        listener: (context, state) {
          if (state.status == UserManagementStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == UserManagementStatus.failure &&
              state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.status == UserManagementStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.users.isEmpty &&
              state.status != UserManagementStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay usuarios registrados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca el botón + para agregar el primero.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserManagementBloc>().add(
                const UserManagementLoadRequested(),
              );
              await context.read<UserManagementBloc>().stream.firstWhere(
                (s) => s.status != UserManagementStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return _UserCard(
                  user: user,
                  onEdit: () => _navigateToForm(context, user: user),
                  onToggleActive: () => _confirmToggleActive(context, user),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {User? user}) {
    final bloc = context.read<UserManagementBloc>();
    final authState = context.read<AuthenticationBloc>().state;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: UserFormPage(
            user: user,
            currentUserRole: authState.user.role,
            currentUserCompanyId: authState.user.company.id,
          ),
        ),
      ),
    );
  }

  void _confirmToggleActive(BuildContext context, User user) {
    final action = user.isActive ? 'desactivar' : 'activar';
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${user.isActive ? "Desactivar" : "Activar"} Usuario'),
        content: Text(
          '¿Estás seguro de $action a "${user.name}"?\n\n'
          '${user.isActive ? "El usuario no podrá acceder al sistema." : "El usuario podrá acceder nuevamente."}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: user.isActive
                  ? AppColors.error
                  : AppColors.success,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserManagementBloc>().add(
                UserManagementToggleActiveRequested(
                  userId: user.id,
                  isActive: !user.isActive,
                ),
              );
            },
            child: Text(user.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de usuario
// ─────────────────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggleActive,
  });

  final User user;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: _roleColor(user.role).withAlpha(38),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Icon(Icons.person, color: _roleColor(user.role), size: 22)
                    : null,
              ),
              const SizedBox(width: 12),

              // Datos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'Sin nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: user.isActive
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email.isNotEmpty ? user.email : 'Sin email',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    if (user.company.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          user.company.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey.withAlpha(179),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Badge de rol
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _roleColor(user.role).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.shortLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _roleColor(user.role),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Badge activo/inactivo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (user.isActive ? AppColors.success : AppColors.error)
                              .withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: user.isActive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),

              // Botón activar/desactivar
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  user.isActive
                      ? Icons.person_off_outlined
                      : Icons.person_outline,
                  color: (user.isActive ? AppColors.error : AppColors.success)
                      .withAlpha(179),
                  size: 20,
                ),
                tooltip: user.isActive ? 'Desactivar' : 'Activar',
                onPressed: onToggleActive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Color por rol para el badge/avatar.
  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => AppColors.error,
      UserRole.admin => AppColors.primaryAccent,
      UserRole.supervisor => AppColors.gold,
      UserRole.driver => AppColors.success,
      UserRole.finance => AppColors.warning,
    };
  }
}
