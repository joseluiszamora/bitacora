import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/my_trips/my_trips_bloc.dart';
import '../../core/blocs/service_locator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/trip.dart';
import '../trip_logs/trip_logs_page.dart';

/// Página "Mis Viajes".
///
/// - Driver: ve los viajes asignados a sus vehículos.
/// - Admin/Supervisor: ve los viajes de su empresa.
class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final user = authState.user;

    return BlocProvider(
      create: (_) => getIt<MyTripsBloc>()
        ..add(
          MyTripsLoadRequested(
            userId: user.id,
            role: user.role,
            companyId: user.company.id,
          ),
        ),
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatelessWidget {
  const _MyTripsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Viajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              final authState = context.read<AuthenticationBloc>().state;
              final user = authState.user;
              context.read<MyTripsBloc>().add(
                MyTripsLoadRequested(
                  userId: user.id,
                  role: user.role,
                  companyId: user.company.id,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MyTripsBloc, MyTripsState>(
        builder: (context, state) {
          if (state.status == MyTripsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MyTripsStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage.isNotEmpty
                          ? state.errorMessage
                          : 'Error al cargar los viajes',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        final authState = context
                            .read<AuthenticationBloc>()
                            .state;
                        final user = authState.user;
                        context.read<MyTripsBloc>().add(
                          MyTripsLoadRequested(
                            userId: user.id,
                            role: user.role,
                            companyId: user.company.id,
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.trips.isEmpty) {
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
                      'No tienes viajes asignados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Los viajes asignados aparecerán aquí.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthenticationBloc>().state;
              final user = authState.user;
              context.read<MyTripsBloc>().add(
                MyTripsLoadRequested(
                  userId: user.id,
                  role: user.role,
                  companyId: user.company.id,
                ),
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.trips.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDefaults.margin),
              itemBuilder: (context, index) {
                final trip = state.trips[index];
                return _TripCard(
                  trip: trip,
                  onTap: () => _navigateToDetail(context, trip),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _MyTripDetailPage(trip: trip)),
    );
  }
}

// ─── Card de viaje ───────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: ruta + estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.route, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.originLocation?.name ?? 'Origen',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColors.grey.withAlpha(128),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.destinationLocation?.name ?? 'Destino',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey.withAlpha(179),
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
                  const SizedBox(width: 8),
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withAlpha(128)),
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
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Info adicional
              Row(
                children: [
                  if (trip.vehicle != null) ...[
                    Icon(
                      Icons.local_shipping,
                      size: 14,
                      color: AppColors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip.vehicle!.plateNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withAlpha(179),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (trip.clientCompany != null) ...[
                    Icon(
                      Icons.storefront,
                      size: 14,
                      color: AppColors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip.clientCompany!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withAlpha(179),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              if (trip.departureTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(trip.departureTime!),
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Detalle de viaje (vista simplificada para drivers) ──────────────────────

class _MyTripDetailPage extends StatelessWidget {
  const _MyTripDetailPage({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (trip.status) {
      TripStatus.pending => AppColors.warning,
      TripStatus.inProgress => AppColors.primaryAccent,
      TripStatus.completed => AppColors.success,
      TripStatus.cancelled => AppColors.error,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Viaje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: 'Bitácora',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TripLogsPage(trip: trip),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con ruta y estado
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.route, size: 48, color: statusColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        trip.originLocation?.name ?? trip.originLocationId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.arrow_downward,
                        color: AppColors.grey.withAlpha(128),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.destinationLocation?.name ??
                            trip.destinationLocationId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withAlpha(128)),
                        ),
                        child: Text(
                          trip.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (trip.price != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Bs ${trip.price!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información del viaje
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Viaje',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (trip.clientCompany != null)
                        _InfoRow(
                          label: 'Cliente',
                          value: trip.clientCompany!.name,
                          icon: Icons.storefront,
                        ),
                      if (trip.vehicle != null)
                        _InfoRow(
                          label: 'Vehículo',
                          value:
                              '${trip.vehicle!.plateNumber} — ${trip.vehicle!.displayName}',
                          icon: Icons.local_shipping,
                        ),
                      _InfoRow(
                        label: 'Salida',
                        value: trip.departureTime != null
                            ? _formatDateTime(trip.departureTime!)
                            : 'No definida',
                        icon: Icons.departure_board,
                      ),
                      _InfoRow(
                        label: 'Llegada',
                        value: trip.arrivalTime != null
                            ? _formatDateTime(trip.arrivalTime!)
                            : 'No definida',
                        icon: Icons.access_time_filled,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Acceso a Bitácora
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.primaryAccent.withAlpha(77),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timeline,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  title: const Text(
                    'Bitácora de Eventos',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Ver y registrar eventos del viaje',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TripLogsPage(trip: trip),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Fila informativa reutilizable.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.grey.withAlpha(179)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey.withAlpha(179),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.greyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
