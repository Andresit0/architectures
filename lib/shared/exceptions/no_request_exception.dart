part of '_exceptions.lib.dart';

class NoRequestException implements Exception {
  final String method;

  const NoRequestException(this.method);

  @override
  String toString() => 'NoRequestException: Método HTTP "$method" no soportado';
}
