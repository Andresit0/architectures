import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

abstract interface class IRetryExecutor {
  Future<HttpResponse<Map<String, dynamic>>> retryOrTimeout({
    required bool retryOnTimeout,
    required int maxRetries,
    required Duration baseDelay,
    required int attempt,
    required Uri uri,
    required Duration timeout,
    required Future<HttpResponse<Map<String, dynamic>>> Function() reExecute,
  });
}

class RetryExecutor implements IRetryExecutor {
  const RetryExecutor();

  @override
  Future<HttpResponse<Map<String, dynamic>>> retryOrTimeout({
    required bool retryOnTimeout,
    required int maxRetries,
    required Duration baseDelay,
    required int attempt,
    required Uri uri,
    required Duration timeout,
    required Future<HttpResponse<Map<String, dynamic>>> Function() reExecute,
  }) async {
    if (retryOnTimeout && attempt < maxRetries) {
      await Future<void>.delayed(baseDelay);
      return reExecute();
    }
    throw AppTimeoutException(
      message:
          'The request timed out for $uri (timeout $timeout, attempt $attempt)',
    );
  }
}
