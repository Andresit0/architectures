part of '_exceptions.lib.dart';

class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException: Sin conexión a internet';
}
