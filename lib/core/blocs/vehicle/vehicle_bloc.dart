import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

/// BLoC para el CRUD de vehículos.
///
/// Accesible para usuarios con rol `super_admin` y `admin`.
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc({VehicleRepository? vehicleRepository})
    : _repository = vehicleRepository ?? VehicleRepository(),
      super(const VehicleState()) {
    on<VehicleLoadRequested>(_onLoadRequested);
    on<VehicleCreateRequested>(_onCreateRequested);
    on<VehicleUpdateRequested>(_onUpdateRequested);
    on<VehicleDeleteRequested>(_onDeleteRequested);
  }

  final VehicleRepository _repository;

  Future<void> _onLoadRequested(
    VehicleLoadRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStateStatus.loading, errorMessage: ''));
    try {
      final vehicles = event.companyId != null
          ? await _repository.getByCompany(event.companyId!)
          : await _repository.getAll();
      emit(
        state.copyWith(status: VehicleStateStatus.loaded, vehicles: vehicles),
      );
    } catch (e) {
      debugPrint('❌ Error cargando vehículos: $e');
      emit(
        state.copyWith(
          status: VehicleStateStatus.failure,
          errorMessage: 'No se pudieron cargar los vehículos: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    VehicleCreateRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStateStatus.creating, errorMessage: ''));
    try {
      final newVehicle = await _repository.create(
        companyId: event.companyId,
        plateNumber: event.plateNumber,
        brand: event.brand,
        model: event.model,
        year: event.year,
        color: event.color,
        avatarUrl: event.avatarUrl,
        chasisCode: event.chasisCode,
        motorCode: event.motorCode,
        ruatNumber: event.ruatNumber,
        soatExpirationDate: event.soatExpirationDate,
        inspectionExpirationDate: event.inspectionExpirationDate,
        insuranceExpirationDate: event.insuranceExpirationDate,
      );
      final updated = List<Vehicle>.from(state.vehicles)..add(newVehicle);
      updated.sort((a, b) => a.plateNumber.compareTo(b.plateNumber));
      emit(
        state.copyWith(status: VehicleStateStatus.success, vehicles: updated),
      );
    } catch (e) {
      debugPrint('❌ Error creando vehículo: $e');
      emit(
        state.copyWith(
          status: VehicleStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    VehicleUpdateRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStateStatus.updating, errorMessage: ''));
    try {
      final updatedVehicle = await _repository.update(
        id: event.id,
        companyId: event.companyId,
        plateNumber: event.plateNumber,
        brand: event.brand,
        model: event.model,
        year: event.year,
        color: event.color,
        avatarUrl: event.avatarUrl,
        chasisCode: event.chasisCode,
        motorCode: event.motorCode,
        ruatNumber: event.ruatNumber,
        soatExpirationDate: event.soatExpirationDate,
        inspectionExpirationDate: event.inspectionExpirationDate,
        insuranceExpirationDate: event.insuranceExpirationDate,
        status: event.status,
      );
      final updated = state.vehicles.map((v) {
        return v.id == event.id ? updatedVehicle : v;
      }).toList();
      updated.sort((a, b) => a.plateNumber.compareTo(b.plateNumber));
      emit(
        state.copyWith(status: VehicleStateStatus.success, vehicles: updated),
      );
    } catch (e) {
      debugPrint('❌ Error actualizando vehículo: $e');
      emit(
        state.copyWith(
          status: VehicleStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    VehicleDeleteRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStateStatus.deleting, errorMessage: ''));
    try {
      await _repository.delete(event.id);
      final updated = state.vehicles.where((v) => v.id != event.id).toList();
      emit(
        state.copyWith(status: VehicleStateStatus.success, vehicles: updated),
      );
    } catch (e) {
      debugPrint('❌ Error eliminando vehículo: $e');
      emit(
        state.copyWith(
          status: VehicleStateStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  /// Traduce errores comunes a mensajes amigables en español.
  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('duplicate') || msg.contains('unique')) {
      return 'Ya existe un vehículo con esa placa.';
    }
    if (msg.contains('foreign key') || msg.contains('referenced')) {
      return 'No se puede eliminar: hay documentos asociados a este vehículo.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
