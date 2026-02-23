import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/auth/authentication_bloc.dart';
import '../../../core/blocs/vehicle_assignment/vehicle_assignment_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/user_role.dart';
import '../../../core/data/models/vehicle_assignment.dart';
import 'vehicle_assignment_detail_page.dart';
import 'vehicle_assignment_form_page.dart';

/// Página de listado de asignaciones vehículo-conductor.
class VehicleAssignmentsPage extends StatelessWidget {
  const VehicleAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final user = authState.user;
    final companyId = user.role == UserRole.superAdmin ? null : user.company.id;

    return BlocProvider(
      create: (_) =>
          VehicleAssignmentBloc()
            ..add(VehicleAssignmentLoadRequested(companyId: companyId)),
      child: _AssignmentsView(companyId: companyId),
    );
  }
}

class _AssignmentsView extends StatelessWidget {
  const _AssignmentsView({this.companyId});

  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<VehicleAssignmentBloc>().add(
                VehicleAssignmentLoadRequested(companyId: companyId),
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
      body: BlocConsumer<VehicleAssignmentBloc, VehicleAssignmentState>(
        listener: (context, state) {
          if (state.status == VehicleAssignmentStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == VehicleAssignmentStatus.failure &&
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
          if (state.status == VehicleAssignmentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.assignments.isEmpty &&
              state.status != VehicleAssignmentStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link_off,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay asignaciones registradas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca el botón + para asignar un conductor a un vehículo.',
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
              context.read<VehicleAssignmentBloc>().add(
                VehicleAssignmentLoadRequested(companyId: companyId),
              );
              await context.read<VehicleAssignmentBloc>().stream.firstWhere(
                (s) => s.status != VehicleAssignmentStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.assignments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final assignment = state.assignments[index];
                return _AssignmentCard(
                  assignment: assignment,
                  onTap: () => _navigateToDetail(context, assignment),
                  onEnd: assignment.isActive
                      ? () => _confirmEnd(context, assignment)
                      : null,
                  onDelete: () => _confirmDelete(context, assignment),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {VehicleAssignment? assignment}) {
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

  void _navigateToDetail(BuildContext context, VehicleAssignment assignment) {
    final bloc = context.read<VehicleAssignmentBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: VehicleAssignmentDetailPage(assignment: assignment),
        ),
      ),
    );
  }

  void _confirmEnd(BuildContext context, VehicleAssignment assignment) {
    final driverName = assignment.driver?.name ?? 'el conductor';
    final vehicleName = assignment.vehicle?.plateNumber ?? 'el vehículo';
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar Asignación'),
        content: Text(
          '¿Deseas finalizar la asignación de $driverName '
          'al vehículo $vehicleName?\n\n'
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
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehicleAssignment assignment) {
    showDialog<bool>(
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
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de asignación.
class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
    this.onEnd,
    required this.onDelete,
  });

  final VehicleAssignment assignment;
  final VoidCallback onTap;
  final VoidCallback? onEnd;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isActive = assignment.isActive;
    final statusColor = isActive ? AppColors.success : AppColors.grey;

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
              // Fila superior: conductor → vehículo + estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.link, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.driver?.name ?? 'Conductor',
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
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColors.grey.withAlpha(128),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                assignment.vehicle != null
                                    ? '${assignment.vehicle!.plateNumber} — ${assignment.vehicle!.displayName}'
                                    : 'Vehículo',
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
                      isActive ? 'Activa' : 'Finalizada',
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
                      if (isActive)
                        const PopupMenuItem(
                          value: 'end',
                          child: ListTile(
                            leading: Icon(
                              Icons.stop_circle_outlined,
                              color: AppColors.warning,
                            ),
                            title: Text(
                              'Finalizar',
                              style: TextStyle(color: AppColors.warning),
                            ),
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
                      if (value == 'end' && onEnd != null) onEnd!();
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fila inferior: fechas
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.grey.withAlpha(179),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(assignment.startDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey.withAlpha(179),
                    ),
                  ),
                  if (assignment.endDate != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '→ ${_formatDate(assignment.endDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey.withAlpha(179),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
