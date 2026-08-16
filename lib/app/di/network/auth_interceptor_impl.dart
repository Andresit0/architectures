import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

class AuthInterceptorImpl implements IAuthInterceptorProvider {
  AuthInterceptorImpl({
    required this._handle401UseCase,
    required this._onForceLogout,
    required this._getToken,
  });

  final IUseCase<NoParams, RetryResult> _handle401UseCase;
  final VoidCallback _onForceLogout;
  final Future<String?> Function() _getToken;

  @override
  void setupAuthInterceptor(IDioWrapper dioWrapper) {
    dioWrapper.addAuthInterceptor(
      () async {
        final result = await _handle401UseCase(NoParams());
        return switch (result) {
          Success(data: final retryResult) => retryResult,
          Failure() => const RetryFailed(),
        };
      },
      onForceLogout: _onForceLogout,
      getToken: _getToken,
    );
  }
}
