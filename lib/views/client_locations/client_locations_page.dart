import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/client_location/client_location_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/client_location.dart';
import '../../core/data/models/user_role.dart';
import 'client_location_detail_page.dart';
import 'client_location_form_page.dart';

/// Página de listado de ubicaciones de clientes.
class ClientLocationsPage extends StatelessWidget {
  const ClientLocationsPage({super.key, this.clientCompanyId});

  /// Si viene un ID, solo muestra ubicaciones de esa empresa cliente.
  final String? clientCompanyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientLocationBloc()
        ..add(ClientLocationLoadRequested(clientCompanyId: clientCompanyId)),
      child: _LocationsView(clientCompanyId: clientCompanyId),
    );
  }
}

class _LocationsView extends StatelessWidget {
  const _LocationsView({this.clientCompanyId});

  final String? clientCompanyId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final canEdit =
        authState.user.role == UserRole.superAdmin ||
        authState.user.role == UserRole.admin ||
        authState.user.role == UserRole.clientAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<ClientLocationBloc>().add(
                ClientLocationLoadRequested(clientCompanyId: clientCompanyId),
              );
            },
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _navigateToForm(context),
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : null,
      body: BlocConsumer<ClientLocationBloc, ClientLocationState>(
        listener: (context, state) {
          if (state.status == ClientLocationBlocStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == ClientLocationBlocStatus.failure &&
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
          if (state.status == ClientLocationBlocStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.locations.isEmpty &&
              state.status != ClientLocationBlocStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay ubicaciones registradas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca el botón + para agregar una ubicación.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ClientLocationBloc>().add(
                ClientLocationLoadRequested(clientCompanyId: clientCompanyId),
              );
              await context.read<ClientLocationBloc>().stream.firstWhere(
                (s) => s.status != ClientLocationBlocStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.locations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final location = state.locations[index];
                return _LocationCard(
                  location: location,
                  onTap: () => _navigateToDetail(context, location),
                  onDelete: canEdit
                      ? () => _confirmDelete(context, location)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {ClientLocation? location}) {
    final bloc = context.read<ClientLocationBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ClientLocationFormPage(
            location: location,
            clientCompanyId: clientCompanyId,
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, ClientLocation location) {
    final bloc = context.read<ClientLocationBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ClientLocationDetailPage(location: location),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ClientLocation location) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Ubicación'),
        content: Text(
          '¿Estás seguro de eliminar "${location.name}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ClientLocationBloc>().add(
                ClientLocationDeleteRequested(location.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de ubicación.
class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.onTap,
    this.onDelete,
  });

  final ClientLocation location;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isActive = location.status == ClientLocationStatus.active;
    final statusColor = isActive ? AppColors.success : AppColors.grey;

    IconData typeIcon;
    switch (location.type) {
      case ClientLocationType.warehouse:
        typeIcon = Icons.warehouse;
      case ClientLocationType.distributionCenter:
        typeIcon = Icons.local_shipping;
      case ClientLocationType.office:
        typeIcon = Icons.business;
      case ClientLocationType.plant:
        typeIcon = Icons.factory;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          location.type.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Estado badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      location.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.grey),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            title: Text(
                              'Eliminar',
                              style: TextStyle(color: AppColors.error),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') onDelete!();
                      },
                    ),
                ],
              ),
              // Dirección y ciudad
              if (location.address != null || location.city != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        [
                          if (location.address != null) location.address,
                          if (location.city != null) location.city!.displayName,
                        ].join(' — '),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withAlpha(179),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              // Empresa cliente
              if (location.clientCompany != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 14,
                      color: AppColors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location.clientCompany!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
