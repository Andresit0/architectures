import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/core/config/environment_provider.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/interceptors/i_auth_interceptor_provider.dart';
import 'package:clean_architecture_sdd_harness/core/network/security/certificate_pinner.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/connection_profile.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

IDioWrapper _createDioWrapper(Ref ref) {
  final internetService = ref.watch(internetServiceProvider);
  final env = ref.watch(environmentProvider);
  return DioWrapper(
    internetService,
    null,
    CertificatePinner(
      pinnedCertificates: env.pinnedCertificates,
      enforcePinning: env.requirePinnedCertificates,
    ),
    null,
    null,
    ConnectionProfile.standard,
  );
}

final authInterceptorProvider = Provider<IAuthInterceptorProvider>(
  (ref) => throw SeamNotBoundException(
    'authInterceptorProvider must be overridden in the composition root '
    '(app/di/network/dio_overrides.dart)',
  ),
);

final authDioProvider = Provider<IDioWrapper>((ref) => _createDioWrapper(ref));

final httpServiceProvider = Provider<IDioWrapper>((ref) {
  final dio = _createDioWrapper(ref);
  ref.watch(authInterceptorProvider).setupAuthInterceptor(dio);
  return dio;
});
