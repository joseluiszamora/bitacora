part of 'user_management_bloc.dart';

enum UserManagementStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  success,
  failure,
}

final class UserManagementState extends Equatable {
  const UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const [],
    this.errorMessage = '',
  });

  final UserManagementStatus status;
  final List<User> users;
  final String errorMessage;

  bool get isIdle =>
      status == UserManagementStatus.initial ||
      status == UserManagementStatus.loaded ||
      status == UserManagementStatus.success ||
      status == UserManagementStatus.failure;

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<User>? users,
    String? errorMessage,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
