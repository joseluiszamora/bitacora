import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/trip/trip_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/trip.dart';
import 'trip_form_page.dart';

/// Página de detalle de un viaje.
class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, required this.trip});

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
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () {
              final bloc = context.read<TripBloc>();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: TripFormPage(trip: trip),
                  ),
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
                        trip.origin,
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
                        trip.destination,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Badge de estado
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

              // Datos del viaje
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
                      if (trip.company != null)
                        _DetailRow(
                          label: 'Empresa',
                          value: trip.company!.name,
                          icon: Icons.business,
                        ),
                      if (trip.clientCompany != null)
                        _DetailRow(
                          label: 'Cliente',
                          value: trip.clientCompany!.name,
                          icon: Icons.storefront,
                        ),
                      if (trip.vehicle != null)
                        _DetailRow(
                          label: 'Vehículo',
                          value:
                              '${trip.vehicle!.plateNumber} — ${trip.vehicle!.displayName}',
                          icon: Icons.local_shipping,
                        ),
                      if (trip.assignedBy != null)
                        _DetailRow(
                          label: 'Asignado por',
                          value: trip.assignedBy!.name,
                          icon: Icons.assignment_ind,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horarios
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
                        'Horarios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Salida',
                        value: trip.departureTime != null
                            ? _formatDateTime(trip.departureTime!)
                            : 'No definida',
                        icon: Icons.departure_board,
                      ),
                      _DetailRow(
                        label: 'Llegada',
                        value: trip.arrivalTime != null
                            ? _formatDateTime(trip.arrivalTime!)
                            : 'No definida',
                        icon: Icons.access_time_filled,
                      ),
                      if (trip.createdAt != null)
                        _DetailRow(
                          label: 'Creado',
                          value: _formatDateTime(trip.createdAt!),
                          icon: Icons.calendar_today,
                        ),
                    ],
                  ),
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

/// Fila de detalle con ícono, etiqueta y valor.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
            width: 100,
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
