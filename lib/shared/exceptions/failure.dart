part of '_exceptions.lib.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}
