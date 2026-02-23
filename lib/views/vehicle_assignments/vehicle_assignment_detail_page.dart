import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/vehicle_assignment/vehicle_assignment_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/vehicle_assignment.dart';
import 'vehicle_assignment_form_page.dart';

/// Detalle de una asignación vehículo-conductor.
class VehicleAssignmentDetailPage extends StatelessWidget {
  const VehicleAssignmentDetailPage({super.key, required this.assignment});

  final VehicleAssignment assignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Asignación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (assignment.isActive
                                ? AppColors.success
                                : AppColors.grey)
                            .withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (assignment.isActive
                                  ? AppColors.success
                                  : AppColors.grey)
                              .withAlpha(128),
                    ),
                  ),
                  child: Text(
                    assignment.isActive ? 'Activa' : 'Finalizada',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: assignment.isActive
                          ? AppColors.success
                          : AppColors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDefaults.marginMedium),

              // Conductor
              _DetailCard(
                icon: Icons.person,
                title: 'Conductor',
                value: assignment.driver?.name ?? assignment.driverId,
                subtitle: assignment.driver?.email,
              ),
              const SizedBox(height: AppDefaults.margin),

              // Vehículo
              _DetailCard(
                icon: Icons.local_shipping,
                title: 'Vehículo',
                value: assignment.vehicle != null
                    ? '${assignment.vehicle!.plateNumber} — ${assignment.vehicle!.displayName}'
                    : assignment.vehicleId,
                subtitle: assignment.vehicle?.company?.name,
              ),
              const SizedBox(height: AppDefaults.margin),

              // Fecha de inicio
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Inicio',
                value: _formatDate(assignment.startDate),
              ),

              // Fecha de fin
              _DetailRow(
                icon: Icons.event,
                label: 'Finalización',
                value: assignment.endDate != null
                    ? _formatDate(assignment.endDate!)
                    : 'Sin finalizar',
              ),

              // Asignado por
              if (assignment.assignedBy != null)
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Asignado por',
                  value: assignment.assignedBy!.name,
                ),

              // Creado el
              if (assignment.createdAt != null)
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Creado el',
                  value: _formatDateTime(assignment.createdAt!),
                ),

              const SizedBox(height: AppDefaults.marginBig),

              // Botón finalizar
              if (assignment.isActive)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _confirmEnd(context),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Finalizar Asignación'),
                ),
              const SizedBox(height: AppDefaults.margin),

              // Botón eliminar
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar Asignación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    final bloc = context.read<VehicleAssignmentBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: VehicleAssignmentFormPage(assignment: assignment),
        ),
      ),
    );
  }

  void _confirmEnd(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar Asignación'),
        content: const Text(
          '¿Deseas finalizar esta asignación?\n\n'
          'Se registrará la fecha de finalización como hoy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VehicleAssignmentBloc>().add(
                VehicleAssignmentEndRequested(assignment.id),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Asignación'),
        content: const Text(
          '¿Estás seguro de eliminar esta asignación?\n\n'
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
              context.read<VehicleAssignmentBloc>().add(
                VehicleAssignmentDeleteRequested(assignment.id),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Tarjeta de detalle con icono.
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
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
    );
  }
}

/// Fila de detalle simple.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey.withAlpha(179)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
