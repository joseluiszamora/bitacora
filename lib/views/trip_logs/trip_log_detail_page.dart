import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/trip_log/trip_log_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/trip_log.dart';
import '../../../core/data/models/trip_log_media.dart';
import '../../../core/data/models/user_role.dart';
import 'trip_log_form_page.dart';

/// Página de detalle de un log de viaje.
class TripLogDetailPage extends StatelessWidget {
  const TripLogDetailPage({
    super.key,
    required this.tripLog,
    required this.tripId,
    required this.currentUserId,
    required this.currentUserRole,
  });

  final TripLog tripLog;
  final String tripId;
  final String currentUserId;
  final UserRole currentUserRole;

  @override
  Widget build(BuildContext context) {
    final eventColor = switch (tripLog.eventType) {
      TripLogEventType.incident => AppColors.error,
      TripLogEventType.delay => AppColors.warning,
      TripLogEventType.completed => AppColors.success,
      TripLogEventType.cancelled => AppColors.error,
      _ => AppColors.primaryAccent,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () {
              final bloc = context.read<TripLogBloc>();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: TripLogFormPage(
                      tripId: tripId,
                      tripLog: tripLog,
                      currentUserId: currentUserId,
                      currentUserRole: currentUserRole,
                    ),
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
              // Cabecera — tipo de evento
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
                          color: eventColor.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          tripLog.eventType.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tripLog.eventType.label,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: eventColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (tripLog.description != null &&
                          tripLog.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          tripLog.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información del evento
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
                        'Información del Evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (tripLog.user != null)
                        _DetailRow(
                          label: 'Registrado por',
                          value: tripLog.user!.name,
                          icon: Icons.person_outline,
                        ),
                      if (tripLog.driver != null)
                        _DetailRow(
                          label: 'Conductor',
                          value: tripLog.driver!.name,
                          icon: Icons.local_shipping_outlined,
                        ),
                      if (tripLog.createdAt != null)
                        _DetailRow(
                          label: 'Fecha / Hora',
                          value: _formatDateTime(tripLog.createdAt!),
                          icon: Icons.access_time,
                        ),
                    ],
                  ),
                ),
              ),

              // Ubicación GPS
              if (tripLog.hasLocation) ...[
                const SizedBox(height: 16),
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
                          'Ubicación GPS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Latitud',
                          value: tripLog.latitude!.toStringAsFixed(6),
                          icon: Icons.my_location,
                        ),
                        _DetailRow(
                          label: 'Longitud',
                          value: tripLog.longitude!.toStringAsFixed(6),
                          icon: Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Media (fotos/videos)
              if (tripLog.media.isNotEmpty) ...[
                const SizedBox(height: 16),
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
                        Text(
                          'Archivos Adjuntos (${tripLog.media.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: tripLog.media.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final media = tripLog.media[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey.withAlpha(26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        media.type == TripLogMediaType.video
                                            ? Icons.videocam
                                            : Icons.photo,
                                        size: 32,
                                        color: AppColors.primaryAccent,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        media.type.label,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      if (media.caption != null) ...[
                                        const SizedBox(height: 2),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            media.caption!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Metadata JSONB
              if (tripLog.metadata != null && tripLog.metadata!.isNotEmpty) ...[
                const SizedBox(height: 16),
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
                          'Datos Adicionales',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...tripLog.metadata!.entries.map((entry) {
                          return _DetailRow(
                            label: entry.key,
                            value: entry.value.toString(),
                            icon: Icons.data_object,
                          );
                        }),
                      ],
                    ),
                  ),
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
