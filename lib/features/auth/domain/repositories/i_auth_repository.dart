import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../entities/login_response_entity.dart';
import '../entities/token_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  });

  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  });

  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  });

  Future<Either<Failure, void>> clearSession();

  Future<Either<Failure, LoginResponseEntity?>> restoreSession();
}
