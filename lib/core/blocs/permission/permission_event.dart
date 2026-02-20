part of 'permission_bloc.dart';

sealed class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

final class PermissionRequested extends PermissionEvent {
  const PermissionRequested(this.permission);

  final Permission permission;

  @override
  List<Object?> get props => [permission];
}

final class PermissionStatusChecked extends PermissionEvent {
  const PermissionStatusChecked(this.permission);

  final Permission permission;

  @override
  List<Object?> get props => [permission];
}
