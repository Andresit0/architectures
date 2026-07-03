import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../../../../shared/functions/_function.lib.dart';

import '../../domain/datasources/i_auth_datasource.dart';
import '../../domain/datasources/i_local_auth_datasource.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required this._remoteDatasource,
    required this._localDatasource,
  });

  final IAuthRemoteDatasource _remoteDatasource;
  final ILocalAuthDatasource _localDatasource;

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async {
    return fetchOrFallback(
      remote: () => CustomFunction.fpdart.guard(
        () => _remoteDatasource.login(email: email, passwordHash: passwordHash),
      ),
      local: () => CustomFunction.fpdart.guard(
        () => _localDatasource.restoreSession(),
      ),
    );
  }

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) =>
      CustomFunction.fpdart.guard(() async {
        return _remoteDatasource.refreshToken(token: token);
      });

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) =>
      CustomFunction.fpdart.guard(() async {
        await _localDatasource.saveSession(
          data: data,
          email: email,
          passwordHash: passwordHash,
        );
      });

  @override
  Future<Either<Failure, void>> clearSession() =>
      CustomFunction.fpdart.guard(() async {
        await _localDatasource.clearSession();
      });

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() =>
      CustomFunction.fpdart.guard(() async {
        return _localDatasource.restoreSession();
      });
}
