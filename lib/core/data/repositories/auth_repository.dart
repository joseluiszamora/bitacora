import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/local_storage.dart';

/// Repositorio de autenticación.
/// Orquesta llamadas entre AuthProvider y LocalStorage.
class AuthRepository {
  AuthRepository({AuthProvider? authProvider})
    : _authProvider = authProvider ?? AuthProvider();

  final AuthProvider _authProvider;

  Future<User> login({required String email, required String password}) async {
    final data = await _authProvider.login(email: email, password: password);

    final token = data['token'] as String?;
    if (token != null) {
      await LocalStorage.saveToken(token);
    }

    final refreshToken = data['refresh_token'] as String?;
    if (refreshToken != null) {
      await LocalStorage.saveRefreshToken(refreshToken);
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> getProfile() async {
    final data = await _authProvider.getProfile();
    return User.fromJson(data);
  }

  Future<void> logout() async {
    await _authProvider.logout();
    await LocalStorage.deleteTokens();
  }

  Future<bool> isAuthenticated() async {
    final token = await LocalStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
