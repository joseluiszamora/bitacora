part of 'user_management_bloc.dart';

sealed class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar la lista de usuarios.
final class UserManagementLoadRequested extends UserManagementEvent {
  const UserManagementLoadRequested();
}

/// Crear un nuevo usuario.
final class UserManagementCreateRequested extends UserManagementEvent {
  const UserManagementCreateRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.companyId,
    this.phone,
  });

  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final String? companyId;
  final String? phone;

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    role,
    companyId,
    phone,
  ];
}

/// Actualizar un usuario existente.
final class UserManagementUpdateRequested extends UserManagementEvent {
  const UserManagementUpdateRequested({
    required this.userId,
    this.fullName,
    this.role,
    this.companyId,
    this.phone,
    this.isActive,
  });

  final String userId;
  final String? fullName;
  final String? role;
  final String? companyId;
  final String? phone;
  final bool? isActive;

  @override
  List<Object?> get props => [
    userId,
    fullName,
    role,
    companyId,
    phone,
    isActive,
  ];
}

/// Activar/desactivar un usuario.
final class UserManagementToggleActiveRequested extends UserManagementEvent {
  const UserManagementToggleActiveRequested({
    required this.userId,
    required this.isActive,
  });

  final String userId;
  final bool isActive;

  @override
  List<Object?> get props => [userId, isActive];
}
