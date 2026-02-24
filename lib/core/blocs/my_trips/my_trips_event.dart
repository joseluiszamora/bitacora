part of 'my_trips_bloc.dart';

sealed class MyTripsEvent extends Equatable {
  const MyTripsEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar los viajes del usuario actual.
final class MyTripsLoadRequested extends MyTripsEvent {
  const MyTripsLoadRequested({
    required this.userId,
    required this.role,
    this.companyId,
  });

  final String userId;
  final UserRole role;
  final String? companyId;

  @override
  List<Object?> get props => [userId, role, companyId];
}
