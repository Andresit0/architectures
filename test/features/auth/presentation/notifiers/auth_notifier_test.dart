import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/clear_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}
class _MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}
class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  final mockPatient = const PatientEntity(id: '1', name: 'John Doe');
  final mockToken = const TokenEntity(
    type: 'Bearer',
    key: 'jwt_token_123',
  );
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

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockLoginUseCase = _MockLoginUseCase();
    mockRestoreSessionUseCase = _MockRestoreSessionUseCase();
    mockAuthRepo = _MockAuthRepository();

    when(() => mockAuthRepo.clearSession()).thenAnswer((_) async => const Success(null));
    when(() => mockRestoreSessionUseCase.call())
        .thenAnswer((_) async => const Success(null));
    when(
      () => mockLoginUseCase.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        rememberMe: any(named: 'rememberMe'),
      ),
    ).thenAnswer((_) async => Success(mockLoginResponse));

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWith((ref) => mockLoginUseCase),
        clearSessionUseCaseProvider.overrideWith(
          (ref) => ClearSessionUseCase(
            repository: mockAuthRepo,
          ),
        ),
        restoreSessionUseCaseProvider.overrideWith(
          (ref) => mockRestoreSessionUseCase,
        ),
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
        verify(() => mockLoginUseCase.call(
          email: any(named: 'email'),
          password: any(named: 'password'),
          rememberMe: any(named: 'rememberMe'),
        )).called(1);
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
          () => mockLoginUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
            rememberMe: any(named: 'rememberMe'),
          ),
        ).thenAnswer((_) async => const Failure(NetworkError('No internet connection')));

        await notifier.login('test@example.com', 'password');
        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
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
        when(() => mockRestoreSessionUseCase.call())
            .thenAnswer((_) async => Success(mockLoginResponse));

        await notifier.restoreSession();
        final state = container.read(authProvider);
        expect(state, isA<AuthLoaded>());
        final loaded = state as AuthLoaded;
        expect(loaded.patient.id, '1');
      });

      test('restoreSession_null_data_keeps_initial_state', () async {
        when(() => mockRestoreSessionUseCase.call())
            .thenAnswer((_) async => const Success(null));

        await notifier.restoreSession();
        expect(container.read(authProvider), const AuthState.initial());
      });

      test('restoreSession_failure_sets_AuthFailure', () async {
        when(() => mockRestoreSessionUseCase.call())
            .thenAnswer((_) async => const Failure(NetworkError('No internet connection')));

        await notifier.restoreSession();
        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
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
        when(() => mockAuthRepo.clearSession())
            .thenAnswer((_) async => const Failure(NetworkError('No internet connection')));

        await notifier.logout();
        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
      });

    });
  });
}
