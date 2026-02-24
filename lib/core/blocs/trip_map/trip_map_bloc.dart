import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/trip.dart';
import '../../data/models/trip_log.dart';
import '../../data/repositories/trip_log_repository.dart';
import '../../data/repositories/trip_repository.dart';

part 'trip_map_event.dart';
part 'trip_map_state.dart';

/// BLoC para la pantalla "Mapa de Viajes".
///
/// Carga los viajes de la empresa y permite seleccionar uno
/// para visualizar origen/destino en el mapa.
/// Al seleccionar un viaje, carga las bitácoras (trip_logs) con ubicación.
class TripMapBloc extends Bloc<TripMapEvent, TripMapState> {
  TripMapBloc({
    TripRepository? tripRepository,
    TripLogRepository? tripLogRepository,
  }) : _repository = tripRepository ?? TripRepository(),
       _tripLogRepository = tripLogRepository ?? TripLogRepository(),
       super(const TripMapState()) {
    on<TripMapLoadRequested>(_onLoadRequested);
    on<TripMapTripSelected>(_onTripSelected);
    on<TripMapLogSelected>(_onLogSelected);
  }

  final TripRepository _repository;
  final TripLogRepository _tripLogRepository;

  Future<void> _onLoadRequested(
    TripMapLoadRequested event,
    Emitter<TripMapState> emit,
  ) async {
    emit(state.copyWith(status: TripMapStatus.loading, errorMessage: ''));
    try {
      final trips = event.companyId.isNotEmpty
          ? await _repository.getByCompany(event.companyId)
          : await _repository.getAll();

      emit(state.copyWith(status: TripMapStatus.loaded, trips: trips));
    } catch (e) {
      debugPrint('❌ Error cargando viajes para mapa: $e');
      emit(
        state.copyWith(
          status: TripMapStatus.failure,
          errorMessage: 'No se pudieron cargar los viajes: $e',
        ),
      );
    }
  }

  Future<void> _onTripSelected(
    TripMapTripSelected event,
    Emitter<TripMapState> emit,
  ) async {
    if (event.trip == null) {
      emit(
        state.copyWith(
          clearSelectedTrip: true,
          clearSelectedTripLog: true,
          tripLogs: const [],
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedTrip: event.trip,
        clearSelectedTripLog: true,
        tripLogs: const [],
      ),
    );

    // Cargar las bitácoras del viaje seleccionado.
    try {
      final logs = await _tripLogRepository.getByTrip(event.trip!.id);
      emit(state.copyWith(tripLogs: logs));
    } catch (e) {
      debugPrint('❌ Error cargando bitácoras del viaje: $e');
      // No cambiamos el status a failure — las bitácoras son complementarias.
    }
  }

  void _onLogSelected(TripMapLogSelected event, Emitter<TripMapState> emit) {
    if (event.tripLog == null) {
      emit(state.copyWith(clearSelectedTripLog: true));
    } else {
      emit(state.copyWith(selectedTripLog: event.tripLog));
    }
  }
}
