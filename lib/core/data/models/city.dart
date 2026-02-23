import 'package:equatable/equatable.dart';

import 'app_state.dart';

/// Modelo de ciudad.
///
/// Corresponde a la tabla `cities` de Supabase.
/// Utilizada para asociar ubicaciones de clientes a una ciudad.
/// Cada ciudad pertenece a un [AppState] (departamento/estado).
class City extends Equatable {
  const City({
    required this.id,
    required this.name,
    this.stateId,
    this.stateName,
    this.latitude,
    this.longitude,
    this.state,
  });

  final String id;
  final String name;
  final int? stateId;
  final String? stateName;
  final double? latitude;
  final double? longitude;

  /// Relación (join).
  final AppState? state;

  /// Ciudad vacía.
  static const empty = City(id: '', name: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Nombre legible con estado/departamento.
  String get displayName {
    // Preferir el nombre del join si existe
    final sName = state?.name ?? stateName;
    if (sName != null && sName.isNotEmpty) {
      return '$name, $sName';
    }
    return name;
  }

  /// Crea una [City] desde un mapa JSON (respuesta de Supabase).
  factory City.fromJson(Map<String, dynamic> json) {
    // Soporta joins anidados: state:states(*)
    final stateData = json['state'];
    String? sName;
    AppState? stateObj;
    if (stateData is Map<String, dynamic>) {
      stateObj = AppState.fromJson(stateData);
      sName = stateObj.name;
    }

    return City(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      stateId: json['state_id'] as int?,
      stateName: sName,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      state: stateObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state_id': stateId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  City copyWith({
    String? id,
    String? name,
    int? stateId,
    String? stateName,
    double? latitude,
    double? longitude,
    AppState? state,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      stateId: stateId ?? this.stateId,
      stateName: stateName ?? this.stateName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    stateId,
    stateName,
    latitude,
    longitude,
    state,
  ];
}
