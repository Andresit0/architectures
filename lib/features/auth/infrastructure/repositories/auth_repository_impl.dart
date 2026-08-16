import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/offline_first_repository.dart';

import '../../domain/datasources/i_auth_datasource.dart';
import '../../domain/datasources/i_local_auth_datasource.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/password_hash.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required this._remoteDatasource,
    required this._localDatasource,
  });

  final IAuthRemoteDatasource _remoteDatasource;
  final ILocalAuthDatasource _localDatasource;

  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) => fetchOrFallback(
    remote: () => guard(
      () => _remoteDatasource.login(
        email: email.value,
        passwordHash: passwordHash.value,
      ),
    ),
    local: () => guard(() => _localDatasource.restoreSession()),
  );

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) =>
      guard(() => _remoteDatasource.refreshToken(token: token));

  @override
  Future<Result<void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) => guard(
    () => _localDatasource.saveSession(
      data: data,
      email: email,
      passwordHash: passwordHash,
    ),
  );

  @override
  Future<Result<void>> clearSession() =>
      guard(() => _localDatasource.clearSession());

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() =>
      guard(() => _localDatasource.restoreSession());
}
