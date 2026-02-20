import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/config.dart';

/// Cliente centralizado de Supabase.
///
/// Proporciona acceso a:
/// - `supabase` → Instancia de SupabaseClient (auth, database, storage, realtime).
/// - `dio` → Cliente Dio para APIs REST externas (si se requieren).
class ApiClient {
  ApiClient._();

  // === Supabase ===

  /// Instancia principal del cliente Supabase.
  static SupabaseClient get supabase => Supabase.instance.client;

  /// Acceso rápido al módulo de autenticación.
  static GoTrueClient get auth => supabase.auth;

  /// Sesión activa del usuario (null si no autenticado).
  static Session? get currentSession => supabase.auth.currentSession;

  /// Usuario actual (null si no autenticado).
  static User? get currentUser => supabase.auth.currentUser;

  // === Dio (para APIs REST externas) ===

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(milliseconds: Config.connectTimeout),
      receiveTimeout: const Duration(milliseconds: Config.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(_SupabaseTokenInterceptor());

  /// Cliente Dio para llamadas HTTP externas (no-Supabase).
  static Dio get dio => _dio;
}

/// Interceptor que inyecta el token de Supabase en llamadas Dio.
class _SupabaseTokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inyectar token de Supabase automáticamente si hay sesión activa
    if (options.headers.containsKey('requiresToken')) {
      options.headers.remove('requiresToken');
      final token = ApiClient.currentSession?.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ DioError: [${err.type}] ${err.message}');
    handler.next(err);
  }
}
