part of 'permission_bloc.dart';

final class PermissionState extends Equatable {
  const PermissionState({this.statuses = const {}});

  final Map<Permission, PermissionStatus> statuses;

  PermissionState copyWith({Map<Permission, PermissionStatus>? statuses}) {
    return PermissionState(statuses: statuses ?? this.statuses);
  }

  bool isGranted(Permission permission) {
    return statuses[permission]?.isGranted ?? false;
  }

  @override
  List<Object?> get props => [statuses];
}
