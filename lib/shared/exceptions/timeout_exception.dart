class AppTimeoutException implements Exception {
  final String message;
  final String? endpoint;
  final Duration? configuredTimeout;
  final int? attemptNumber;
  final DateTime timestamp;

  AppTimeoutException({
    this.message = 'The request timed out',
    this.endpoint,
    this.configuredTimeout,
    this.attemptNumber,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'AppTimeoutException: $message';
}
