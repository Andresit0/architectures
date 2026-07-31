import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import '../entities/token_entity.dart';
import '../repositories/i_auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase({
    required this._repository,
  });

  final IAuthRepository _repository;

  Future<Result<TokenEntity>> call({
    required String token,
  }) async {
    final result = await _repository.refreshToken(token: token);
    return result;
  }
}
