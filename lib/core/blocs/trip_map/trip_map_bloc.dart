import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/trip.dart';
import '../../data/repositories/trip_repository.dart';

part 'trip_map_event.dart';
part 'trip_map_state.dart';

/// BLoC para la pantalla "Mapa de Viajes".
///
/// Carga los viajes de la empresa y permite seleccionar uno
/// para visualizar origen/destino en el mapa.
class TripMapBloc extends Bloc<TripMapEvent, TripMapState> {
  TripMapBloc({TripRepository? tripRepository})
    : _repository = tripRepository ?? TripRepository(),
      super(const TripMapState()) {
    on<TripMapLoadRequested>(_onLoadRequested);
    on<TripMapTripSelected>(_onTripSelected);
  }

  final TripRepository _repository;

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

  void _onTripSelected(TripMapTripSelected event, Emitter<TripMapState> emit) {
    if (event.trip == null) {
      emit(state.copyWith(clearSelectedTrip: true));
    } else {
      emit(state.copyWith(selectedTrip: event.trip));
    }
  }
}
