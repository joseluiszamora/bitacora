import 'package:equatable/equatable.dart';

/// Tipo de media de un log de viaje.
enum TripLogMediaType {
  photo('PHOTO'),
  video('VIDEO');

  const TripLogMediaType(this.value);
  final String value;

  static TripLogMediaType fromValue(String? value) {
    if (value == null) return TripLogMediaType.photo;
    return TripLogMediaType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TripLogMediaType.photo,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    TripLogMediaType.photo => 'Foto',
    TripLogMediaType.video => 'Video',
  };
}

/// Modelo de media asociado a un log de viaje.
///
/// Corresponde a la tabla `trip_log_media` de Supabase.
class TripLogMedia extends Equatable {
  const TripLogMedia({
    required this.id,
    required this.tripLogId,
    required this.url,
    this.type = TripLogMediaType.photo,
    this.caption,
    this.createdAt,
  });

  final String id;
  final String tripLogId;
  final String url;
  final TripLogMediaType type;
  final String? caption;
  final DateTime? createdAt;

  /// Media vacío.
  static const empty = TripLogMedia(id: '', tripLogId: '', url: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Crea un [TripLogMedia] desde un mapa JSON (respuesta de Supabase).
  factory TripLogMedia.fromJson(Map<String, dynamic> json) {
    return TripLogMedia(
      id: json['id'] as String? ?? '',
      tripLogId: json['trip_log_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: TripLogMediaType.fromValue(json['type'] as String?),
      caption: json['caption'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'trip_log_id': tripLogId,
      'url': url,
      'type': type.value,
      'caption': caption,
    };
  }

  TripLogMedia copyWith({
    String? id,
    String? tripLogId,
    String? url,
    TripLogMediaType? type,
    String? caption,
    DateTime? createdAt,
  }) {
    return TripLogMedia(
      id: id ?? this.id,
      tripLogId: tripLogId ?? this.tripLogId,
      url: url ?? this.url,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, tripLogId, url, type, caption, createdAt];
}
