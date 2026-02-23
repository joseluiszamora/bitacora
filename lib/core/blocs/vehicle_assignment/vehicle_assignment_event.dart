part of 'vehicle_assignment_bloc.dart';

sealed class VehicleAssignmentEvent extends Equatable {
  const VehicleAssignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar asignaciones. Filtra por vehicleId, driverId o companyId.
final class VehicleAssignmentLoadRequested extends VehicleAssignmentEvent {
  const VehicleAssignmentLoadRequested({
    this.vehicleId,
    this.driverId,
    this.companyId,
  });

  final String? vehicleId;
  final String? driverId;
  final String? companyId;

  @override
  List<Object?> get props => [vehicleId, driverId, companyId];
}

/// Crear una nueva asignación.
final class VehicleAssignmentCreateRequested extends VehicleAssignmentEvent {
  const VehicleAssignmentCreateRequested({
    required this.vehicleId,
    required this.driverId,
    this.assignedByUserId,
    required this.startDate,
    this.endDate,
  });

  final String vehicleId;
  final String driverId;
  final String? assignedByUserId;
  final DateTime startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [
    vehicleId,
    driverId,
    assignedByUserId,
    startDate,
    endDate,
  ];
}

/// Actualizar una asignación existente.
final class VehicleAssignmentUpdateRequested extends VehicleAssignmentEvent {
  const VehicleAssignmentUpdateRequested({
    required this.id,
    this.vehicleId,
    this.driverId,
    this.assignedByUserId,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  final String id;
  final String? vehicleId;
  final String? driverId;
  final String? assignedByUserId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    driverId,
    assignedByUserId,
    startDate,
    endDate,
    isActive,
  ];
}

/// Finalizar una asignación (desactivar y poner fecha fin = ahora).
final class VehicleAssignmentEndRequested extends VehicleAssignmentEvent {
  const VehicleAssignmentEndRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Eliminar una asignación.
final class VehicleAssignmentDeleteRequested extends VehicleAssignmentEvent {
  const VehicleAssignmentDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
