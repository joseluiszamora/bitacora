import 'package:get_it/get_it.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/client_company_repository.dart';
import '../data/repositories/company_client_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/user_repository.dart';
import 'auth/authentication_bloc.dart';
import 'client_company/client_company_bloc.dart';
import 'company/company_bloc.dart';
import 'login/login_bloc.dart';
import 'permission/permission_bloc.dart';
import 'user_management/user_management_bloc.dart';

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

  // === BLoCs globales (Singletons) ===
  getIt.registerSingleton<AuthenticationBloc>(
    AuthenticationBloc(authRepository: getIt<AuthRepository>())
      ..add(const AuthenticationStatusChecked()),
  );

  getIt.registerSingleton<PermissionBloc>(PermissionBloc());

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

  // === Servicios (Lazy Singletons) ===
  // getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}
