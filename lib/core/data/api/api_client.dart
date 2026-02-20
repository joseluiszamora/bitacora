import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/config.dart';
import '../providers/local_storage.dart';

/// Cliente HTTP centralizado con Dio.
class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Config.baseMTVirtual,
      connectTimeout: const Duration(milliseconds: Config.connectTimeout),
      receiveTimeout: const Duration(milliseconds: Config.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(AppInterceptors());

  static Dio get dio => _dio;
}

/// Interceptores de la app para manejo de token y errores.
class AppInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('requiresToken')) {
      options.headers.remove('requiresToken');
      final token = await LocalStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ DioError: [${err.type}] ${err.message}');

    if (err.response?.statusCode == 401) {
      // Token expirado — redirigir a logout
      debugPrint('🔒 Token expirado. Redirigiendo a logout...');
      // TODO: Emitir evento de logout via GetIt
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}
