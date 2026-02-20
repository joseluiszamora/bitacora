/// Excepción personalizada para errores de red.
class NetworkException implements Exception {
  const NetworkException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'NetworkException($statusCode): $message';

  /// Crea una excepción a partir de un código de estado HTTP.
  factory NetworkException.fromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return const NetworkException(
          message: 'Solicitud incorrecta. Verifica los datos enviados.',
          statusCode: 400,
        );
      case 401:
        return const NetworkException(
          message: 'No autorizado. Tu sesión ha expirado.',
          statusCode: 401,
        );
      case 403:
        return const NetworkException(
          message: 'No tienes permisos para realizar esta acción.',
          statusCode: 403,
        );
      case 404:
        return const NetworkException(
          message: 'Recurso no encontrado.',
          statusCode: 404,
        );
      case 500:
        return const NetworkException(
          message: 'Error del servidor. Intenta más tarde.',
          statusCode: 500,
        );
      default:
        return NetworkException(
          message: 'Error inesperado (código: $statusCode).',
          statusCode: statusCode,
        );
    }
  }
}
