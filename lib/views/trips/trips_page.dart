import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/auth/authentication_bloc.dart';
import '../../../core/blocs/trip/trip_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/trip.dart';
import '../../../core/data/models/user_role.dart';
import 'trip_detail_page.dart';
import 'trip_form_page.dart';

/// Página de listado de viajes — CRUD para super_admin y admin.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final user = authState.user;
    final companyId = user.role == UserRole.superAdmin ? null : user.company.id;

    return BlocProvider(
      create: (_) => TripBloc()..add(TripLoadRequested(companyId: companyId)),
      child: _TripsView(companyId: companyId),
    );
  }
}

class _TripsView extends StatelessWidget {
  const _TripsView({this.companyId});

  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<TripBloc>().add(
                TripLoadRequested(companyId: companyId),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state.status == TripStateStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == TripStateStatus.failure &&
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
          if (state.status == TripStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.trips.isEmpty && state.status != TripStateStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay viajes registrados',
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
              context.read<TripBloc>().add(
                TripLoadRequested(companyId: companyId),
              );
              await context.read<TripBloc>().stream.firstWhere(
                (s) => s.status != TripStateStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.trips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final trip = state.trips[index];
                return _TripCard(
                  trip: trip,
                  onTap: () => _navigateToDetail(context, trip),
                  onEdit: () => _navigateToForm(context, trip: trip),
                  onDelete: () => _confirmDelete(context, trip),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Trip? trip}) {
    final bloc = context.read<TripBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: TripFormPage(trip: trip),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Trip trip) {
    final bloc = context.read<TripBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: TripDetailPage(trip: trip),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Trip trip) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Viaje'),
        content: Text(
          '¿Estás seguro de eliminar el viaje '
          '"${trip.originLocation?.name ?? trip.originLocationId} → '
          '${trip.destinationLocation?.name ?? trip.destinationLocationId}"?\n\n'
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
              context.read<TripBloc>().add(TripDeleteRequested(trip.id));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de viaje.
class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (trip.status) {
      TripStatus.pending => AppColors.warning,
      TripStatus.inProgress => AppColors.primaryAccent,
      TripStatus.completed => AppColors.success,
      TripStatus.cancelled => AppColors.error,
    };

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
              // Fila superior: ruta + estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.route, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.originLocation?.name ?? trip.originLocationId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 14,
                              color: AppColors.grey.withAlpha(128),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.destinationLocation?.name ??
                                    trip.destinationLocationId,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                      trip.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.grey),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
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
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fila inferior: conductor, vehículo, precio
              Row(
                children: [
                  if (trip.vehicle != null) ...[
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: AppColors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.vehicle!.plateNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey.withAlpha(179),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Spacer(),
                  if (trip.price != null)
                    Text(
                      'Bs ${trip.price!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
