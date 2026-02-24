part of 'trip_log_bloc.dart';

sealed class TripLogEvent extends Equatable {
  const TripLogEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar los logs de un viaje.
final class TripLogLoadRequested extends TripLogEvent {
  const TripLogLoadRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

/// Crear un nuevo log de viaje.
final class TripLogCreateRequested extends TripLogEvent {
  const TripLogCreateRequested({
    required this.tripId,
    this.userId,
    this.driverId,
    required this.eventType,
    this.description,
    this.latitude,
    this.longitude,
    this.metadata,
  });

  final String tripId;
  final String? userId;
  final String? driverId;
  final TripLogEventType eventType;
  final String? description;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
    tripId,
    userId,
    driverId,
    eventType,
    description,
    latitude,
    longitude,
    metadata,
  ];
}

/// Actualizar un log existente.
final class TripLogUpdateRequested extends TripLogEvent {
  const TripLogUpdateRequested({
    required this.id,
    this.userId,
    this.driverId,
    this.eventType,
    this.description,
    this.latitude,
    this.longitude,
    this.metadata,
  });

  final String id;
  final String? userId;
  final String? driverId;
  final TripLogEventType? eventType;
  final String? description;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
    id,
    userId,
    driverId,
    eventType,
    description,
    latitude,
    longitude,
    metadata,
  ];
}

/// Eliminar un log por su ID.
final class TripLogDeleteRequested extends TripLogEvent {
  const TripLogDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
