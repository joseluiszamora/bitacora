/// Configuración global de la aplicación.
class Config {
  Config._();

  // URLs base de la API
  static const String baseMTVirtual = 'https://api.example.com/v1';

  // Timeouts (en milisegundos)
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;

  // Keys
  static const String appName = 'BITACORA de Transporte';
  static const String bundleId = 'bo.monval.bitacora';
}
