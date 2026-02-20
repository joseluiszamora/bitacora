import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/blocs/auth/authentication_bloc.dart';
import 'core/blocs/service_locator.dart';
import 'core/constants/config.dart';
import 'core/themes/app_theme.dart';
import 'views/auth/login_page.dart';
import 'views/navigation/navigation_page.dart';
import 'views/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicializar Supabase
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  // Inicializar Service Locator (GetIt)
  serviceLocatorInit();

  runApp(const BitacoraApp());
}

class BitacoraApp extends StatelessWidget {
  const BitacoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: getIt<AuthenticationBloc>())],
      child: MaterialApp(
        title: 'BITACORA de Transporte',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.unknown:
                return const SplashPage();
              case AuthenticationStatus.authenticated:
                return const NavigationPage();
              case AuthenticationStatus.unauthenticated:
                return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
