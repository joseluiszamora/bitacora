import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/user.dart';
import '../../data/models/user_role.dart';
import '../../data/repositories/user_repository.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

/// BLoC para la administración de usuarios.
///
/// Recibe el rol y companyId del usuario autenticado para filtrar
/// correctamente la lista y las acciones permitidas.
class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  UserManagementBloc({
    required this.currentRole,
    this.currentCompanyId,
    this.currentClientCompanyId,
    UserRepository? userRepository,
  }) : _repository = userRepository ?? UserRepository(),
       super(const UserManagementState()) {
    on<UserManagementLoadRequested>(_onLoadRequested);
    on<UserManagementCreateRequested>(_onCreateRequested);
    on<UserManagementUpdateRequested>(_onUpdateRequested);
    on<UserManagementToggleActiveRequested>(_onToggleActive);
  }

  final UserRole currentRole;
  final String? currentCompanyId;
  final String? currentClientCompanyId;
  final UserRepository _repository;

  // ─── Load ────────────────────────────────────────────────────────────

  Future<void> _onLoadRequested(
    UserManagementLoadRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      state.copyWith(status: UserManagementStatus.loading, errorMessage: ''),
    );
    try {
      final users = await _repository.getAll(
        currentRole: currentRole,
        currentCompanyId: currentCompanyId,
        currentClientCompanyId: currentClientCompanyId,
      );
      emit(state.copyWith(status: UserManagementStatus.loaded, users: users));
    } catch (e) {
      debugPrint('❌ Error cargando usuarios: $e');
      emit(
        state.copyWith(
          status: UserManagementStatus.failure,
          errorMessage: 'No se pudieron cargar los usuarios: $e',
        ),
      );
    }
  }

  // ─── Create ──────────────────────────────────────────────────────────

  Future<void> _onCreateRequested(
    UserManagementCreateRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      state.copyWith(status: UserManagementStatus.creating, errorMessage: ''),
    );
    try {
      final newUser = await _repository.create(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
        companyId: event.companyId,
        clientCompanyId: event.clientCompanyId,
        phone: event.phone,
      );
      final updated = List<User>.from(state.users)..add(newUser);
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(
        state.copyWith(status: UserManagementStatus.success, users: updated),
      );
    } catch (e) {
      debugPrint('❌ Error creando usuario: $e');
      emit(
        state.copyWith(
          status: UserManagementStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  // ─── Update ──────────────────────────────────────────────────────────

  Future<void> _onUpdateRequested(
    UserManagementUpdateRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      state.copyWith(status: UserManagementStatus.updating, errorMessage: ''),
    );
    try {
      final updatedUser = await _repository.update(
        userId: event.userId,
        fullName: event.fullName,
        role: event.role,
        companyId: event.companyId,
        clientCompanyId: event.clientCompanyId,
        phone: event.phone,
        isActive: event.isActive,
      );
      final updated = state.users.map((u) {
        return u.id == event.userId ? updatedUser : u;
      }).toList();
      updated.sort((a, b) => a.name.compareTo(b.name));
      emit(
        state.copyWith(status: UserManagementStatus.success, users: updated),
      );
    } catch (e) {
      debugPrint('❌ Error actualizando usuario: $e');
      emit(
        state.copyWith(
          status: UserManagementStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  // ─── Toggle Active ──────────────────────────────────────────────────

  Future<void> _onToggleActive(
    UserManagementToggleActiveRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      state.copyWith(status: UserManagementStatus.updating, errorMessage: ''),
    );
    try {
      await _repository.toggleActive(event.userId, event.isActive);
      final updated = state.users.map((u) {
        return u.id == event.userId ? u.copyWith(isActive: event.isActive) : u;
      }).toList();
      emit(
        state.copyWith(status: UserManagementStatus.success, users: updated),
      );
    } catch (e) {
      debugPrint('❌ Error cambiando estado de usuario: $e');
      emit(
        state.copyWith(
          status: UserManagementStatus.failure,
          errorMessage: _mapError(e),
        ),
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  /// Traduce errores comunes a mensajes amigables en español.
  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'Ya existe un usuario con ese correo electrónico.';
    }
    if (msg.contains('email') && msg.contains('invalid')) {
      return 'El correo electrónico no es válido.';
    }
    if (msg.contains('password') &&
        (msg.contains('short') || msg.contains('weak'))) {
      return 'La contraseña es demasiado débil. Usa al menos 6 caracteres.';
    }
    if (msg.contains('permission') || msg.contains('policy')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    if (msg.contains('not found')) {
      return 'No se encontró el usuario solicitado.';
    }
    return 'Error inesperado. Intenta de nuevo.';
  }
}
