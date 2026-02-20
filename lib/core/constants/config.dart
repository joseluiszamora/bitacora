import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración global de la aplicación.
class Config {
  Config._();

  // === Supabase ===
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Timeouts (en milisegundos)
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;

  // Keys
  static const String appName = 'BITACORA de Transporte';
  static const String bundleId = 'bo.monval.bitacora';
}
