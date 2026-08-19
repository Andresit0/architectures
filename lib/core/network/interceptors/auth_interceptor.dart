import 'package:clean_architecture_sdd_harness/core/network/retry/exponential_backoff.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._onRetry,
    required this._internalDio,
    required this._onForceLogout,
    required this._getToken,
    IRetryPolicy? retryPolicy,
  }) : _retryPolicy = retryPolicy ?? const ExponentialBackoff();

  final Future<RetryResult> Function() _onRetry;
  final Dio _internalDio;
  final VoidCallback _onForceLogout;
  final Future<String?> Function() _getToken;
  final IRetryPolicy _retryPolicy;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['Authorization'] == null) {
      final token = await _getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    if (_isRefreshing) return handler.next(err);
    _isRefreshing = true;

    try {
      for (int attempt = 1; attempt <= _retryPolicy.maxRetries; attempt++) {
        final result = await _onRetry();
        switch (result) {
          case RetrySuccess(:final token):
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _internalDio.fetch<dynamic>(
                err.requestOptions,
              );
              handler.resolve(response);
              return;
            } catch (_) {}
          case RetryFailed():
            _onForceLogout();
            handler.next(err);
            return;
          case RetryNoConnection():
            if (attempt < _retryPolicy.maxRetries) {
              await Future<void>.delayed(_retryPolicy.nextDelay(attempt));
            }
        }
      }
    } finally {
      _isRefreshing = false;
    }

    handler.next(err);
  }
}
