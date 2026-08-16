import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

abstract interface class IAuthRepository {
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  });

  Future<Result<TokenEntity>> refreshToken({required String token});

  Future<Result<void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  });

  Future<Result<void>> clearSession();

  Future<Result<LoginResponseEntity?>> restoreSession();
}
