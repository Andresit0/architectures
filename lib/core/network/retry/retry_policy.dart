class RetryPolicy {
  final int maxRetries;
  final bool retryOnTimeout;
  final Duration baseDelay;

  const RetryPolicy({
    this.maxRetries = 0,
    this.retryOnTimeout = false,
    this.baseDelay = const Duration(seconds: 1),
  });

  static const standard = RetryPolicy();
  static const idempotent = RetryPolicy(
    maxRetries: 2,
    retryOnTimeout: true,
  );
}
