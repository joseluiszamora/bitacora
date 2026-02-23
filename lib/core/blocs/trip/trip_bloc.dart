import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/trip.dart';
import '../../data/repositories/trip_repository.dart';

part 'trip_event.dart';
part 'trip_state.dart';

/// BLoC para el CRUD de viajes.
///
/// Accesible para usuarios con rol `super_admin` y `admin`.
class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc({TripRepository? tripRepository})
    : _repository = tripRepository ?? TripRepository(),
      super(const TripState()) {
    on<TripLoadRequested>(_onLoadRequested);
    on<TripCreateRequested>(_onCreateRequested);
    on<TripUpdateRequested>(_onUpdateRequested);
    on<TripDeleteRequested>(_onDeleteRequested);
  }

  final TripRepository _repository;

  Future<void> _onLoadRequested(
    TripLoadRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripStateStatus.loading, errorMessage: ''));
    try {
      final trips = event.companyId != null
          ? await _repository.getByCompany(event.companyId!)
          : await _repository.getAll();
      emit(state.copyWith(status: TripStateStatus.loaded, trips: trips));
    } catch (e) {
      debugPrint('❌ Error cargando viajes: $e');
      emit(
        state.copyWith(
          status: TripStateStatus.failure,
          errorMessage: 'No se pudieron cargar los viajes: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    TripCreateRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripStateStatus.creating, errorMessage: ''));
    try {
      final newTrip = await _repository.create(
        companyId: event.companyId,
        clientCompanyId: event.clientCompanyId,
        vehicleId: event.vehicleId,
        assignedByUserId: event.assignedByUserId,
        origin: event.origin,
        destination: event.destination,
        departureTime: event.departureTime,
        arrivalTime: event.arrivalTime,
        price: event.price,
      );
      final updated = List<Trip>.from(state.trips)..insert(0, newTrip);
      emit(state.copyWith(status: TripStateStatus.success, trips: updated));
    } catch (e) {
      debugPrint('❌ Error creando viaje: $e');
      emit(
        state.copyWith(
          status: TripStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    TripUpdateRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripStateStatus.updating, errorMessage: ''));
    try {
      final updatedTrip = await _repository.update(
        id: event.id,
        companyId: event.companyId,
        clientCompanyId: event.clientCompanyId,
        vehicleId: event.vehicleId,
        assignedByUserId: event.assignedByUserId,
        origin: event.origin,
        destination: event.destination,
        departureTime: event.departureTime,
        arrivalTime: event.arrivalTime,
        status: event.status,
        price: event.price,
      );
      final updated = state.trips.map((t) {
        return t.id == event.id ? updatedTrip : t;
      }).toList();
      emit(state.copyWith(status: TripStateStatus.success, trips: updated));
    } catch (e) {
      debugPrint('❌ Error actualizando viaje: $e');
      emit(
        state.copyWith(
          status: TripStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    TripDeleteRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripStateStatus.deleting, errorMessage: ''));
    try {
      await _repository.delete(event.id);
      final updated = state.trips.where((t) => t.id != event.id).toList();
      emit(state.copyWith(status: TripStateStatus.success, trips: updated));
    } catch (e) {
      debugPrint('❌ Error eliminando viaje: $e');
      emit(
        state.copyWith(
          status: TripStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  /// Traduce errores comunes a mensajes amigables en español.
  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('duplicate') || msg.contains('unique')) {
      return 'Ya existe un viaje con esos datos.';
    }
    if (msg.contains('foreign key') || msg.contains('referenced')) {
      return 'Referencia inválida: vehículo, conductor o empresa no encontrados.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
