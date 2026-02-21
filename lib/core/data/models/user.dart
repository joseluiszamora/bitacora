import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'company.dart';
import 'user_role.dart';

/// Modelo de usuario de la app.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.role = UserRole.driver,
    this.company = Company.empty,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final UserRole role;
  final Company company;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Usuario vacío (no autenticado).
  static const empty = User(id: '', name: '', email: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => !isEmpty;

  /// Verifica si el usuario tiene permisos iguales o superiores al rol dado.
  bool hasPermission(UserRole requiredRole) => role.hasPermission(requiredRole);

  /// Crea un [User] desde un [sb.User] de Supabase Auth.
  factory User.fromSupabaseUser(sb.User supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};
    return User(
      id: supabaseUser.id,
      name:
          metadata['name'] as String? ?? metadata['full_name'] as String? ?? '',
      email: supabaseUser.email ?? '',
      avatarUrl: metadata['avatar_url'] as String?,
      phone: supabaseUser.phone,
    );
  }

  /// Crea un [User] desde la respuesta de la RPC `get_my_profile()`.
  ///
  /// Espera un JSON con los campos del perfil + un objeto `company` anidado.
  factory User.fromProfile(Map<String, dynamic> json) {
    final companyData = json['company'];
    return User(
      id: json['id'] as String? ?? '',
      name: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      role: UserRole.fromValue(json['role'] as String?),
      company: companyData is Map<String, dynamic>
          ? Company.fromJson(companyData)
          : Company.empty,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Crea un [User] desde un mapa JSON genérico.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'phone': phone,
      'role': role.value,
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    UserRole? role,
    Company? company,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      company: company ?? this.company,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    avatarUrl,
    phone,
    role,
    company,
    isActive,
    createdAt,
    updatedAt,
  ];
}
