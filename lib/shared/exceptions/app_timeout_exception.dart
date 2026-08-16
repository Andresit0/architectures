class AppTimeoutException implements Exception {
  final String message;

  const AppTimeoutException({this.message = 'The request timed out'});

  @override
  String toString() => 'AppTimeoutException: $message';
}
