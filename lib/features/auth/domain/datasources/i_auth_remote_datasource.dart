import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';

abstract interface class IAuthRemoteDatasource {
  Future<LoginResponseEntity> login({
    required String email,
    required String passwordHash,
  });

  Future<TokenEntity> refreshToken({required String token});
}
