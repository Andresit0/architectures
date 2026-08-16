import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'refresh_token_input.dart';

class Handle401UseCase implements IUseCase<NoParams, RetryResult> {
  const Handle401UseCase({
    required this._tokenStore,
    required this._connectivityChecker,
    required this._refreshTokenUseCase,
    required this._credentialLoginUseCase,
  });

  final ITokenStore _tokenStore;
  final IConnectivityChecker _connectivityChecker;
  final IUseCase<RefreshTokenInput, TokenEntity> _refreshTokenUseCase;
  final IUseCase<NoParams, LoginResponseEntity?> _credentialLoginUseCase;

  @override
  Future<Result<RetryResult>> call(NoParams input) async {
    final connectivityResult = await guard(
      () => _connectivityChecker.isConnected(),
    );
    final online = switch (connectivityResult) {
      Success(data: final data) => data,
      Failure() => false,
    };
    if (!online) {
      return const Success(RetryNoConnection());
    }

    AppError? lastError;

    final readResult = await guard(() => _tokenStore.read());
    String? token;
    if (readResult case Success(:final data)) {
      token = data;
    } else if (readResult case Failure(:final error)) {
      lastError = error;
    }

    if (token != null) {
      final refreshResult = await _refreshTokenUseCase(
        RefreshTokenInput(token: token),
      );
      if (refreshResult case Success(:final data)) {
        await guard(() => _tokenStore.save(data.key));
        return Success(RetrySuccess(data.key));
      }
      if (refreshResult case Failure(:final error)) {
        lastError = error;
      }
    }

    final loginResult = await _credentialLoginUseCase(NoParams());
    if (loginResult case Success(data: final data) when data != null) {
      await guard(() => _tokenStore.save(data.token.key));
      return Success(RetrySuccess(data.token.key));
    }
    if (loginResult case Failure(:final error)) {
      lastError = error;
    }

    if (lastError != null && lastError.isTransient) {
      return const Success(RetryNoConnection());
    }

    return Failure(lastError ?? const UnexpectedError());
  }
}
