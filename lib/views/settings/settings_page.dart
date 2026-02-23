import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/theme/theme_cubit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

/// Pantalla de configuración.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDefaults.margin),

              // Sección: Apariencia
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Apariencia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _ThemeOption(
                          icon: Icons.phone_android,
                          title: 'Igual al dispositivo',
                          subtitle: 'Usa la configuración del sistema',
                          isSelected: state.themeMode == ThemeMode.system,
                          onTap: () => context.read<ThemeCubit>().setThemeMode(
                            ThemeMode.system,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ThemeOption(
                          icon: Icons.light_mode,
                          title: 'Modo Claro',
                          subtitle: 'Fondo claro con texto oscuro',
                          isSelected: state.themeMode == ThemeMode.light,
                          onTap: () => context.read<ThemeCubit>().setThemeMode(
                            ThemeMode.light,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ThemeOption(
                          icon: Icons.dark_mode,
                          title: 'Modo Oscuro',
                          subtitle: 'Fondo oscuro con texto claro',
                          isSelected: state.themeMode == ThemeMode.dark,
                          onTap: () => context.read<ThemeCubit>().setThemeMode(
                            ThemeMode.dark,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppDefaults.marginBig),

              // Info de la app
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 32,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'BITACORA de Transporte',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opción de tema individual.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isSelected ? AppColors.primary : AppColors.grey).withAlpha(
            26,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.grey,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.grey.withAlpha(179)),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : Icon(Icons.circle_outlined, color: AppColors.grey.withAlpha(77)),
      onTap: onTap,
    );
  }
}
