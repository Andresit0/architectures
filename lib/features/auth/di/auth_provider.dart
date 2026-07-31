import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/app/di/_providers.lib.dart';
import '../domain/datasources/i_auth_datasource.dart';
import '../domain/datasources/i_local_auth_datasource.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/clear_session_usecase.dart';
import '../domain/usecases/restore_session_usecase.dart';
import '../domain/usecases/refresh_token_usecase.dart';
import '../domain/usecases/handle_401_usecase.dart';
import '../infrastructure/datasources/auth_datasource_impl.dart';
import '../infrastructure/datasources/local_auth_datasource_impl.dart';
import '../infrastructure/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

final appNameProvider = Provider<String>((ref) => ref.watch(environmentProvider).appName);

@riverpod
IAuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasourceImpl(dio: ref.watch(authDioProvider));

@riverpod
ILocalAuthDatasource localAuthDatasource(Ref ref) => LocalAuthDatasourceImpl(
      patientInfo: ref.watch(patientInfoStoreProvider),
      clinicalHistory: ref.watch(clinicalHistoryStoreProvider),
      tokenStore: ref.watch(tokenStoreProvider),
      credentialStore: ref.watch(credentialStoreProvider),
      tokenVerifier: ref.watch(tokenVerifierProvider),
      appDatabase: ref.watch(appDatabaseProvider),
      internetService: ref.watch(internetServiceProvider),
    );

@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      remoteDatasource: ref.watch(authRemoteDatasourceProvider),
      localDatasource: ref.watch(localAuthDatasourceProvider),
    );

@riverpod
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(
      repository: ref.watch(authRepositoryProvider),
      passwordHasher: ref.watch(passwordHasherProvider),
      tokenStore: ref.watch(tokenStoreProvider),
    );


@riverpod
ClearSessionUseCase clearSessionUseCase(Ref ref) => ClearSessionUseCase(
      repository: ref.watch(authRepositoryProvider),
    );

@riverpod
RefreshTokenUseCase refreshTokenUseCase(Ref ref) => RefreshTokenUseCase(
  repository: ref.watch(authRepositoryProvider),
);

@riverpod
RestoreSessionUseCase restoreSessionUseCase(Ref ref) => RestoreSessionUseCase(
  repository: ref.watch(authRepositoryProvider),
  connectivityChecker: ref.watch(connectivityCheckerProvider),
  credentialStore: ref.watch(credentialStoreProvider),
  tokenVerifier: ref.watch(tokenVerifierProvider),
);

@riverpod
Handle401UseCase handle401UseCase(Ref ref) => Handle401UseCase(
  tokenStore: ref.watch(tokenStoreProvider),
  connectivityChecker: ref.watch(connectivityCheckerProvider),
  credentialStore: ref.watch(credentialStoreProvider),
  repository: ref.watch(authRepositoryProvider),
  refreshTokenUseCase: ref.watch(refreshTokenUseCaseProvider),
);
