import 'package:equatable/equatable.dart';

/// Modelo de usuario.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;

  /// Usuario vacío (no autenticado).
  static const empty = User(id: '', name: '', email: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => !isEmpty;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
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
    };
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, phone];
}
