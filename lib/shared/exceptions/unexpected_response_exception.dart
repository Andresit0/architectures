part of '_exceptions.lib.dart';

class UnexpectedResponseException implements Exception {
  final String details;

  const UnexpectedResponseException(this.details);

  @override
  String toString() => 'UnexpectedResponseException: $details';
}
