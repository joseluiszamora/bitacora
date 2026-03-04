import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/finance_category.dart';
import '../../data/models/finance_group.dart';
import '../../data/models/finance_record.dart';
import '../../data/providers/user_provider.dart';
import '../../data/repositories/finance_category_repository.dart';
import '../../data/repositories/finance_group_repository.dart';
import '../../data/repositories/finance_record_repository.dart';

part 'finance_event.dart';
part 'finance_state.dart';

/// BLoC para el módulo de Finanzas.
///
/// Gestiona grupos, categorías y registros financieros (ingresos/egresos).
/// Accesible solo para super_admin, admin y supervisor.
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc({
    FinanceGroupRepository? groupRepository,
    FinanceCategoryRepository? categoryRepository,
    FinanceRecordRepository? recordRepository,
    UserProvider? userProvider,
  }) : _groupRepo = groupRepository ?? FinanceGroupRepository(),
       _categoryRepo = categoryRepository ?? FinanceCategoryRepository(),
       _recordRepo = recordRepository ?? FinanceRecordRepository(),
       _userProvider = userProvider ?? UserProvider(),
       super(const FinanceState()) {
    // Carga
    on<FinanceLoadRequested>(_onLoadRequested);

    // Grupos
    on<FinanceGroupCreateRequested>(_onGroupCreate);
    on<FinanceGroupUpdateRequested>(_onGroupUpdate);
    on<FinanceGroupDeleteRequested>(_onGroupDelete);

    // Categorías
    on<FinanceCategoryCreateRequested>(_onCategoryCreate);
    on<FinanceCategoryUpdateRequested>(_onCategoryUpdate);
    on<FinanceCategoryDeleteRequested>(_onCategoryDelete);

    // Registros
    on<FinanceRecordCreateRequested>(_onRecordCreate);
    on<FinanceRecordUpdateRequested>(_onRecordUpdate);
    on<FinanceRecordDeleteRequested>(_onRecordDelete);

    // Filtro
    on<FinanceFilterByGroupRequested>(_onFilterByGroup);
  }

  final FinanceGroupRepository _groupRepo;
  final FinanceCategoryRepository _categoryRepo;
  final FinanceRecordRepository _recordRepo;
  final UserProvider _userProvider;

  // ─── Carga ───────────────────────────────────────────────────────────

  Future<void> _onLoadRequested(
    FinanceLoadRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.loading, errorMessage: ''));
    try {
      final results = await Future.wait([
        _groupRepo.getByCompany(event.companyId),
        _categoryRepo.getByCompany(event.companyId),
        _recordRepo.getByCompany(event.companyId),
        _userProvider.getByCompany(event.companyId),
      ]);

      final usersData = results[3] as List<Map<String, dynamic>>;
      final users = usersData.map(FinanceUser.fromJson).toList();

      emit(
        state.copyWith(
          status: FinanceStatus.loaded,
          groups: results[0] as List<FinanceGroup>,
          categories: results[1] as List<FinanceCategory>,
          records: results[2] as List<FinanceRecord>,
          companyUsers: users,
          clearFilterGroupId: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error cargando finanzas: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: 'No se pudieron cargar los datos financieros: $e',
        ),
      );
    }
  }

  // ─── Grupos ──────────────────────────────────────────────────────────

  Future<void> _onGroupCreate(
    FinanceGroupCreateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.creating, errorMessage: ''));
    try {
      final newGroup = await _groupRepo.create(
        companyId: event.companyId,
        name: event.name,
        description: event.description,
      );
      final updated = List<FinanceGroup>.from(state.groups)..add(newGroup);
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(status: FinanceStatus.success, groups: updated));
    } catch (e) {
      debugPrint('❌ Error creando grupo: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onGroupUpdate(
    FinanceGroupUpdateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.updating, errorMessage: ''));
    try {
      final updatedGroup = await _groupRepo.update(
        id: event.id,
        name: event.name,
        description: event.description,
        isActive: event.isActive,
      );
      final updated = state.groups.map((g) {
        return g.id == event.id ? updatedGroup : g;
      }).toList();
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(status: FinanceStatus.success, groups: updated));
    } catch (e) {
      debugPrint('❌ Error actualizando grupo: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onGroupDelete(
    FinanceGroupDeleteRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.deleting, errorMessage: ''));
    try {
      await _groupRepo.delete(event.id);
      final updated = state.groups.where((g) => g.id != event.id).toList();
      emit(state.copyWith(status: FinanceStatus.success, groups: updated));
    } catch (e) {
      debugPrint('❌ Error eliminando grupo: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  // ─── Categorías ──────────────────────────────────────────────────────

  Future<void> _onCategoryCreate(
    FinanceCategoryCreateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.creating, errorMessage: ''));
    try {
      final newCat = await _categoryRepo.create(
        companyId: event.companyId,
        name: event.name,
        description: event.description,
      );
      final updated = List<FinanceCategory>.from(state.categories)..add(newCat);
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(status: FinanceStatus.success, categories: updated));
    } catch (e) {
      debugPrint('❌ Error creando categoría: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onCategoryUpdate(
    FinanceCategoryUpdateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.updating, errorMessage: ''));
    try {
      final updatedCat = await _categoryRepo.update(
        id: event.id,
        name: event.name,
        description: event.description,
        isActive: event.isActive,
      );
      final updated = state.categories.map((c) {
        return c.id == event.id ? updatedCat : c;
      }).toList();
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(status: FinanceStatus.success, categories: updated));
    } catch (e) {
      debugPrint('❌ Error actualizando categoría: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onCategoryDelete(
    FinanceCategoryDeleteRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.deleting, errorMessage: ''));
    try {
      await _categoryRepo.delete(event.id);
      final updated = state.categories.where((c) => c.id != event.id).toList();
      emit(state.copyWith(status: FinanceStatus.success, categories: updated));
    } catch (e) {
      debugPrint('❌ Error eliminando categoría: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  // ─── Registros ───────────────────────────────────────────────────────

  Future<void> _onRecordCreate(
    FinanceRecordCreateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.creating, errorMessage: ''));
    try {
      final newRecord = await _recordRepo.create(
        companyId: event.companyId,
        groupId: event.groupId,
        categoryId: event.categoryId,
        type: event.type,
        amount: event.amount,
        responsibleUserId: event.responsibleUserId,
        description: event.description,
        recordDate: event.recordDate,
      );
      final updated = List<FinanceRecord>.from(state.records)
        ..insert(0, newRecord);
      emit(state.copyWith(status: FinanceStatus.success, records: updated));
    } catch (e) {
      debugPrint('❌ Error creando registro: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onRecordUpdate(
    FinanceRecordUpdateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.updating, errorMessage: ''));
    try {
      final updatedRecord = await _recordRepo.update(
        id: event.id,
        groupId: event.groupId,
        categoryId: event.categoryId,
        type: event.type,
        amount: event.amount,
        responsibleUserId: event.responsibleUserId,
        description: event.description,
        recordDate: event.recordDate,
      );
      final updated = state.records.map((r) {
        return r.id == event.id ? updatedRecord : r;
      }).toList();
      emit(state.copyWith(status: FinanceStatus.success, records: updated));
    } catch (e) {
      debugPrint('❌ Error actualizando registro: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  Future<void> _onRecordDelete(
    FinanceRecordDeleteRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.deleting, errorMessage: ''));
    try {
      await _recordRepo.delete(event.id);
      final updated = state.records.where((r) => r.id != event.id).toList();
      emit(state.copyWith(status: FinanceStatus.success, records: updated));
    } catch (e) {
      debugPrint('❌ Error eliminando registro: $e');
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  // ─── Filtro ──────────────────────────────────────────────────────────

  void _onFilterByGroup(
    FinanceFilterByGroupRequested event,
    Emitter<FinanceState> emit,
  ) {
    if (event.groupId == null) {
      emit(state.copyWith(clearFilterGroupId: true));
    } else {
      emit(state.copyWith(filterGroupId: event.groupId));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('duplicate') || msg.contains('unique')) {
      return 'Ya existe un registro con ese nombre.';
    }
    if (msg.contains('foreign key') || msg.contains('referenced')) {
      return 'No se puede eliminar: tiene registros asociados.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
