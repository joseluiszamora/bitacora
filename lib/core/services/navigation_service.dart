import 'package:flutter/material.dart';

/// Servicio de navegación global (accesible sin BuildContext).
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get _navigator => navigatorKey.currentState;

  /// Navegar a una ruta nombrada.
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return _navigator!.pushNamed(routeName, arguments: arguments);
  }

  /// Reemplazar la ruta actual.
  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return _navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navegar y limpiar el stack completo.
  Future<dynamic> navigateAndClearStack(String routeName, {Object? arguments}) {
    return _navigator!.pushNamedAndRemoveUntil(
      routeName,
      (_) => false,
      arguments: arguments,
    );
  }

  /// Volver atrás.
  void goBack() {
    _navigator!.pop();
  }
}
