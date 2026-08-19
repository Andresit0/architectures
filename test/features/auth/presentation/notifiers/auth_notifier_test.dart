import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/clear_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_input.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/reset_account_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import '../../../../helpers/mocks.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockRestoreSessionUseCase extends Mock
    implements RestoreSessionUseCase {}

class _MockAuthRepository extends Mock
    implements IAuthRepository, ILocalAuthRepository {}

void main() {
  final mockPatient = const PatientEntity(id: '1', name: 'John Doe');
  final mockToken = const TokenEntity(key: 'jwt_token_123');
  final mockLoginResponse = LoginResponseEntity(
    patient: mockPatient,
    token: mockToken,
    clinicalHistory: [],
  );
  late ProviderContainer container;
  late AuthNotifier notifier;
  late _MockLoginUseCase mockLoginUseCase;
  late _MockRestoreSessionUseCase mockRestoreSessionUseCase;
  late _MockAuthRepository mockAuthRepo;
  late FakeLogger fakeLogger;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(const LoginInput(email: '', password: ''));
    registerFallbackValue(const NoParams());
    mockLoginUseCase = _MockLoginUseCase();
    mockRestoreSessionUseCase = _MockRestoreSessionUseCase();
    mockAuthRepo = _MockAuthRepository();
    fakeLogger = FakeLogger();

    when(
      () => mockAuthRepo.clearSession(),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockAuthRepo.resetAccount(),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockRestoreSessionUseCase.call(any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockLoginUseCase.call(any()),
    ).thenAnswer((_) async => Success(mockLoginResponse));

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWith((ref) => mockLoginUseCase),
        clearSessionUseCaseProvider.overrideWith(
          (ref) => ClearSessionUseCase(repository: mockAuthRepo),
        ),
        resetAccountUseCaseProvider.overrideWith(
          (ref) => ResetAccountUseCase(repository: mockAuthRepo),
        ),
        restoreSessionUseCaseProvider.overrideWith(
          (ref) => mockRestoreSessionUseCase,
        ),
        loggerProvider.overrideWithValue(fakeLogger),
      ],
    );
    notifier = container.read(authProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('authNotifier', () {
    group('initial state', () {
      test('initial state is AuthInitial', () {
        expect(container.read(authProvider), const AuthState.initial());
      });
    });

    group('login', () {
      test('login_calls_loginUseCase', () async {
        await notifier.login('test@example.com', 'password');
        verify(() => mockLoginUseCase.call(any())).called(1);
      });

      test('login_sets_loading_state', () async {
        final future = notifier.login('test@example.com', 'password');
        expect(container.read(authProvider), const AuthState.loading());
        await future;
      });

      test('login_success_sets_loaded_state_with_patient_and_token', () async {
        await notifier.login('test@example.com', 'password');
        final state = container.read(authProvider);
        expect(state, isA<AuthLoaded>());
        final loaded = state as AuthLoaded;
        expect(loaded.patient.id, '1');
        expect(loaded.patient.name, 'John Doe');
        expect(loaded.token.key, 'jwt_token_123');
      });

      test('login_failure_sets_AuthFailure_with_message', () async {
        when(
          () => mockLoginUseCase.call(any()),
        ).thenAnswer((_) async => const Failure(NetworkError()));

        await notifier.login('test@example.com', 'password');
        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
        expect(fakeLogger.errorMessages, contains('[auth] login failed'));
      });

      test('login_resets_state_on_subsequent_login', () async {
        await notifier.login('test@example.com', 'password');
        expect(container.read(authProvider), isA<AuthLoaded>());

        final future = notifier.login('other@example.com', 'other');
        expect(container.read(authProvider), const AuthState.loading());
        await future;
      });
    });

    group('restoreSession', () {
      test('restoreSession_success_sets_loaded_state', () async {
        when(
          () => mockRestoreSessionUseCase.call(any()),
        ).thenAnswer((_) async => Success(mockLoginResponse));

        await notifier.restoreSession();
        final state = container.read(authProvider);
        expect(state, isA<AuthLoaded>());
        final loaded = state as AuthLoaded;
        expect(loaded.patient.id, '1');
      });

      test('restoreSession_null_data_keeps_initial_state', () async {
        when(
          () => mockRestoreSessionUseCase.call(any()),
        ).thenAnswer((_) async => const Success(null));

        await notifier.restoreSession();
        expect(container.read(authProvider), const AuthState.initial());
      });

      test('restoreSession_failure_sets_AuthFailure', () async {
        when(
          () => mockRestoreSessionUseCase.call(any()),
        ).thenAnswer((_) async => const Failure(NetworkError()));

        await notifier.restoreSession();
        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
        expect(
          fakeLogger.errorMessages,
          contains('[auth] restore session failed'),
        );
      });
    });

    group('logout', () {
      test('logout_sets_initial_state', () async {
        await notifier.login('test@example.com', 'password');
        expect(container.read(authProvider), isA<AuthLoaded>());

        await notifier.logout();
        expect(container.read(authProvider), const AuthState.initial());
      });

      test('logout_does_not_fail_when_already_initial', () async {
        await notifier.logout();
        expect(container.read(authProvider), const AuthState.initial());
      });

      test('logout_failure_sets_AuthFailure', () async {
        when(
          () => mockAuthRepo.clearSession(),
        ).thenAnswer((_) async => const Failure(NetworkError()));

        await notifier.logout();
        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
        expect(fakeLogger.errorMessages, contains('[auth] logout failed'));
      });
    });

    group('forceLogout', () {
      test('forceLogout_clears_session_and_sets_initial_state', () async {
        await notifier.login('test@example.com', 'password');
        expect(container.read(authProvider), isA<AuthLoaded>());

        await notifier.forceLogout();

        verify(() => mockAuthRepo.clearSession()).called(1);
        expect(container.read(authProvider), const AuthState.initial());
      });

      test('forceLogout_resets_state_even_when_clear_session_fails', () async {
        when(
          () => mockAuthRepo.clearSession(),
        ).thenAnswer((_) async => const Failure(NetworkError()));

        await notifier.forceLogout();

        expect(container.read(authProvider), const AuthState.initial());
      });

      test('forceLogout_does_not_fail_when_already_initial', () async {
        await notifier.forceLogout();
        expect(container.read(authProvider), const AuthState.initial());
      });
    });

    group('resetAccount', () {
      test('resetAccount_sets_initial_state_on_success', () async {
        await notifier.login('test@example.com', 'password');
        expect(container.read(authProvider), isA<AuthLoaded>());

        await notifier.resetAccount();

        verify(() => mockAuthRepo.resetAccount()).called(1);
        expect(container.read(authProvider), const AuthState.initial());
      });

      test('resetAccount_failure_sets_AuthFailure', () async {
        when(
          () => mockAuthRepo.resetAccount(),
        ).thenAnswer((_) async => const Failure(NetworkError()));

        await notifier.resetAccount();

        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
        expect(
          fakeLogger.errorMessages,
          contains('[auth] reset account failed'),
        );
      });
    });
  });
}
