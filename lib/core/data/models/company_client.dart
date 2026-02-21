import 'package:equatable/equatable.dart';

import 'client_company.dart';
import 'company.dart';

/// Modelo de relación transportista ↔ cliente.
///
/// Corresponde a la tabla `company_clients` de Supabase.
/// Representa el vínculo contractual entre una empresa transportista
/// y una empresa cliente.
class CompanyClient extends Equatable {
  const CompanyClient({
    required this.id,
    required this.companyId,
    required this.clientCompanyId,
    this.contractType,
    this.status = 'active',
    this.createdAt,
    this.company,
    this.clientCompany,
  });

  final String id;

  /// ID de la empresa transportista.
  final String companyId;

  /// ID de la empresa cliente.
  final String clientCompanyId;

  /// Tipo de contrato (e.g. 'anual', 'por_viaje', 'exclusivo').
  final String? contractType;

  /// Estado de la relación ('active', 'inactive', 'suspended').
  final String status;

  final DateTime? createdAt;

  /// Empresa transportista (join).
  final Company? company;

  /// Empresa cliente (join).
  final ClientCompany? clientCompany;

  /// Relación vacía.
  static const empty = CompanyClient(
    id: '',
    companyId: '',
    clientCompanyId: '',
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Crea un [CompanyClient] desde un mapa JSON (respuesta de Supabase).
  factory CompanyClient.fromJson(Map<String, dynamic> json) {
    final companyData = json['company'];
    final clientData = json['client_company'];

    return CompanyClient(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      clientCompanyId: json['client_company_id'] as String? ?? '',
      contractType: json['contract_type'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      company: companyData is Map<String, dynamic>
          ? Company.fromJson(companyData)
          : null,
      clientCompany: clientData is Map<String, dynamic>
          ? ClientCompany.fromJson(clientData)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'client_company_id': clientCompanyId,
      'contract_type': contractType,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CompanyClient copyWith({
    String? id,
    String? companyId,
    String? clientCompanyId,
    String? contractType,
    String? status,
    DateTime? createdAt,
    Company? company,
    ClientCompany? clientCompany,
  }) {
    return CompanyClient(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      clientCompanyId: clientCompanyId ?? this.clientCompanyId,
      contractType: contractType ?? this.contractType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      company: company ?? this.company,
      clientCompany: clientCompany ?? this.clientCompany,
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    clientCompanyId,
    contractType,
    status,
    createdAt,
  ];
}
