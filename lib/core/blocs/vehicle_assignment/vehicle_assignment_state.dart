part of 'vehicle_assignment_bloc.dart';

enum VehicleAssignmentStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

final class VehicleAssignmentState extends Equatable {
  const VehicleAssignmentState({
    this.status = VehicleAssignmentStatus.initial,
    this.assignments = const [],
    this.errorMessage = '',
  });

  final VehicleAssignmentStatus status;
  final List<VehicleAssignment> assignments;
  final String errorMessage;

  bool get isIdle =>
      status == VehicleAssignmentStatus.initial ||
      status == VehicleAssignmentStatus.loaded ||
      status == VehicleAssignmentStatus.success ||
      status == VehicleAssignmentStatus.failure;

  VehicleAssignmentState copyWith({
    VehicleAssignmentStatus? status,
    List<VehicleAssignment>? assignments,
    String? errorMessage,
  }) {
    return VehicleAssignmentState(
      status: status ?? this.status,
      assignments: assignments ?? this.assignments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, assignments, errorMessage];
}
