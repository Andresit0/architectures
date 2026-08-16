import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/clinical_history_providers.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/patient_info_providers.dart';
import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/token_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/crypto/password_hasher_provider.dart';
import 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';
import '../domain/datasources/i_auth_remote_datasource.dart';
import '../domain/datasources/i_local_auth_datasource.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_local_auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/clear_session_usecase.dart';
import '../domain/usecases/reset_account_usecase.dart';
import '../domain/usecases/restore_session_usecase.dart';
import '../domain/usecases/refresh_token_usecase.dart';
import '../domain/usecases/handle_401_usecase.dart';
import '../domain/usecases/credential_login_usecase.dart';
import '../infrastructure/datasources/auth_datasource_impl.dart';
import '../infrastructure/datasources/local_auth_datasource_impl.dart';
import '../infrastructure/repositories/auth_local_repository_impl.dart';
import '../infrastructure/repositories/auth_remote_repository_impl.dart';

export 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';

part 'auth_provider.g.dart';

@riverpod
IAuthRemoteDatasource authRemoteDatasource(Ref ref) => AuthRemoteDatasourceImpl(
  dio: ref.watch(authDioProvider),
  appUries: ref.watch(appUriesProvider),
);

@riverpod
ILocalAuthDatasource localAuthDatasource(Ref ref) => LocalAuthDatasourceImpl(
  patientInfo: ref.watch(patientInfoStoreProvider),
  clinicalHistoryReader: ref.watch(clinicalHistoryStoreProvider),
  clinicalHistoryWriter: ref.watch(clinicalHistoryStoreProvider),
  tokenStore: ref.watch(tokenStoreProvider),
  credentialStore: ref.watch(credentialStoreProvider),
  appDatabase: ref.watch(appDatabaseProvider),
);

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRemoteRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  ),
);

final localAuthRepositoryProvider = Provider<ILocalAuthRepository>(
  (ref) => AuthLocalRepositoryImpl(
    localDatasource: ref.watch(localAuthDatasourceProvider),
  ),
);

@riverpod
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(
  repository: ref.watch(authRepositoryProvider),
  sessionRepository: ref.watch(localAuthRepositoryProvider),
  passwordHasher: ref.watch(passwordHasherProvider),
  tokenStore: ref.watch(tokenStoreProvider),
);

@riverpod
ClearSessionUseCase clearSessionUseCase(Ref ref) =>
    ClearSessionUseCase(repository: ref.watch(localAuthRepositoryProvider));

@riverpod
ResetAccountUseCase resetAccountUseCase(Ref ref) =>
    ResetAccountUseCase(repository: ref.watch(localAuthRepositoryProvider));

@riverpod
RefreshTokenUseCase _refreshTokenUseCase(Ref ref) =>
    RefreshTokenUseCase(repository: ref.watch(authRepositoryProvider));

@riverpod
CredentialLoginUseCase _credentialLoginUseCase(Ref ref) =>
    CredentialLoginUseCase(
      repository: ref.watch(authRepositoryProvider),
      credentialStore: ref.watch(credentialStoreProvider),
      logger: ref.watch(loggerProvider),
    );

@riverpod
RestoreSessionUseCase restoreSessionUseCase(Ref ref) => RestoreSessionUseCase(
  localRepository: ref.watch(localAuthRepositoryProvider),
  connectivityChecker: ref.watch(connectivityCheckerProvider),
  tokenStore: ref.watch(tokenStoreProvider),
  tokenVerifier: ref.watch(tokenVerifierProvider),
  credentialLoginUseCase: ref.watch(_credentialLoginUseCaseProvider),
  refreshTokenUseCase: ref.watch(_refreshTokenUseCaseProvider),
);

@riverpod
Handle401UseCase handle401UseCase(Ref ref) => Handle401UseCase(
  tokenStore: ref.watch(tokenStoreProvider),
  connectivityChecker: ref.watch(connectivityCheckerProvider),
  refreshTokenUseCase: ref.watch(_refreshTokenUseCaseProvider),
  credentialLoginUseCase: ref.watch(_credentialLoginUseCaseProvider),
);
