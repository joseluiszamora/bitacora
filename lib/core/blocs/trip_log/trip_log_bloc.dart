import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/trip_log.dart';
import '../../data/repositories/trip_log_repository.dart';

part 'trip_log_event.dart';
part 'trip_log_state.dart';

/// BLoC para el CRUD de logs de viaje.
///
/// Accesible para usuarios con rol `admin`, `supervisor` y `driver`.
class TripLogBloc extends Bloc<TripLogEvent, TripLogState> {
  TripLogBloc({TripLogRepository? tripLogRepository})
    : _repository = tripLogRepository ?? TripLogRepository(),
      super(const TripLogState()) {
    on<TripLogLoadRequested>(_onLoadRequested);
    on<TripLogCreateRequested>(_onCreateRequested);
    on<TripLogUpdateRequested>(_onUpdateRequested);
    on<TripLogDeleteRequested>(_onDeleteRequested);
  }

  final TripLogRepository _repository;

  Future<void> _onLoadRequested(
    TripLogLoadRequested event,
    Emitter<TripLogState> emit,
  ) async {
    emit(state.copyWith(status: TripLogStateStatus.loading, errorMessage: ''));
    try {
      final logs = await _repository.getByTrip(event.tripId);
      emit(state.copyWith(status: TripLogStateStatus.loaded, logs: logs));
    } catch (e) {
      debugPrint('❌ Error cargando logs del viaje: $e');
      emit(
        state.copyWith(
          status: TripLogStateStatus.failure,
          errorMessage: 'No se pudieron cargar los logs del viaje: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    TripLogCreateRequested event,
    Emitter<TripLogState> emit,
  ) async {
    emit(state.copyWith(status: TripLogStateStatus.creating, errorMessage: ''));
    try {
      final newLog = await _repository.create(
        tripId: event.tripId,
        userId: event.userId,
        driverId: event.driverId,
        eventType: event.eventType,
        description: event.description,
        latitude: event.latitude,
        longitude: event.longitude,
        metadata: event.metadata,
      );
      final updated = List<TripLog>.from(state.logs)..add(newLog);
      emit(state.copyWith(status: TripLogStateStatus.success, logs: updated));
    } catch (e) {
      debugPrint('❌ Error creando log de viaje: $e');
      emit(
        state.copyWith(
          status: TripLogStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    TripLogUpdateRequested event,
    Emitter<TripLogState> emit,
  ) async {
    emit(state.copyWith(status: TripLogStateStatus.updating, errorMessage: ''));
    try {
      final updatedLog = await _repository.update(
        id: event.id,
        userId: event.userId,
        driverId: event.driverId,
        eventType: event.eventType,
        description: event.description,
        latitude: event.latitude,
        longitude: event.longitude,
        metadata: event.metadata,
      );
      final updated = state.logs.map((l) {
        return l.id == event.id ? updatedLog : l;
      }).toList();
      emit(state.copyWith(status: TripLogStateStatus.success, logs: updated));
    } catch (e) {
      debugPrint('❌ Error actualizando log de viaje: $e');
      emit(
        state.copyWith(
          status: TripLogStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    TripLogDeleteRequested event,
    Emitter<TripLogState> emit,
  ) async {
    emit(state.copyWith(status: TripLogStateStatus.deleting, errorMessage: ''));
    try {
      await _repository.delete(event.id);
      final updated = state.logs.where((l) => l.id != event.id).toList();
      emit(state.copyWith(status: TripLogStateStatus.success, logs: updated));
    } catch (e) {
      debugPrint('❌ Error eliminando log de viaje: $e');
      emit(
        state.copyWith(
          status: TripLogStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  /// Traduce errores comunes a mensajes amigables en español.
  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('duplicate') || msg.contains('unique')) {
      return 'Ya existe un registro duplicado.';
    }
    if (msg.contains('foreign key') || msg.contains('referenced')) {
      return 'Referencia inválida: viaje, usuario o conductor no encontrados.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
