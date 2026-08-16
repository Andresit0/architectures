import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'refresh_token_input.dart';

class RestoreSessionUseCase
    implements IUseCase<NoParams, LoginResponseEntity?> {
  const RestoreSessionUseCase({
    required this._localRepository,
    required this._connectivityChecker,
    required this._tokenStore,
    required this._tokenVerifier,
    required this._credentialLoginUseCase,
    required this._refreshTokenUseCase,
  });

  final ILocalAuthRepository _localRepository;
  final IConnectivityChecker _connectivityChecker;
  final ITokenStore _tokenStore;
  final ITokenVerifier _tokenVerifier;
  final IUseCase<NoParams, LoginResponseEntity?> _credentialLoginUseCase;
  final IUseCase<RefreshTokenInput, TokenEntity> _refreshTokenUseCase;

  @override
  Future<Result<LoginResponseEntity?>> call(NoParams input) async {
    final connectivityResult = await guard(
      () => _connectivityChecker.isConnected(),
    );
    final online = switch (connectivityResult) {
      Success(data: final data) => data,
      Failure() => false,
    };

    if (online) {
      final loginResult = await _credentialLoginUseCase(NoParams());
      if (loginResult case Success(
        data: final loginData,
      ) when loginData != null) {
        await guard(() => _tokenStore.save(loginData.token.key));
        return Success(loginData);
      }
    }

    final localResult = await _localRepository.restoreSession();
    if (localResult case Failure()) return localResult;
    final localData = (localResult as Success<LoginResponseEntity?>).data;
    if (localData == null) return const Success(null);

    final expiredResult = await guard(
      () => _tokenVerifier.isExpired(localData.token.key),
    );
    final expired = switch (expiredResult) {
      Success(data: final data) => data,
      Failure() => false,
    };
    if (expired && online) {
      final refreshResult = await _refreshTokenUseCase(
        RefreshTokenInput(token: localData.token.key),
      );
      if (refreshResult case Success(data: final tokenData)) {
        await guard(() => _tokenStore.save(tokenData.key));
        return Success(
          localData.copyWith(token: TokenEntity(key: tokenData.key)),
        );
      }
      return Success(localData);
    }

    return Success(localData);
  }
}
