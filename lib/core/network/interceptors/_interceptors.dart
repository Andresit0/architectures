import 'package:clean_architecture_sdd_harness/core/network/interceptors/auth_interceptor.dart';
import 'package:clean_architecture_sdd_harness/core/network/retry/exponential_backoff.dart';
import 'package:clean_architecture_sdd_harness/shared/error/retry_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

class CustomInterceptors {
  static AuthInterceptor auth({
    required Future<RetryResult> Function() onRetry,
    required Dio internalDio,
    required VoidCallback onForceLogout,
    IRetryPolicy? retryPolicy,
  }) =>
      AuthInterceptor(
        onRetry: onRetry,
        internalDio: internalDio,
        onForceLogout: onForceLogout,
        retryPolicy: retryPolicy,
      );
}
