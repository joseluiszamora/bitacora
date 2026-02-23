import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../providers/city_provider.dart';

/// Repositorio de ciudades (solo lectura).
class CityRepository {
  CityRepository({CityProvider? provider})
    : _provider = provider ?? CityProvider();

  final CityProvider _provider;

  /// Obtener todas las ciudades.
  Future<List<City>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(City.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo ciudades: $e');
      rethrow;
    }
  }

  /// Obtener ciudades por estado/departamento.
  Future<List<City>> getByState(int stateId) async {
    try {
      final data = await _provider.getByState(stateId);
      return data.map(City.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo ciudades del estado $stateId: $e');
      rethrow;
    }
  }

  /// Obtener una ciudad por su ID.
  Future<City?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return City.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo ciudad $id: $e');
      rethrow;
    }
  }
}
