import 'package:equatable/equatable.dart';

/// Modelo de departamento/estado.
///
/// Corresponde a la tabla `states` de Supabase.
/// Cada estado puede tener múltiples ciudades.
class AppState extends Equatable {
  const AppState({
    required this.id,
    required this.name,
    this.code,
    this.countryCode,
  });

  final int id;
  final String name;
  final String? code;
  final String? countryCode;

  /// Estado vacío.
  static const empty = AppState(id: 0, name: '');

  bool get isEmpty => id == 0;
  bool get isNotEmpty => !isEmpty;

  /// Nombre legible.
  String get displayName {
    if (code != null && code!.isNotEmpty) {
      return '$name ($code)';
    }
    return name;
  }

  /// Crea un [AppState] desde un mapa JSON (respuesta de Supabase).
  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'country_code': countryCode};
  }

  AppState copyWith({
    int? id,
    String? name,
    String? code,
    String? countryCode,
  }) {
    return AppState(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  @override
  List<Object?> get props => [id, name, code, countryCode];
}
