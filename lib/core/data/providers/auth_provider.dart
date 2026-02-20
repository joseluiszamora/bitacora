import 'package:dio/dio.dart';

import '../api/api_client.dart';

/// Provider de autenticación — llamadas HTTP.
class AuthProvider {
  Dio get _dio => ApiClient.dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(
      '/auth/profile',
      options: Options(headers: {'requiresToken': true}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post(
      '/auth/logout',
      options: Options(headers: {'requiresToken': true}),
    );
  }
}
