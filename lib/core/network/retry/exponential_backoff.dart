import 'dart:math';

abstract interface class IRetryPolicy {
  Duration nextDelay(int attempt);
  Duration get maxDelay;
  int get maxRetries;
}

class ExponentialBackoff implements IRetryPolicy {
  final Duration baseDelay;
  @override
  final Duration maxDelay;
  @override
  final int maxRetries;
  final double multiplier;

  const ExponentialBackoff({
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.multiplier = 2.0,
  });

  @override
  Duration nextDelay(int attempt) {
    final delay = Duration(
      milliseconds: (baseDelay.inMilliseconds * pow(multiplier, attempt - 1))
          .toInt()
          .clamp(0, maxDelay.inMilliseconds),
    );
    return delay;
  }
}
