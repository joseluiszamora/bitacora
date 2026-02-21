import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/client_company.dart';
import '../../data/repositories/client_company_repository.dart';

part 'client_company_event.dart';
part 'client_company_state.dart';

/// BLoC para el CRUD de empresas cliente.
///
/// Accesible para usuarios con rol `super_admin`.
class ClientCompanyBloc extends Bloc<ClientCompanyEvent, ClientCompanyState> {
  ClientCompanyBloc({ClientCompanyRepository? clientCompanyRepository})
    : _repository = clientCompanyRepository ?? ClientCompanyRepository(),
      super(const ClientCompanyState()) {
    on<ClientCompanyLoadRequested>(_onLoadRequested);
    on<ClientCompanyCreateRequested>(_onCreateRequested);
    on<ClientCompanyUpdateRequested>(_onUpdateRequested);
    on<ClientCompanyDeleteRequested>(_onDeleteRequested);
  }

  final ClientCompanyRepository _repository;

  Future<void> _onLoadRequested(
    ClientCompanyLoadRequested event,
    Emitter<ClientCompanyState> emit,
  ) async {
    emit(state.copyWith(status: ClientCompanyStatus.loading, errorMessage: ''));
    try {
      final clientCompanies = await _repository.getAll();
      emit(
        state.copyWith(
          status: ClientCompanyStatus.loaded,
          clientCompanies: clientCompanies,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error cargando empresas cliente: $e');
      emit(
        state.copyWith(
          status: ClientCompanyStatus.failure,
          errorMessage: 'No se pudieron cargar las empresas cliente: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    ClientCompanyCreateRequested event,
    Emitter<ClientCompanyState> emit,
  ) async {
    emit(
      state.copyWith(status: ClientCompanyStatus.creating, errorMessage: ''),
    );
    try {
      final newCompany = await _repository.create(
        name: event.name,
        nit: event.nit,
        address: event.address,
        contactEmail: event.contactEmail,
      );
      final updated = List<ClientCompany>.from(state.clientCompanies)
        ..add(newCompany);
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(
        state.copyWith(
          status: ClientCompanyStatus.success,
          clientCompanies: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error creando empresa cliente: $e');
      emit(
        state.copyWith(
          status: ClientCompanyStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ClientCompanyUpdateRequested event,
    Emitter<ClientCompanyState> emit,
  ) async {
    emit(
      state.copyWith(status: ClientCompanyStatus.updating, errorMessage: ''),
    );
    try {
      final updatedCompany = await _repository.update(
        id: event.id,
        name: event.name,
        nit: event.nit,
        address: event.address,
        contactEmail: event.contactEmail,
      );
      final updated = state.clientCompanies.map((c) {
        return c.id == event.id ? updatedCompany : c;
      }).toList();
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(
        state.copyWith(
          status: ClientCompanyStatus.success,
          clientCompanies: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error actualizando empresa cliente: $e');
      emit(
        state.copyWith(
          status: ClientCompanyStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    ClientCompanyDeleteRequested event,
    Emitter<ClientCompanyState> emit,
  ) async {
    emit(
      state.copyWith(status: ClientCompanyStatus.deleting, errorMessage: ''),
    );
    try {
      await _repository.delete(event.id);
      final updated = state.clientCompanies
          .where((c) => c.id != event.id)
          .toList();
      emit(
        state.copyWith(
          status: ClientCompanyStatus.success,
          clientCompanies: updated,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error eliminando empresa cliente: $e');
      emit(
        state.copyWith(
          status: ClientCompanyStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  /// Traduce errores comunes a mensajes amigables en español.
  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('duplicate') || msg.contains('unique')) {
      return 'Ya existe una empresa cliente con ese NIT.';
    }
    if (msg.contains('foreign key') || msg.contains('referenced')) {
      return 'No se puede eliminar: hay usuarios o contratos asociados.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
