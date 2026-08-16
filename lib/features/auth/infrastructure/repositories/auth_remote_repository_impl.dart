import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_auth_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

class AuthRemoteRepositoryImpl implements IAuthRepository {
  const AuthRemoteRepositoryImpl({required this._remoteDatasource});

  final IAuthRemoteDatasource _remoteDatasource;

  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) => guard(
    () => _remoteDatasource.login(
      email: email.value,
      passwordHash: passwordHash.value,
    ),
  );

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) =>
      guard(() => _remoteDatasource.refreshToken(token: token));
}
