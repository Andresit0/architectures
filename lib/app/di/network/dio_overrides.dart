import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import 'package:clean_architecture_sdd_harness/app/di/network/auth_interceptor_impl.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/token_providers.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';

List<Override> dioOverrides() => [
  authInterceptorProvider.overrideWith(
    (ref) => AuthInterceptorImpl(
      handle401UseCase: ref.watch(handle401UseCaseProvider),
      onForceLogout: () => ref.read(authProvider.notifier).forceLogout(),
      getToken: () => ref.read(tokenStoreProvider).read(),
    ),
  ),
];
