part of '_exceptions.lib.dart';

class ServerUnreachableFailure extends Failure {
  const ServerUnreachableFailure() : super('Estamos en mantenimiento');
}
