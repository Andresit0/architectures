part of '_exceptions.lib.dart';

class ServerUnreachableException implements Exception {
  const ServerUnreachableException();

  @override
  String toString() => 'ServerUnreachableException: Server not available';
}
