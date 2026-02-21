import 'package:flutter/foundation.dart';

import '../models/company.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../providers/user_provider.dart';

/// Repositorio de usuarios.
///
/// Encapsula la lógica de negocio del CRUD de usuarios
/// y aplica las reglas de permisos por rol.
class UserRepository {
  UserRepository({UserProvider? provider})
    : _provider = provider ?? UserProvider();

  final UserProvider _provider;

  /// Obtener todos los usuarios visibles según el rol del usuario actual.
  ///
  /// - `super_admin`: ve todos los usuarios.
  /// - `admin`: solo ve usuarios de su misma compañía.
  Future<List<User>> getAll({
    required UserRole currentRole,
    String? currentCompanyId,
  }) async {
    try {
      List<Map<String, dynamic>> data;

      if (currentRole == UserRole.superAdmin) {
        data = await _provider.getAll();
      } else if (currentRole == UserRole.admin &&
          currentCompanyId != null &&
          currentCompanyId.isNotEmpty) {
        data = await _provider.getByCompany(currentCompanyId);
      } else {
        return [];
      }

      return data.map(_mapProfileToUser).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo usuarios: $e');
      rethrow;
    }
  }

  /// Crear un nuevo usuario.
  Future<User> create({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? companyId,
    String? phone,
  }) async {
    try {
      final data = await _provider.createUser(
        email: email,
        password: password,
        fullName: fullName,
        role: role.value,
        companyId: companyId,
        phone: phone,
      );
      return _mapProfileToUser(data);
    } catch (e) {
      debugPrint('❌ Error creando usuario: $e');
      rethrow;
    }
  }

  /// Actualizar datos del perfil de un usuario.
  Future<User> update({
    required String userId,
    String? fullName,
    String? role,
    String? companyId,
    String? phone,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (role != null) updates['role'] = role;
      if (companyId != null) updates['company_id'] = companyId;
      if (phone != null) updates['phone'] = phone;
      if (isActive != null) updates['is_active'] = isActive;

      final data = await _provider.updateProfile(userId, updates);
      return _mapProfileToUser(data);
    } catch (e) {
      debugPrint('❌ Error actualizando usuario: $e');
      rethrow;
    }
  }

  /// Activar o desactivar un usuario.
  Future<void> toggleActive(String userId, bool isActive) async {
    try {
      await _provider.toggleActive(userId, isActive);
    } catch (e) {
      debugPrint('❌ Error cambiando estado de usuario: $e');
      rethrow;
    }
  }

  /// Mapea un registro de `profiles` (con company join) a un [User].
  User _mapProfileToUser(Map<String, dynamic> data) {
    final companyData = data['company'];

    // Intentar obtener el email vía campo directo o metadata
    final email = data['email'] as String? ?? '';

    return User(
      id: data['id'] as String? ?? '',
      name: data['full_name'] as String? ?? '',
      email: email,
      avatarUrl: data['avatar_url'] as String?,
      phone: data['phone'] as String?,
      role: UserRole.fromValue(data['role'] as String?),
      company: companyData is Map<String, dynamic>
          ? Company.fromJson(companyData)
          : Company.empty,
      isActive: data['is_active'] as bool? ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'] as String)
          : null,
    );
  }
}
