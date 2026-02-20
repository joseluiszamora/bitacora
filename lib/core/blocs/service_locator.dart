import 'package:get_it/get_it.dart';

import 'auth/authentication_bloc.dart';
import 'permission/permission_bloc.dart';

final getIt = GetIt.instance;

/// Inicializa todas las dependencias de la app.
void serviceLocatorInit() {
  // === BLoCs globales (Singletons) ===
  getIt.registerSingleton<AuthenticationBloc>(
    AuthenticationBloc()..add(const AuthenticationStatusChecked()),
  );

  getIt.registerSingleton<PermissionBloc>(PermissionBloc());

  // === BLoCs de feature (Factory — se crean por pantalla) ===
  // getIt.registerFactory<BitacoraFormBloc>(() => BitacoraFormBloc());

  // === Servicios (Lazy Singletons) ===
  // getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}
