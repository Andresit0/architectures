import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/handle_401_usecase.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

class AuthInterceptorImpl implements IAuthInterceptorProvider {
  const AuthInterceptorImpl({required this.handle401UseCase});

  final Handle401UseCase handle401UseCase;

  @override
  void setupAuthInterceptor(
    IDioWrapper dioWrapper, {
    required VoidCallback onForceLogout,
  }) {
    dioWrapper.addAuthInterceptor(() async {
      final result = await handle401UseCase();
      return switch (result) {
        Success(data: final retryResult) => retryResult,
        Failure() => const RetryFailed(),
      };
    }, onForceLogout: onForceLogout);
  }
}
