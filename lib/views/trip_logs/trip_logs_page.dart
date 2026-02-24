import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/auth/authentication_bloc.dart';
import '../../../core/blocs/trip_log/trip_log_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/trip.dart';
import '../../../core/data/models/trip_log.dart';
import 'trip_log_detail_page.dart';
import 'trip_log_form_page.dart';

/// Página que muestra la línea de tiempo de logs de un viaje.
class TripLogsPage extends StatelessWidget {
  const TripLogsPage({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripLogBloc()..add(TripLogLoadRequested(tripId: trip.id)),
      child: _TripLogsView(trip: trip),
    );
  }
}

class _TripLogsView extends StatelessWidget {
  const _TripLogsView({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora del Viaje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<TripLogBloc>().add(
                TripLogLoadRequested(tripId: trip.id),
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
      body: BlocConsumer<TripLogBloc, TripLogState>(
        listener: (context, state) {
          if (state.status == TripLogStateStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == TripLogStateStatus.failure &&
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
          if (state.status == TripLogStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.logs.isEmpty &&
              state.status != TripLogStateStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timeline_outlined,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay eventos registrados',
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registra el primer evento del viaje.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildTimeline(context, state.logs);
        },
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<TripLog> logs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.paddingSmall,
      ),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isFirst = index == 0;
        final isLast = index == logs.length - 1;
        return _TripLogTimelineItem(
          log: log,
          isFirst: isFirst,
          isLast: isLast,
          onTap: () => _navigateToDetail(context, log),
          onDelete: () => _confirmDelete(context, log),
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, {TripLog? log}) {
    final bloc = context.read<TripLogBloc>();
    final authState = context.read<AuthenticationBloc>().state;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: TripLogFormPage(
            tripId: trip.id,
            tripLog: log,
            currentUserId: authState.user.id,
            currentUserRole: authState.user.role,
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, TripLog log) {
    final bloc = context.read<TripLogBloc>();
    final authState = context.read<AuthenticationBloc>().state;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: TripLogDetailPage(
            tripLog: log,
            tripId: trip.id,
            currentUserId: authState.user.id,
            currentUserRole: authState.user.role,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TripLog log) {
    final bloc = context.read<TripLogBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: Text('¿Deseas eliminar el evento "${log.eventType.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(TripLogDeleteRequested(log.id));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Item de la línea de tiempo con indicador lateral.
class _TripLogTimelineItem extends StatelessWidget {
  const _TripLogTimelineItem({
    required this.log,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onDelete,
  });

  final TripLog log;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color get _eventColor => switch (log.eventType) {
    TripLogEventType.incident => AppColors.error,
    TripLogEventType.delay => AppColors.warning,
    TripLogEventType.completed => AppColors.success,
    TripLogEventType.cancelled => AppColors.error,
    _ => AppColors.primaryAccent,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicador de línea de tiempo
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.grey.withAlpha(64),
                    ),
                  ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _eventColor,
                    border: Border.all(
                      color: _eventColor.withAlpha(128),
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.grey.withAlpha(64),
                    ),
                  ),
              ],
            ),
          ),
          // Card del evento
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              log.displayName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _eventColor,
                              ),
                            ),
                            const Spacer(),
                            if (log.media.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.photo_library_outlined,
                                  size: 16,
                                  color: AppColors.grey.withAlpha(179),
                                ),
                              ),
                            if (log.hasLocation)
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.grey.withAlpha(179),
                              ),
                            PopupMenuButton<String>(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Eliminar',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') onDelete();
                              },
                              icon: Icon(
                                Icons.more_vert,
                                size: 18,
                                color: AppColors.grey.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                        if (log.description != null &&
                            log.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            log.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (log.user != null)
                              _InfoChip(
                                icon: Icons.person_outline,
                                text: log.user!.name,
                              ),
                            if (log.driver != null)
                              _InfoChip(
                                icon: Icons.local_shipping_outlined,
                                text: log.driver!.name,
                              ),
                            const Spacer(),
                            if (log.createdAt != null)
                              Text(
                                _formatTime(log.createdAt!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey.withAlpha(179),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey.withAlpha(179)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }
}
