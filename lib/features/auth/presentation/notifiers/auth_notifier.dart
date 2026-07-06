  import 'package:riverpod_annotation/riverpod_annotation.dart';

  import '../../../../shared/functions/_function.lib.dart';
  import '../../../../shared/providers/_providers.lib.dart';
  import '../providers/auth_provider.dart';
  import 'auth_state.dart';

  part 'auth_notifier.g.dart';

  @Riverpod(keepAlive: true)
  class AuthNotifier extends _$AuthNotifier {
    @override
    AuthState build() => const AuthState.initial();

    void reset() => state = const AuthState.initial();

    Future<void> login(String email, String password, {bool rememberMe = false}) async {
      state = const AuthState.loading();
      final passwordHash = CustomFunction.crypto.sha256(password);
      final result = await ref.read(loginUseCaseProvider).call(
        email: email,
        passwordHash: passwordHash,
      );
      await result.fold<Future<void>>(
        (failure) async {
          state = AuthState.failure(
            CustomFunction.failure.launch(
              failure,
              onFailure: (msg) => msg,
            ),
          );
        },
        (data) async {
          await ref.read(CustomProviders.token).save(data.token.key);
          if (rememberMe) {
            final saveResult = await ref.read(saveSessionUseCaseProvider).call(
              data: data,
              email: email,
              passwordHash: passwordHash,
            );
            final shouldProceed = saveResult.fold(
              (failure) {
                state = AuthState.failure(
                  CustomFunction.failure.launch(
                    failure,
                    onFailure: (msg) => msg,
                  ),
                );
                return false;
              },
              (_) => true,
            );
            if (!shouldProceed) return;
          }
          state = AuthState.loaded(
            patient: data.patient,
            token: data.token,
            clinicalHistory: data.clinicalHistory,
          );
          ref.read(CustomProviders.goRouter).update(true);
        },
      );
    }

    Future<void> restoreSession() async {
      final result = await ref.read(restoreSessionUseCaseProvider).call();
      await result.fold(
        (failure) {
          state = AuthState.failure(
            CustomFunction.failure.launch(
              failure,
              onFailure: (msg) => msg,
            ),
          );
        },
        (data) async {
          if (data == null) return;
          state = AuthState.loaded(
            patient: data.patient,
            token: data.token,
            clinicalHistory: data.clinicalHistory,
          );
          ref.read(CustomProviders.goRouter).update(true);
        },
      );
    }

    Future<void> logout() async {
      final result = await ref.read(clearSessionUseCaseProvider).call();
      await result.fold(
        (failure) {
          state = AuthState.failure(
            CustomFunction.failure.launch(
              failure,
              onFailure: (msg) => msg,
            ),
          );
        },
        (_) async {
          state = const AuthState.initial();
          ref.read(CustomProviders.goRouter).update(false);
        },
      );
    }
  }
