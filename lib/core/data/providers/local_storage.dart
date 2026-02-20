import 'package:shared_preferences/shared_preferences.dart';

/// Acceso centralizado a almacenamiento local.
///
/// NOTA: Supabase maneja los tokens (access, refresh) internamente
/// usando su propio almacenamiento seguro. No es necesario guardarlos
/// manualmente con FlutterSecureStorage.
///
/// Esta clase se usa solo para preferencias de la app.
class LocalStorage {
  LocalStorage._();

  // === Claves ===
  static const String _themeKey = 'app_theme';
  static const String _onboardingKey = 'onboarding_complete';

  // === Preferencias (Shared Preferences) ===

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, complete);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // === Limpiar todo ===

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
