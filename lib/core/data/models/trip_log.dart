import 'package:equatable/equatable.dart';

import 'trip.dart';
import 'trip_log_media.dart';
import 'user.dart';

/// Tipo de evento de un log de viaje.
enum TripLogEventType {
  assigned('ASSIGNED'),
  started('STARTED'),
  arrivedAtOrigin('ARRIVED_AT_ORIGIN'),
  loadingStarted('LOADING_STARTED'),
  loadingCompleted('LOADING_COMPLETED'),
  departed('DEPARTED'),
  arrivedAtStop('ARRIVED_AT_STOP'),
  incident('INCIDENT'),
  delay('DELAY'),
  arrivedAtDestination('ARRIVED_AT_DESTINATION'),
  unloadingStarted('UNLOADING_STARTED'),
  unloadingCompleted('UNLOADING_COMPLETED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const TripLogEventType(this.value);
  final String value;

  static TripLogEventType fromValue(String? value) {
    if (value == null) return TripLogEventType.assigned;
    return TripLogEventType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TripLogEventType.assigned,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    TripLogEventType.assigned => 'Asignado',
    TripLogEventType.started => 'Iniciado',
    TripLogEventType.arrivedAtOrigin => 'Llegó al Origen',
    TripLogEventType.loadingStarted => 'Carga Iniciada',
    TripLogEventType.loadingCompleted => 'Carga Completada',
    TripLogEventType.departed => 'En Camino',
    TripLogEventType.arrivedAtStop => 'Llegó a Parada',
    TripLogEventType.incident => 'Incidente',
    TripLogEventType.delay => 'Retraso',
    TripLogEventType.arrivedAtDestination => 'Llegó al Destino',
    TripLogEventType.unloadingStarted => 'Descarga Iniciada',
    TripLogEventType.unloadingCompleted => 'Descarga Completada',
    TripLogEventType.completed => 'Completado',
    TripLogEventType.cancelled => 'Cancelado',
  };

  /// Ícono representativo del evento.
  String get icon => switch (this) {
    TripLogEventType.assigned => '📋',
    TripLogEventType.started => '🚀',
    TripLogEventType.arrivedAtOrigin => '📍',
    TripLogEventType.loadingStarted => '📦',
    TripLogEventType.loadingCompleted => '✅',
    TripLogEventType.departed => '🚛',
    TripLogEventType.arrivedAtStop => '🛑',
    TripLogEventType.incident => '⚠️',
    TripLogEventType.delay => '⏱️',
    TripLogEventType.arrivedAtDestination => '🏁',
    TripLogEventType.unloadingStarted => '📦',
    TripLogEventType.unloadingCompleted => '✅',
    TripLogEventType.completed => '🎉',
    TripLogEventType.cancelled => '❌',
  };
}

/// Modelo de log de viaje.
///
/// Corresponde a la tabla `trip_logs` de Supabase.
class TripLog extends Equatable {
  const TripLog({
    required this.id,
    required this.tripId,
    this.userId,
    this.driverId,
    required this.eventType,
    this.description,
    this.latitude,
    this.longitude,
    this.metadata,
    this.createdAt,
    this.trip,
    this.user,
    this.driver,
    this.media = const [],
  });

  final String id;
  final String tripId;
  final String? userId;
  final String? driverId;
  final TripLogEventType eventType;
  final String? description;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  /// Relaciones (joins).
  final Trip? trip;
  final User? user;
  final User? driver;
  final List<TripLogMedia> media;

  /// TripLog vacío.
  static const empty = TripLog(
    id: '',
    tripId: '',
    eventType: TripLogEventType.assigned,
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Resumen legible del evento.
  String get displayName => '${eventType.icon} ${eventType.label}';

  /// Indica si el log tiene ubicación GPS registrada.
  bool get hasLocation => latitude != null && longitude != null;

  /// Crea un [TripLog] desde un mapa JSON (respuesta de Supabase).
  factory TripLog.fromJson(Map<String, dynamic> json) {
    // Parsear media anidados.
    final rawMedia = json['media'];
    final mediaList = (rawMedia is List)
        ? rawMedia
              .whereType<Map<String, dynamic>>()
              .map(TripLogMedia.fromJson)
              .toList()
        : <TripLogMedia>[];

    // Parsear metadata JSONB.
    final rawMeta = json['metadata'];
    final metadataMap = rawMeta is Map<String, dynamic> ? rawMeta : null;

    return TripLog(
      id: json['id'] as String? ?? '',
      tripId: json['trip_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      driverId: json['driver_id'] as String?,
      eventType: TripLogEventType.fromValue(json['event_type'] as String?),
      description: json['description'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      metadata: metadataMap,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      trip: json['trip'] != null && json['trip'] is Map
          ? Trip.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null && json['user'] is Map
          ? User.fromProfile(json['user'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null && json['driver'] is Map
          ? User.fromProfile(json['driver'] as Map<String, dynamic>)
          : null,
      media: mediaList,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  /// No incluye `id`, `created_at` ni las relaciones (son joins).
  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'user_id': userId,
      'driver_id': driverId,
      'event_type': eventType.value,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'metadata': metadata,
    };
  }

  TripLog copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? driverId,
    TripLogEventType? eventType,
    String? description,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    Trip? trip,
    User? user,
    User? driver,
    List<TripLogMedia>? media,
  }) {
    return TripLog(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      trip: trip ?? this.trip,
      user: user ?? this.user,
      driver: driver ?? this.driver,
      media: media ?? this.media,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tripId,
    userId,
    driverId,
    eventType,
    description,
    latitude,
    longitude,
    metadata,
    createdAt,
    trip,
    user,
    driver,
    media,
  ];
}
