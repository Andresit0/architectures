part of '_exceptions.lib.dart';

class ApiException implements Exception {
  final int statusCode;

  const ApiException(this.statusCode);

  @override
  String toString() =>
      'ApiException($statusCode): La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.';
}
