import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/constants/app_icons.dart';
import '../../core/data/models/user_role.dart';
import '../finance/finance_page.dart';
import '../home/home_page.dart';
import '../my_trips/my_trips_page.dart';
import '../notification/notification_page.dart';
import '../profile/profile_page.dart';
import '../trip_map/trip_map_page.dart';

/// Barra de navegación inferior principal.
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  /// Roles que pueden ver la pestaña "Mis Viajes".
  static const _rolesWithMyTrips = {
    UserRole.superAdmin,
    UserRole.admin,
    UserRole.supervisor,
    UserRole.driver,
  };

  /// Roles que pueden ver la pestaña "Mapa de Viajes".
  static const _rolesWithTripMap = {
    UserRole.superAdmin,
    UserRole.admin,
    UserRole.supervisor,
  };

  /// Roles que pueden ver la pestaña "Finanzas".
  static const _rolesWithFinance = {
    UserRole.superAdmin,
    UserRole.admin,
    UserRole.supervisor,
  };

  bool _showMyTrips(UserRole role) => _rolesWithMyTrips.contains(role);
  bool _showTripMap(UserRole role) => _rolesWithTripMap.contains(role);
  bool _showFinance(UserRole role) => _rolesWithFinance.contains(role);

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthenticationBloc>().state.user.role;
    final hasMyTrips = _showMyTrips(role);
    final hasTripMap = _showTripMap(role);
    final hasFinance = _showFinance(role);

    final pages = <Widget>[
      const HomePage(),
      if (hasMyTrips) const MyTripsPage(),
      if (hasTripMap) const TripMapPage(),
      if (hasFinance) const FinancePage(),
      const NotificationPage(),
      const ProfilePage(),
    ];

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: FaIcon(AppIcons.home),
        label: 'Inicio',
      ),
      if (hasMyTrips)
        const BottomNavigationBarItem(
          icon: FaIcon(AppIcons.route),
          label: 'Mis Viajes',
        ),
      if (hasTripMap)
        const BottomNavigationBarItem(
          icon: FaIcon(AppIcons.map),
          label: 'Mapa',
        ),
      if (hasFinance)
        const BottomNavigationBarItem(
          icon: FaIcon(AppIcons.finance),
          label: 'Finanzas',
        ),
      const BottomNavigationBarItem(
        icon: FaIcon(AppIcons.notifications),
        label: 'Notificaciones',
      ),
      const BottomNavigationBarItem(
        icon: FaIcon(AppIcons.profile),
        label: 'Perfil',
      ),
    ];

    // Asegurar que el índice no exceda el número de tabs disponibles.
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
