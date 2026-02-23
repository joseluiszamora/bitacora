import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/vehicle_assignment.dart';
import '../../data/repositories/vehicle_assignment_repository.dart';

part 'vehicle_assignment_event.dart';
part 'vehicle_assignment_state.dart';

/// BLoC para el CRUD de asignaciones vehículo-conductor.
class VehicleAssignmentBloc
    extends Bloc<VehicleAssignmentEvent, VehicleAssignmentState> {
  VehicleAssignmentBloc({VehicleAssignmentRepository? repository})
    : _repository = repository ?? VehicleAssignmentRepository(),
      super(const VehicleAssignmentState()) {
    on<VehicleAssignmentLoadRequested>(_onLoadRequested);
    on<VehicleAssignmentCreateRequested>(_onCreateRequested);
    on<VehicleAssignmentUpdateRequested>(_onUpdateRequested);
    on<VehicleAssignmentEndRequested>(_onEndRequested);
    on<VehicleAssignmentDeleteRequested>(_onDeleteRequested);
  }

  final VehicleAssignmentRepository _repository;

  Future<void> _onLoadRequested(
    VehicleAssignmentLoadRequested event,
    Emitter<VehicleAssignmentState> emit,
  ) async {
    emit(
      state.copyWith(status: VehicleAssignmentStatus.loading, errorMessage: ''),
    );
    try {
      final List<VehicleAssignment> assignments;
      if (event.vehicleId != null) {
        assignments = await _repository.getByVehicle(event.vehicleId!);
      } else if (event.driverId != null) {
        assignments = await _repository.getByDriver(event.driverId!);
      } else if (event.companyId != null) {
        assignments = await _repository.getByCompany(event.companyId!);
      } else {
        assignments = await _repository.getAll();
      }
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.loaded,
          assignments: assignments,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error cargando asignaciones: $e');
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.failure,
          errorMessage: 'No se pudieron cargar las asignaciones: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    VehicleAssignmentCreateRequested event,
    Emitter<VehicleAssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VehicleAssignmentStatus.creating,
        errorMessage: '',
      ),
    );
    try {
      final newAssignment = await _repository.create(
        vehicleId: event.vehicleId,
        driverId: event.driverId,
        assignedByUserId: event.assignedByUserId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final updated = List<VehicleAssignment>.from(state.assignments)
        ..insert(0, newAssignment);
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.success,
          assignments: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error creando asignación: $e');
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    VehicleAssignmentUpdateRequested event,
    Emitter<VehicleAssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VehicleAssignmentStatus.updating,
        errorMessage: '',
      ),
    );
    try {
      final updatedAssignment = await _repository.update(
        id: event.id,
        vehicleId: event.vehicleId,
        driverId: event.driverId,
        assignedByUserId: event.assignedByUserId,
        startDate: event.startDate,
        endDate: event.endDate,
        isActive: event.isActive,
      );
      final updated = state.assignments.map((a) {
        return a.id == event.id ? updatedAssignment : a;
      }).toList();
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.success,
          assignments: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error actualizando asignación: $e');
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onEndRequested(
    VehicleAssignmentEndRequested event,
    Emitter<VehicleAssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VehicleAssignmentStatus.updating,
        errorMessage: '',
      ),
    );
    try {
      final ended = await _repository.endAssignment(event.id);
      final updated = state.assignments.map((a) {
        return a.id == event.id ? ended : a;
      }).toList();
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.success,
          assignments: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error finalizando asignación: $e');
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    VehicleAssignmentDeleteRequested event,
    Emitter<VehicleAssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VehicleAssignmentStatus.deleting,
        errorMessage: '',
      ),
    );
    try {
      await _repository.delete(event.id);
      final updated = state.assignments.where((a) => a.id != event.id).toList();
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.success,
          assignments: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error eliminando asignación: $e');
      emit(
        state.copyWith(
          status: VehicleAssignmentStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('duplicate key') || msg.contains('unique')) {
      return 'Esta asignación ya existe.';
    }
    if (msg.contains('foreign key') || msg.contains('violates')) {
      return 'El vehículo o conductor no existe.';
    }
    return 'Error inesperado: $msg';
  }
}
