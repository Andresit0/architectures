import 'package:clean_architecture_sdd_harness/app/di/auth/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/app/di/network/auth_interceptor_impl.dart';
import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Internal factory. Both [authDioProvider] and [httpServiceProvider] use this
/// to ensure consistent DioWrapper construction. If construction parameters
/// change, update this single function.
IDioWrapper _createDioWrapper(Ref ref) {
  final internetService = ref.watch(internetServiceProvider);
  return DioWrapper(
    internetService,
    null,
    CertificatePinner(
      pinnedCertificates: AppEnvironment.current.pinnedCertificates,
    ),
    null,
    null,
    ConnectionProfile.standard,
  );
}

/// Dio WITHOUT auth interceptor. Used by AuthRemoteDatasource for login/refresh
/// where no token exists yet.
final authDioProvider = Provider<IDioWrapper>((ref) => _createDioWrapper(ref));

/// Dio WITH auth interceptor (401 retry + force logout).
/// Use this in features that need authenticated HTTP calls.
final httpServiceProvider = Provider<IDioWrapper>((ref) {
  final dio = _createDioWrapper(ref);
  AuthInterceptorImpl(
    handle401UseCase: ref.watch(handle401UseCaseProvider),
  ).setupAuthInterceptor(
    dio,
    onForceLogout: () => ref.read(authProvider.notifier).reset(),
  );
  return dio;
});
