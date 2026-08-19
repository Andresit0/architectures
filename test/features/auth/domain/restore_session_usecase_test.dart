import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_input.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class _MockLocalAuthRepository extends Mock implements ILocalAuthRepository {}

class _MockConnectivityChecker extends Mock implements IConnectivityChecker {}

class _MockTokenStore extends Mock implements ITokenStore {}

class _MockTokenVerifier extends Mock implements ITokenVerifier {}

class _MockCredentialLoginUseCase extends Mock
    implements IUseCase<NoParams, LoginResponseEntity?> {}

class _MockRefreshTokenUseCase extends Mock
    implements IUseCase<RefreshTokenInput, TokenEntity> {}

void main() {
  late _MockLocalAuthRepository mockLocalRepo;
  late _MockConnectivityChecker mockConnectivity;
  late _MockTokenStore mockTokenStore;
  late _MockTokenVerifier mockTokenVerifier;
  late _MockCredentialLoginUseCase mockCredentialLoginUseCase;
  late _MockRefreshTokenUseCase mockRefreshTokenUseCase;
  late RestoreSessionUseCase useCase;

  final loginResponse = LoginResponseEntity(
    patient: const PatientEntity(id: '1', name: 'John Doe'),
    token: const TokenEntity(key: 'jwt_token_123'),
    clinicalHistory: [],
  );

  const newToken = TokenEntity(key: 'new_jwt');

  setUp(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const RefreshTokenInput(token: ''));
    mockLocalRepo = _MockLocalAuthRepository();
    mockConnectivity = _MockConnectivityChecker();
    mockTokenStore = _MockTokenStore();
    mockTokenVerifier = _MockTokenVerifier();
    mockCredentialLoginUseCase = _MockCredentialLoginUseCase();
    mockRefreshTokenUseCase = _MockRefreshTokenUseCase();
    when(
      () => mockTokenVerifier.isExpired(any()),
    ).thenAnswer((_) async => false);

    useCase = RestoreSessionUseCase(
      localRepository: mockLocalRepo,
      connectivityChecker: mockConnectivity,
      tokenStore: mockTokenStore,
      tokenVerifier: mockTokenVerifier,
      credentialLoginUseCase: mockCredentialLoginUseCase,
      refreshTokenUseCase: mockRefreshTokenUseCase,
    );
  });

  group('RestoreSessionUseCase', () {
    test('online_with_credentials_login_success_returns_login_data', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => Success<LoginResponseEntity?>(loginResponse));
      when(() => mockTokenStore.save(any())).thenAnswer((_) async {});

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      verify(() => mockTokenStore.save('jwt_token_123')).called(1);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.patient.name, 'John Doe');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('online_with_credentials_login_fails_fallback_to_local', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Failure(UnexpectedError()));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenAnswer((_) async => false);

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.patient.name, 'John Doe');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('offline_with_valid_local_session_returns_local_data', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenAnswer((_) async => false);

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.token.key, 'jwt_token_123');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('offline_with_expired_local_session_returns_local_data', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenAnswer((_) async => true);

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.token.key, 'jwt_token_123');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test(
      'online_with_expired_session_refresh_success_returns_new_token',
      () async {
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCredentialLoginUseCase(any()),
        ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
        when(
          () => mockLocalRepo.restoreSession(),
        ).thenAnswer((_) async => Success(loginResponse));
        when(
          () => mockTokenVerifier.isExpired('jwt_token_123'),
        ).thenAnswer((_) async => true);
        when(
          () => mockRefreshTokenUseCase(any()),
        ).thenAnswer((_) async => const Success(newToken));
        when(() => mockTokenStore.save(any())).thenAnswer((_) async {});

        final result = await useCase(NoParams());

        expect(result.isSuccess, isTrue);
        verify(() => mockTokenStore.save('new_jwt')).called(1);
        result.fold(
          onSuccess: (entity) {
            expect(entity, isNotNull);
            expect(entity!.token.key, 'new_jwt');
          },
          onFailure: (_) => fail('should be Success'),
        );
      },
    );

    test(
      'online_with_expired_session_refresh_fails_returns_local_data_no_logout',
      () async {
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCredentialLoginUseCase(any()),
        ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
        when(
          () => mockLocalRepo.restoreSession(),
        ).thenAnswer((_) async => Success(loginResponse));
        when(
          () => mockTokenVerifier.isExpired('jwt_token_123'),
        ).thenAnswer((_) async => true);
        when(
          () => mockRefreshTokenUseCase(any()),
        ).thenAnswer((_) async => const Failure(UnexpectedError()));

        final result = await useCase(NoParams());

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (entity) {
            expect(entity, isNotNull);
            expect(entity!.token.key, 'jwt_token_123');
          },
          onFailure: (_) => fail('should be Success — restore must NOT logout'),
        );
        verifyNever(() => mockTokenStore.delete());
      },
    );

    test('no_credentials_and_no_local_session_returns_null', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase(NoParams());

      result.fold(
        onSuccess: (entity) => expect(entity, isNull),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('local_session_failure_propagates_error', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => const Failure(UnexpectedError()));

      final result = await useCase(NoParams());

      expect(result.isSuccess, isFalse);
    });

    test('connectivity_check_throws_falls_back_to_local_data', () async {
      when(
        () => mockConnectivity.isConnected(),
      ).thenThrow(Exception('connectivity down'));
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.token.key, 'jwt_token_123');
        },
        onFailure: (_) =>
            fail('should be Success — restore must not fail on connectivity'),
      );
      verifyNever(() => mockCredentialLoginUseCase(any()));
    });

    test('token_verifier_throws_keeps_local_data_without_refresh', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenThrow(Exception('verifier down'));

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.token.key, 'jwt_token_123');
        },
        onFailure: (_) =>
            fail('should be Success — no refresh on verifier failure'),
      );
      verifyNever(() => mockRefreshTokenUseCase(any()));
    });

    test('token_save_throws_after_refresh_still_returns_success', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));
      when(
        () => mockLocalRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired('jwt_token_123'),
      ).thenAnswer((_) async => true);
      when(
        () => mockRefreshTokenUseCase(any()),
      ).thenAnswer((_) async => const Success(newToken));
      when(
        () => mockTokenStore.save(any()),
      ).thenThrow(Exception('storage down'));

      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.token.key, 'new_jwt');
        },
        onFailure: (_) => fail('should be Success — best-effort token save'),
      );
    });
  });
}
