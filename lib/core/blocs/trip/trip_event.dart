part of 'trip_bloc.dart';

sealed class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar la lista de viajes.
/// Si [companyId] es null, carga todos (super_admin).
/// Si tiene valor, filtra por empresa (admin).
final class TripLoadRequested extends TripEvent {
  const TripLoadRequested({this.companyId});

  final String? companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Crear un nuevo viaje.
final class TripCreateRequested extends TripEvent {
  const TripCreateRequested({
    required this.companyId,
    required this.clientCompanyId,
    required this.vehicleId,
    this.assignedByUserId,
    required this.originLocationId,
    required this.destinationLocationId,
    this.departureTime,
    this.arrivalTime,
    this.price,
  });

  final String companyId;
  final String clientCompanyId;
  final String vehicleId;
  final String? assignedByUserId;
  final String originLocationId;
  final String destinationLocationId;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final double? price;

  @override
  List<Object?> get props => [
    companyId,
    clientCompanyId,
    vehicleId,
    assignedByUserId,
    originLocationId,
    destinationLocationId,
    departureTime,
    arrivalTime,
    price,
  ];
}

/// Actualizar un viaje existente.
final class TripUpdateRequested extends TripEvent {
  const TripUpdateRequested({
    required this.id,
    this.companyId,
    this.clientCompanyId,
    this.vehicleId,
    this.assignedByUserId,
    this.originLocationId,
    this.destinationLocationId,
    this.departureTime,
    this.arrivalTime,
    this.status,
    this.price,
  });

  final String id;
  final String? companyId;
  final String? clientCompanyId;
  final String? vehicleId;
  final String? assignedByUserId;
  final String? originLocationId;
  final String? destinationLocationId;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final TripStatus? status;
  final double? price;

  @override
  List<Object?> get props => [
    id,
    companyId,
    clientCompanyId,
    vehicleId,
    assignedByUserId,
    originLocationId,
    destinationLocationId,
    departureTime,
    arrivalTime,
    status,
    price,
  ];
}

/// Eliminar un viaje.
final class TripDeleteRequested extends TripEvent {
  const TripDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
