import 'package:flutter/foundation.dart';

import '../models/app_state.dart';
import '../providers/state_provider.dart';

/// Repositorio de estados/departamentos (solo lectura).
class StateRepository {
  StateRepository({StateProvider? provider})
    : _provider = provider ?? StateProvider();

  final StateProvider _provider;

  /// Obtener todos los estados.
  Future<List<AppState>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(AppState.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo estados: $e');
      rethrow;
    }
  }

  /// Obtener estados por código de país.
  Future<List<AppState>> getByCountryCode(String countryCode) async {
    try {
      final data = await _provider.getByCountryCode(countryCode);
      return data.map(AppState.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo estados de $countryCode: $e');
      rethrow;
    }
  }

  /// Obtener un estado por su ID.
  Future<AppState?> getById(int id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return AppState.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo estado $id: $e');
      rethrow;
    }
  }
}
