import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/client_location.dart';
import '../../data/repositories/client_location_repository.dart';

part 'client_location_event.dart';
part 'client_location_state.dart';

/// BLoC para el CRUD de ubicaciones de clientes.
class ClientLocationBloc
    extends Bloc<ClientLocationEvent, ClientLocationState> {
  ClientLocationBloc({ClientLocationRepository? repository})
    : _repository = repository ?? ClientLocationRepository(),
      super(const ClientLocationState()) {
    on<ClientLocationLoadRequested>(_onLoadRequested);
    on<ClientLocationCreateRequested>(_onCreateRequested);
    on<ClientLocationUpdateRequested>(_onUpdateRequested);
    on<ClientLocationDeleteRequested>(_onDeleteRequested);
  }

  final ClientLocationRepository _repository;

  Future<void> _onLoadRequested(
    ClientLocationLoadRequested event,
    Emitter<ClientLocationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ClientLocationBlocStatus.loading,
        errorMessage: '',
      ),
    );
    try {
      final List<ClientLocation> locations;
      if (event.clientCompanyId != null) {
        locations = await _repository.getByClientCompany(
          event.clientCompanyId!,
        );
      } else {
        locations = await _repository.getAll();
      }
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.loaded,
          locations: locations,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error cargando ubicaciones: $e');
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.failure,
          errorMessage: 'No se pudieron cargar las ubicaciones: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    ClientLocationCreateRequested event,
    Emitter<ClientLocationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ClientLocationBlocStatus.creating,
        errorMessage: '',
      ),
    );
    try {
      final newLocation = await _repository.create(
        clientCompanyId: event.clientCompanyId,
        name: event.name,
        type: event.type,
        address: event.address,
        cityId: event.cityId,
        country: event.country,
        latitude: event.latitude,
        longitude: event.longitude,
        contactName: event.contactName,
        contactPhone: event.contactPhone,
      );
      final updated = List<ClientLocation>.from(state.locations)
        ..insert(0, newLocation);
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.success,
          locations: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error creando ubicación: $e');
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ClientLocationUpdateRequested event,
    Emitter<ClientLocationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ClientLocationBlocStatus.updating,
        errorMessage: '',
      ),
    );
    try {
      final updatedLocation = await _repository.update(
        id: event.id,
        clientCompanyId: event.clientCompanyId,
        name: event.name,
        type: event.type,
        address: event.address,
        cityId: event.cityId,
        country: event.country,
        latitude: event.latitude,
        longitude: event.longitude,
        contactName: event.contactName,
        contactPhone: event.contactPhone,
        status: event.status,
      );
      final updated = state.locations.map((l) {
        return l.id == event.id ? updatedLocation : l;
      }).toList();
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.success,
          locations: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error actualizando ubicación: $e');
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    ClientLocationDeleteRequested event,
    Emitter<ClientLocationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ClientLocationBlocStatus.deleting,
        errorMessage: '',
      ),
    );
    try {
      await _repository.delete(event.id);
      final updated = state.locations.where((l) => l.id != event.id).toList();
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.success,
          locations: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error eliminando ubicación: $e');
      emit(
        state.copyWith(
          status: ClientLocationBlocStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('duplicate key') || msg.contains('unique')) {
      return 'Ya existe una ubicación con ese nombre.';
    }
    if (msg.contains('foreign key') || msg.contains('violates')) {
      return 'La empresa cliente o ciudad seleccionada no existe.';
    }
    return 'Error inesperado: $msg';
  }
}
