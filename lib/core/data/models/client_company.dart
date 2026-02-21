import 'package:equatable/equatable.dart';

/// Modelo de empresa cliente.
///
/// Corresponde a la tabla `client_companies` de Supabase.
/// Son las empresas que contratan viajes a las transportistas.
class ClientCompany extends Equatable {
  const ClientCompany({
    required this.id,
    required this.name,
    this.nit,
    this.address,
    this.contactEmail,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? nit;
  final String? address;
  final String? contactEmail;
  final DateTime? createdAt;

  /// Empresa cliente vacía.
  static const empty = ClientCompany(id: '', name: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Crea una [ClientCompany] desde un mapa JSON (respuesta de Supabase).
  factory ClientCompany.fromJson(Map<String, dynamic> json) {
    return ClientCompany(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nit: json['nit'] as String?,
      address: json['address'] as String?,
      contactEmail: json['contact_email'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nit': nit,
      'address': address,
      'contact_email': contactEmail,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ClientCompany copyWith({
    String? id,
    String? name,
    String? nit,
    String? address,
    String? contactEmail,
    DateTime? createdAt,
  }) {
    return ClientCompany(
      id: id ?? this.id,
      name: name ?? this.name,
      nit: nit ?? this.nit,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, nit, address, contactEmail, createdAt];
}
