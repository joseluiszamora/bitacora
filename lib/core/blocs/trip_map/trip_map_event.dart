part of 'trip_map_bloc.dart';

sealed class TripMapEvent extends Equatable {
  const TripMapEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar los viajes de la empresa del usuario actual.
final class TripMapLoadRequested extends TripMapEvent {
  const TripMapLoadRequested({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Seleccionar un viaje en el mapa.
final class TripMapTripSelected extends TripMapEvent {
  const TripMapTripSelected({this.trip});

  final Trip? trip;

  @override
  List<Object?> get props => [trip];
}

/// Seleccionar una bitácora (trip log) en el mapa.
final class TripMapLogSelected extends TripMapEvent {
  const TripMapLogSelected({this.tripLog});

  final TripLog? tripLog;

  @override
  List<Object?> get props => [tripLog];
}
