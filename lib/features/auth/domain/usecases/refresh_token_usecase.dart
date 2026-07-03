import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../entities/token_entity.dart';
import '../repositories/i_auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase({required this._repository});

  final IAuthRepository _repository;

  Future<Either<Failure, TokenEntity>> call({
    required String token,
  }) =>
      _repository.refreshToken(
        token: token,
      );
}
