import 'package:get_it/get_it.dart';

import '../data/repositories/auth_repository.dart';
import 'auth/authentication_bloc.dart';
import 'login/login_bloc.dart';
import 'permission/permission_bloc.dart';

final getIt = GetIt.instance;

/// Inicializa todas las dependencias de la app.
void serviceLocatorInit() {
  // === Repositorios (Lazy Singletons) ===
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());

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

  // === Servicios (Lazy Singletons) ===
  // getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}
