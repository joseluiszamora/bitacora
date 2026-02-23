part of 'vehicle_bloc.dart';

enum VehicleStateStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

final class VehicleState extends Equatable {
  const VehicleState({
    this.status = VehicleStateStatus.initial,
    this.vehicles = const [],
    this.errorMessage = '',
  });

  final VehicleStateStatus status;
  final List<Vehicle> vehicles;
  final String errorMessage;

  /// Indica si se puede interactuar con la UI.
  bool get isIdle =>
      status == VehicleStateStatus.initial ||
      status == VehicleStateStatus.loaded ||
      status == VehicleStateStatus.success ||
      status == VehicleStateStatus.failure;

  VehicleState copyWith({
    VehicleStateStatus? status,
    List<Vehicle>? vehicles,
    String? errorMessage,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, errorMessage];
}
