import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/company.dart';
import '../../data/repositories/company_repository.dart';

part 'company_event.dart';
part 'company_state.dart';

/// BLoC para el CRUD de compañías.
///
/// Solo accesible para usuarios con rol `super_admin`.
class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc({CompanyRepository? companyRepository})
    : _repository = companyRepository ?? CompanyRepository(),
      super(const CompanyState()) {
    on<CompanyLoadRequested>(_onLoadRequested);
    on<CompanyCreateRequested>(_onCreateRequested);
    on<CompanyUpdateRequested>(_onUpdateRequested);
    on<CompanyDeleteRequested>(_onDeleteRequested);
  }

  final CompanyRepository _repository;

  Future<void> _onLoadRequested(
    CompanyLoadRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(state.copyWith(status: CompanyStatus.loading, errorMessage: ''));
    try {
      final companies = await _repository.getAll();
      emit(state.copyWith(status: CompanyStatus.loaded, companies: companies));
    } catch (e) {
      debugPrint('❌ Error cargando compañías: $e');
      emit(
        state.copyWith(
          status: CompanyStatus.failure,
          errorMessage: 'No se pudieron cargar las compañías: $e',
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    CompanyCreateRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(state.copyWith(status: CompanyStatus.creating, errorMessage: ''));
    try {
      final newCompany = await _repository.create(
        name: event.name,
        socialReason: event.socialReason,
        nit: event.nit,
      );
      final updated = List<Company>.from(state.companies)..add(newCompany);
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(status: CompanyStatus.success, companies: updated));
    } catch (e) {
      debugPrint('❌ Error creando compañía: $e');
      emit(
        state.copyWith(
          status: CompanyStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    CompanyUpdateRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(state.copyWith(status: CompanyStatus.updating, errorMessage: ''));
    try {
      final updatedCompany = await _repository.update(
        id: event.id,
        name: event.name,
        socialReason: event.socialReason,
        nit: event.nit,
        status: event.status,
      );
      final updated = state.companies.map((c) {
        return c.id == event.id ? updatedCompany : c;
      }).toList();
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(status: CompanyStatus.success, companies: updated));
    } catch (e) {
      debugPrint('❌ Error actualizando compañía: $e');
      emit(
        state.copyWith(
          status: CompanyStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    CompanyDeleteRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(state.copyWith(status: CompanyStatus.deleting, errorMessage: ''));
    try {
      await _repository.delete(event.id);
      final updated = state.companies.where((c) => c.id != event.id).toList();
      emit(state.copyWith(status: CompanyStatus.success, companies: updated));
    } catch (e) {
      debugPrint('❌ Error eliminando compañía: $e');
      emit(
        state.copyWith(
          status: CompanyStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  /// Traduce errores comunes a mensajes amigables en español.
  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('duplicate') || msg.contains('unique')) {
      return 'Ya existe una compañía con ese NIT.';
    }
    if (msg.contains('foreign key') || msg.contains('referenced')) {
      return 'No se puede eliminar: hay usuarios asociados a esta compañía.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
