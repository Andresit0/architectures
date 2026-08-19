import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

import '../../di/auth_provider.dart';
import '../../domain/usecases/login_input.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  void reset() => state = const AuthState.initial();

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    state = const AuthState.loading();
    final result = await ref.read(loginUseCaseProvider)(
      LoginInput(email: email, password: password, rememberMe: rememberMe),
    );
    await result.fold<Future<void>>(
      onSuccess: (data) async {
        state = AuthState.loaded(patient: data.patient, token: data.token);
      },
      onFailure: (error) async {
        ref
            .read(loggerProvider)
            .error(
              '[auth] login failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> restoreSession() async {
    final result = await ref.read(restoreSessionUseCaseProvider)(NoParams());
    await result.fold(
      onSuccess: (data) async {
        if (data == null) return;
        state = AuthState.loaded(patient: data.patient, token: data.token);
      },
      onFailure: (error) {
        ref
            .read(loggerProvider)
            .error(
              '[auth] restore session failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> logout() async {
    final result = await ref.read(clearSessionUseCaseProvider)(NoParams());
    await result.fold(
      onSuccess: (_) async {
        state = const AuthState.initial();
      },
      onFailure: (error) {
        ref
            .read(loggerProvider)
            .error(
              '[auth] logout failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> resetAccount() async {
    final result = await ref.read(resetAccountUseCaseProvider)(NoParams());
    await result.fold(
      onSuccess: (_) async {
        state = const AuthState.initial();
      },
      onFailure: (error) {
        ref
            .read(loggerProvider)
            .error(
              '[auth] reset account failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> forceLogout() async {
    await ref.read(clearSessionUseCaseProvider)(NoParams());
    state = const AuthState.initial();
  }
}
