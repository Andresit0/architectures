part of '_exceptions.lib.dart';

class ServerUnreachableFailure extends Failure {
  const ServerUnreachableFailure() : super('Server under maintenance');
}
