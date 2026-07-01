part of '_exceptions.lib.dart';

class GoRouterException implements Exception {
  final String message;

  const GoRouterException(this.message);

  @override
  String toString() => 'GoRouterException: $message';
}
