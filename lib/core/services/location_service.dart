import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio centralizado de geolocalización.
///
/// Maneja permisos y obtención de la posición GPS del dispositivo.
class LocationService {
  LocationService._();

  /// Verifica y solicita permisos de ubicación.
  /// Retorna `true` si se obtuvo permiso, `false` si fue denegado.
  static Future<bool> requestPermission() async {
    // Verificar si el servicio de ubicación está habilitado.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ Servicio de ubicación deshabilitado.');
      return false;
    }

    // Verificar permisos actuales.
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Permiso de ubicación denegado.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('⚠️ Permiso de ubicación denegado permanentemente.');
      return false;
    }

    return true;
  }

  /// Obtiene la posición actual del dispositivo.
  ///
  /// Retorna `null` si no se pudo obtener la posición
  /// (permisos denegados o servicio deshabilitado).
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return position;
    } catch (e) {
      debugPrint('❌ Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Verifica si los servicios de ubicación están habilitados.
  static Future<bool> isServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Verifica si ya se tienen permisos de ubicación.
  static Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Mensaje de error descriptivo según el estado del permiso.
  static Future<String> getPermissionMessage() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'El servicio de ubicación está deshabilitado. '
          'Actívalo en la configuración del dispositivo.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return 'El permiso de ubicación fue denegado permanentemente. '
          'Ve a Configuración > Apps > Bitácora > Permisos para habilitarlo.';
    }
    if (permission == LocationPermission.denied) {
      return 'Se necesita permiso de ubicación para registrar la posición GPS.';
    }

    return '';
  }
}
