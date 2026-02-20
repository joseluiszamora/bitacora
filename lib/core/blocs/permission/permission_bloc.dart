import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permission_event.dart';
part 'permission_state.dart';

/// BLoC para gestionar permisos del dispositivo.
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(const PermissionState()) {
    on<PermissionRequested>(_onRequested);
    on<PermissionStatusChecked>(_onStatusChecked);
  }

  Future<void> _onRequested(
    PermissionRequested event,
    Emitter<PermissionState> emit,
  ) async {
    final status = await event.permission.request();
    emit(
      state.copyWith(statuses: {...state.statuses, event.permission: status}),
    );
  }

  Future<void> _onStatusChecked(
    PermissionStatusChecked event,
    Emitter<PermissionState> emit,
  ) async {
    final status = await event.permission.status;
    emit(
      state.copyWith(statuses: {...state.statuses, event.permission: status}),
    );
  }
}
