import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/app_icons.dart';
import '../home/home_page.dart';
import '../notification/notification_page.dart';
import '../profile/profile_page.dart';

/// Barra de navegación inferior principal.
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: FaIcon(AppIcons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: FaIcon(AppIcons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(AppIcons.profile),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
