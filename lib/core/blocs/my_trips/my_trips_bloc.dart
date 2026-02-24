import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/trip.dart';
import '../../data/models/user_role.dart';
import '../../data/repositories/trip_repository.dart';

part 'my_trips_event.dart';
part 'my_trips_state.dart';

/// BLoC para "Mis Viajes".
///
/// - Driver: carga viajes asignados a su persona (vía vehicle_assignments).
/// - Admin/Supervisor: carga viajes de su empresa.
class MyTripsBloc extends Bloc<MyTripsEvent, MyTripsState> {
  MyTripsBloc({TripRepository? tripRepository})
    : _repository = tripRepository ?? TripRepository(),
      super(const MyTripsState()) {
    on<MyTripsLoadRequested>(_onLoadRequested);
  }

  final TripRepository _repository;

  Future<void> _onLoadRequested(
    MyTripsLoadRequested event,
    Emitter<MyTripsState> emit,
  ) async {
    emit(state.copyWith(status: MyTripsStatus.loading, errorMessage: ''));
    try {
      List<Trip> trips;

      if (event.role == UserRole.driver) {
        // Driver: obtener viajes por vehículos asignados
        trips = await _repository.getByDriver(event.userId);
      } else {
        // Admin/Supervisor: obtener viajes de su empresa
        if (event.companyId != null && event.companyId!.isNotEmpty) {
          trips = await _repository.getByCompany(event.companyId!);
        } else {
          trips = await _repository.getAll();
        }
      }

      emit(state.copyWith(status: MyTripsStatus.loaded, trips: trips));
    } catch (e) {
      debugPrint('❌ Error cargando mis viajes: $e');
      emit(
        state.copyWith(
          status: MyTripsStatus.failure,
          errorMessage: 'No se pudieron cargar los viajes: $e',
        ),
      );
    }
  }
}
