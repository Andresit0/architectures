import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di/auth_provider.dart';
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
    final result = await ref
        .read(loginUseCaseProvider)
        .call(email: email, password: password, rememberMe: rememberMe);
    await result.fold<Future<void>>(
      onSuccess: (data) async {
        state = AuthState.loaded(
          patient: data.patient,
          token: data.token,
          clinicalHistory: data.clinicalHistory,
        );
      },
      onFailure: (error) async {
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> restoreSession() async {
    final result = await ref.read(restoreSessionUseCaseProvider).call();
    await result.fold(
      onSuccess: (data) async {
        if (data == null) return;
        state = AuthState.loaded(
          patient: data.patient,
          token: data.token,
          clinicalHistory: data.clinicalHistory,
        );
      },
      onFailure: (error) {
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> logout() async {
    final result = await ref.read(clearSessionUseCaseProvider).call();
    await result.fold(
      onSuccess: (_) async {
        state = const AuthState.initial();
      },
      onFailure: (error) {
        state = AuthState.failure(error);
      },
    );
  }
}
