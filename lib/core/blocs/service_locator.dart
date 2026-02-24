import 'package:get_it/get_it.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/city_repository.dart';
import '../data/repositories/client_company_repository.dart';
import '../data/repositories/client_location_repository.dart';
import '../data/repositories/company_client_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/state_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/trip_log_media_repository.dart';
import '../data/repositories/trip_log_repository.dart';
import '../data/repositories/trip_repository.dart';
import '../data/repositories/vehicle_assignment_repository.dart';
import '../data/repositories/vehicle_document_repository.dart';
import '../data/repositories/vehicle_repository.dart';
import 'auth/authentication_bloc.dart';
import 'client_company/client_company_bloc.dart';
import 'client_location/client_location_bloc.dart';
import 'company/company_bloc.dart';
import 'login/login_bloc.dart';
import 'my_trips/my_trips_bloc.dart';
import 'permission/permission_bloc.dart';
import 'theme/theme_cubit.dart';
import 'trip/trip_bloc.dart';
import 'trip_log/trip_log_bloc.dart';
import 'user_management/user_management_bloc.dart';
import 'vehicle/vehicle_bloc.dart';
import 'vehicle_assignment/vehicle_assignment_bloc.dart';

final getIt = GetIt.instance;

/// Inicializa todas las dependencias de la app.
void serviceLocatorInit() {
  // === Repositorios (Lazy Singletons) ===
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<CompanyRepository>(() => CompanyRepository());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  getIt.registerLazySingleton<ClientCompanyRepository>(
    () => ClientCompanyRepository(),
  );
  getIt.registerLazySingleton<CompanyClientRepository>(
    () => CompanyClientRepository(),
  );
  getIt.registerLazySingleton<VehicleRepository>(() => VehicleRepository());
  getIt.registerLazySingleton<VehicleDocumentRepository>(
    () => VehicleDocumentRepository(),
  );
  getIt.registerLazySingleton<TripRepository>(() => TripRepository());
  getIt.registerLazySingleton<TripLogRepository>(() => TripLogRepository());
  getIt.registerLazySingleton<TripLogMediaRepository>(
    () => TripLogMediaRepository(),
  );
  getIt.registerLazySingleton<VehicleAssignmentRepository>(
    () => VehicleAssignmentRepository(),
  );
  getIt.registerLazySingleton<CityRepository>(() => CityRepository());
  getIt.registerLazySingleton<StateRepository>(() => StateRepository());
  getIt.registerLazySingleton<ClientLocationRepository>(
    () => ClientLocationRepository(),
  );

  // === BLoCs globales (Singletons) ===
  getIt.registerSingleton<AuthenticationBloc>(
    AuthenticationBloc(authRepository: getIt<AuthRepository>())
      ..add(const AuthenticationStatusChecked()),
  );

  getIt.registerSingleton<PermissionBloc>(PermissionBloc());

  getIt.registerSingleton<ThemeCubit>(ThemeCubit());

  // === BLoCs de feature (Factory — se crean por pantalla) ===
  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<CompanyBloc>(
    () => CompanyBloc(companyRepository: getIt<CompanyRepository>()),
  );

  getIt.registerFactory<ClientCompanyBloc>(
    () => ClientCompanyBloc(
      clientCompanyRepository: getIt<ClientCompanyRepository>(),
    ),
  );

  getIt.registerFactory<UserManagementBloc>(
    () => UserManagementBloc(
      currentRole: getIt<AuthenticationBloc>().state.user.role,
      currentCompanyId: getIt<AuthenticationBloc>().state.user.company.id,
      currentClientCompanyId:
          getIt<AuthenticationBloc>().state.user.clientCompany.id,
      userRepository: getIt<UserRepository>(),
    ),
  );

  getIt.registerFactory<VehicleBloc>(
    () => VehicleBloc(vehicleRepository: getIt<VehicleRepository>()),
  );

  getIt.registerFactory<TripBloc>(
    () => TripBloc(tripRepository: getIt<TripRepository>()),
  );

  getIt.registerFactory<TripLogBloc>(
    () => TripLogBloc(tripLogRepository: getIt<TripLogRepository>()),
  );

  getIt.registerFactory<VehicleAssignmentBloc>(() => VehicleAssignmentBloc());

  getIt.registerFactory<ClientLocationBloc>(() => ClientLocationBloc());

  getIt.registerFactory<MyTripsBloc>(
    () => MyTripsBloc(tripRepository: getIt<TripRepository>()),
  );

  // === Servicios (Lazy Singletons) ===
  // getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}
