import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import '../entities/token_entity.dart';
import '../repositories/i_auth_repository.dart';
import 'refresh_token_input.dart';

class RefreshTokenUseCase implements IUseCase<RefreshTokenInput, TokenEntity> {
  const RefreshTokenUseCase({required this._repository});

  final IAuthRepository _repository;

  @override
  Future<Result<TokenEntity>> call(RefreshTokenInput input) =>
      _repository.refreshToken(token: input.token);
}
