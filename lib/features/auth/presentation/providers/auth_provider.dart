import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/_providers.lib.dart';
import '../../../../shared/database/_database.lib.dart';
import '../../../../shared/functions/_function.lib.dart';

import '../../domain/datasources/i_auth_datasource.dart';
import '../../domain/datasources/i_local_auth_datasource.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/save_session_usecase.dart';
import '../../domain/usecases/clear_session_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../infrastructure/datasources/auth_datasource_impl.dart';
import '../../infrastructure/datasources/local_auth_datasource_impl.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
IAuthRemoteDatasource authRemoteDatasource(Ref ref) => AuthRemoteDatasourceImpl(
      dio: ref.watch(CustomProviders.dio),
    );

@riverpod
ILocalAuthDatasource localAuthDatasource(Ref ref) => LocalAuthDatasourceImpl(
      patientInfo: CustomDb.patientInfo,
      clinicalHistory: CustomDb.clinicalHistory,
      tokenService: ref.watch(CustomProviders.token),
      appDatabase: AppDatabase(),
      internetService: CustomFunction.internetService,
    );

@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      remoteDatasource: ref.watch(authRemoteDatasourceProvider),
      localDatasource: ref.watch(localAuthDatasourceProvider),
    );

@riverpod
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(
      repository: ref.watch(authRepositoryProvider),
    );

@riverpod
RefreshTokenUseCase refreshTokenUseCase(Ref ref) => RefreshTokenUseCase(
      repository: ref.watch(authRepositoryProvider),
    );

@riverpod
SaveSessionUseCase saveSessionUseCase(Ref ref) => SaveSessionUseCase(
      repository: ref.watch(authRepositoryProvider),
    );

@riverpod
ClearSessionUseCase clearSessionUseCase(Ref ref) => ClearSessionUseCase(
      repository: ref.watch(authRepositoryProvider),
    );

@riverpod
RestoreSessionUseCase restoreSessionUseCase(Ref ref) => RestoreSessionUseCase(
      repository: ref.watch(authRepositoryProvider),
    );
