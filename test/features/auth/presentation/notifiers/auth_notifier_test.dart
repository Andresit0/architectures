import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/clear_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/providers/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/database/_database.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/go_router_notifier_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/sembast_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/token_provider.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockICpSembast extends Mock implements ICpSembast {}

class _MockITokenService extends Mock implements ITokenService {}

class _FakeGoRouter implements ICpGoRouter {
  @override
  void go(String location, {Object? extra}) {}
  @override
  void push(String location, {Object? extra}) {}
  @override
  void goNamed(String name, {Map<String, String>? params, Object? extra}) {}
  @override
  void pushNamed(String name, {Map<String, String>? params, Object? extra}) {}
  @override
  void pop() {}
  @override
  bool canPop() => throw UnimplementedError('canPop should not be called in notifier tests');
  @override
  void replace(String location, {Object? extra}) {}
}

class _FakeGoRouterListenable extends GoRouterListenable {
  _FakeGoRouterListenable() : super(false);
}

void main() {
  final mockPatient = PatientEntity(id: '1', name: 'John Doe');
  final mockToken = TokenEntity(
    type: 'Bearer',
    key: 'jwt_token_123',
    expiresInHours: 24,
    expirationDate: null,
  );
  final mockLoginResponse = LoginResponseEntity(
    patient: mockPatient,
    token: mockToken,
    clinicalHistory: null,
  );
  final mockLoginResponseWithHistory = LoginResponseEntity(
    patient: mockPatient,
    token: mockToken,
    clinicalHistory: [
      ClinicalHistoryEntity(
        id: 'ch1',
        encounterNumber: 'ENC-001',
        service: ClinicalHistoryServiceEntity(
          code: 'GEN',
          name: 'General Medicine',
          category: 'consultation',
        ),
        facility: ClinicalHistoryFacilityEntity(
          id: 'FAC-001',
          name: 'Central Medical Center',
          city: 'Quito',
        ),
        professional: null,
        encounterDate: '2026-01-15',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: null,
        description: null,
        diagnosis: [],
        observations: [],
        attachments: [],
        state: null,
      ),
    ],
  );

  late ProviderContainer container;
  late AuthNotifier notifier;
  late _MockLoginUseCase mockLoginUseCase;
  late _MockAuthRepository mockAuthRepo;
  late _MockICpSembast mockSembast;
  late _MockITokenService mockTokenService;
  late _FakeGoRouterListenable fakeGoRouterListenable;

  setUp(() async {
    registerFallbackValue(const LoginResponseEntity(
      patient: PatientEntity(id: '', name: ''),
      token: TokenEntity(
        type: '', key: '', expiresInHours: 0, expirationDate: null,
      ),
      clinicalHistory: null,
    ));
    TestWidgetsFlutterBinding.ensureInitialized();
    AppDatabase.testFactory = databaseFactoryMemory;
    mockLoginUseCase = _MockLoginUseCase();
    mockAuthRepo = _MockAuthRepository();
    mockSembast = _MockICpSembast();
    mockTokenService = _MockITokenService();
    CustomFunction.goRouter = _FakeGoRouter();
    fakeGoRouterListenable = _FakeGoRouterListenable();

    when(() => mockTokenService.deleteAll()).thenAnswer((_) async {});
    when(() => mockTokenService.save(any())).thenAnswer((_) async {});
    when(() => mockTokenService.read()).thenAnswer((_) async => null);
    when(() => mockTokenService.isTokenExpired(any())).thenAnswer((_) async => false);
    when(
      () => mockTokenService.saveCredentials(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockAuthRepo.clearSession()).thenAnswer((_) async => const Right(null));
    when(
      () => mockAuthRepo.saveSession(
        data: any(named: 'data'),
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    ).thenAnswer((_) async => const Right(null));
    when(() => mockAuthRepo.restoreSession())
        .thenAnswer((_) async => const Right(null));

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWith((ref) => mockLoginUseCase),
        clearSessionUseCaseProvider.overrideWith(
          (ref) => ClearSessionUseCase(repository: mockAuthRepo),
        ),
        saveSessionUseCaseProvider.overrideWith(
          (ref) => SaveSessionUseCase(repository: mockAuthRepo),
        ),
        restoreSessionUseCaseProvider.overrideWith(
          (ref) => RestoreSessionUseCase(repository: mockAuthRepo),
        ),
        sembastProvider.overrideWith((ref) => mockSembast),
        tokenServiceProvider.overrideWith((ref) => mockTokenService),
        goRouterListenableProvider.overrideWith((ref) => fakeGoRouterListenable),
      ],
    );
    notifier = container.read(authProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    AppDatabase.testFactory = null;
  });

  group('initial state', () {
    test('initial state is AuthInitial', () {
      expect(container.read(authProvider), isA<AuthInitial>());
    });
  });

  group('login', () {
    test('login_success_sets_loaded_state_with_patient_and_token', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Right(mockLoginResponse));

      await notifier.login('test@example.com', 'mypassword', rememberMe: true);

      final state = container.read(authProvider);
      expect(state, isA<AuthLoaded>());
      final loaded = state as AuthLoaded;
      expect(loaded.patient.id, '1');
      expect(loaded.patient.name, 'John Doe');
      expect(loaded.token.key, 'jwt_token_123');
    });

    test('login_saves_token_to_secure_storage_always', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Right(mockLoginResponse));

      await notifier.login('test@example.com', 'mypassword', rememberMe: false);

      verify(() => mockTokenService.save('jwt_token_123')).called(1);
    });

    test('login_with_rememberMe_true_calls_saveSession', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Right(mockLoginResponseWithHistory));

      await notifier.login('test@example.com', 'mypassword', rememberMe: true);

      verify(
        () => mockAuthRepo.saveSession(
          data: mockLoginResponseWithHistory,
          email: 'test@example.com',
          passwordHash: any(named: 'passwordHash'),
        ),
      ).called(1);
    });

    test('login_without_rememberMe_does_not_call_saveSession', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Right(mockLoginResponse));

      await notifier.login('test@example.com', 'mypassword', rememberMe: false);

      verifyNever(() => mockAuthRepo.saveSession(
        data: any(named: 'data'),
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ));
    });

    test('login_with_rememberMe_and_saveSession_failure_sets_AuthFailure_and_blocks_navigation', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Right(mockLoginResponse));
      when(
        () => mockAuthRepo.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Left(UnexpectedFailure()));

      await notifier.login('test@example.com', 'mypassword', rememberMe: true);

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
      expect(fakeGoRouterListenable.isAuthenticated, isFalse);
    });

    test('login_updates_goRouterListenable_to_authenticated', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Right(mockLoginResponse));

      expect(fakeGoRouterListenable.isAuthenticated, isFalse);

      await notifier.login('test@example.com', 'mypassword');

      expect(fakeGoRouterListenable.isAuthenticated, isTrue);
    });

    test('login_failure_sets_failure_state_with_message', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Left(NoConnectionFailure()));

      await notifier.login('test@example.com', 'mypassword');

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
    });

    test('login_failure_includes_error_message', () async {
      when(
        () => mockLoginUseCase(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer(
        (_) async => const Left(ApiFailure()),
      );

      await notifier.login('test@example.com', 'wrong');

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
      expect((state as AuthFailure).message, isNotEmpty);
    });
  });

  group('restoreSession', () {
    test('restoreSession_with_valid_session_sets_AuthLoaded', () async {
      when(() => mockAuthRepo.restoreSession())
          .thenAnswer((_) async => Right(mockLoginResponse));

      await notifier.restoreSession();

      final state = container.read(authProvider);
      expect(state, isA<AuthLoaded>());
      final loaded = state as AuthLoaded;
      expect(loaded.patient.name, 'John Doe');
      expect(loaded.token.key, 'jwt_token_123');
    });

    test('restoreSession_without_session_stays_AuthInitial', () async {
      when(() => mockAuthRepo.restoreSession())
          .thenAnswer((_) async => const Right(null));

      await notifier.restoreSession();

      expect(container.read(authProvider), isA<AuthInitial>());
    });

    test('restoreSession_updates_goRouter_when_session_found', () async {
      when(() => mockAuthRepo.restoreSession())
          .thenAnswer((_) async => Right(mockLoginResponse));

      expect(fakeGoRouterListenable.isAuthenticated, isFalse);

      await notifier.restoreSession();

      expect(fakeGoRouterListenable.isAuthenticated, isTrue);
    });

    test('restoreSession_does_not_update_goRouter_when_no_session', () async {
      when(() => mockAuthRepo.restoreSession())
          .thenAnswer((_) async => const Right(null));

      expect(fakeGoRouterListenable.isAuthenticated, isFalse);

      await notifier.restoreSession();

      expect(fakeGoRouterListenable.isAuthenticated, isFalse);
    });

    test('restoreSession_with_failure_sets_AuthFailure', () async {
      when(() => mockAuthRepo.restoreSession())
          .thenAnswer((_) async => const Left(UnexpectedFailure()));

      await notifier.restoreSession();

      expect(container.read(authProvider), isA<AuthFailure>());
    });
  });

  group('logout', () {
    test('logout_success_clears_session_and_resets_state', () async {
      await notifier.logout();

      verify(() => mockAuthRepo.clearSession()).called(1);
      expect(container.read(authProvider), isA<AuthInitial>());
    });

    test('logout_updates_goRouterListenable_to_unauthenticated', () async {
      fakeGoRouterListenable.update(true);

      await notifier.logout();

      expect(fakeGoRouterListenable.isAuthenticated, isFalse);
    });

    test('logout_with_failure_sets_AuthFailure', () async {
      when(() => mockAuthRepo.clearSession())
          .thenAnswer((_) async => const Left(UnexpectedFailure()));

      await notifier.logout();

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
    });
  });
}
