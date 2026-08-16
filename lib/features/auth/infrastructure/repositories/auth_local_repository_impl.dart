import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_local_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

class AuthLocalRepositoryImpl implements ILocalAuthRepository {
  const AuthLocalRepositoryImpl({required this._localDatasource});

  final ILocalAuthDatasource _localDatasource;

  @override
  Future<Result<void>> saveSession({
    required LoginResponseEntity data,
    required Email email,
    required PasswordHash passwordHash,
  }) => guard(
    () => _localDatasource.saveSession(
      data: data,
      email: email.value,
      passwordHash: passwordHash.value,
    ),
  );

  @override
  Future<Result<void>> clearSession() =>
      guard(() => _localDatasource.clearSession());

  @override
  Future<Result<void>> resetAccount() =>
      guard(() => _localDatasource.resetAccount());

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() =>
      guard(() => _localDatasource.restoreSession());
}
