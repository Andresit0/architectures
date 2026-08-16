import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_verifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockConnectivityChecker extends Mock implements IConnectivityChecker {}

class _MockCredentialStore extends Mock implements ICredentialStore {}

class _MockTokenVerifier extends Mock implements ITokenVerifier {}

void main() {
  late _MockAuthRepository mockRepo;
  late _MockConnectivityChecker mockConnectivity;
  late _MockCredentialStore mockCredentialStore;
  late _MockTokenVerifier mockTokenVerifier;
  late RestoreSessionUseCase useCase;

  final loginResponse = LoginResponseEntity(
    patient: const PatientEntity(id: '1', name: 'John Doe'),
    token: const TokenEntity(type: 'Bearer', key: 'jwt_token_123'),
    clinicalHistory: [],
  );

  const newToken = TokenEntity(type: 'Bearer', key: 'new_jwt');

  setUp(() {
    registerFallbackValue(Email.create('fallback@test.com'));
    registerFallbackValue(PasswordHash.create('fallback_hash'));
    mockRepo = _MockAuthRepository();
    mockConnectivity = _MockConnectivityChecker();
    mockCredentialStore = _MockCredentialStore();
    mockTokenVerifier = _MockTokenVerifier();
    when(
      () => mockTokenVerifier.isExpired(any()),
    ).thenAnswer((_) async => false);

    useCase = RestoreSessionUseCase(
      repository: mockRepo,
      connectivityChecker: mockConnectivity,
      credentialStore: mockCredentialStore,
      tokenVerifier: mockTokenVerifier,
    );
  });

  group('RestoreSessionUseCase', () {
    test('online_with_credentials_login_success_returns_login_data', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
      when(() => mockCredentialStore.readCredentials()).thenAnswer(
        (_) async => (email: 'test@example.com', passwordHash: 'hash'),
      );
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => Success(loginResponse));
      when(() => mockCredentialStore.saveToken(any())).thenAnswer((_) async {});

      final result = await useCase();

      expect(result.isSuccess, isTrue);
      verify(() => mockCredentialStore.saveToken('jwt_token_123')).called(1);
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
      when(() => mockCredentialStore.readCredentials()).thenAnswer(
        (_) async => (email: 'test@example.com', passwordHash: 'hash'),
      );
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Failure(UnexpectedError('error')));
      when(
        () => mockRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenAnswer((_) async => false);

      final result = await useCase();

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
        () => mockCredentialStore.readCredentials(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenAnswer((_) async => false);

      final result = await useCase();

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
        () => mockCredentialStore.readCredentials(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepo.restoreSession(),
      ).thenAnswer((_) async => Success(loginResponse));
      when(
        () => mockTokenVerifier.isExpired(any()),
      ).thenAnswer((_) async => true);

      final result = await useCase();

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
          () => mockCredentialStore.readCredentials(),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepo.restoreSession(),
        ).thenAnswer((_) async => Success(loginResponse));
        when(
          () => mockTokenVerifier.isExpired('jwt_token_123'),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepo.refreshToken(token: 'jwt_token_123'),
        ).thenAnswer((_) async => const Success(newToken));
        when(
          () => mockCredentialStore.saveToken(any()),
        ).thenAnswer((_) async {});

        final result = await useCase();

        expect(result.isSuccess, isTrue);
        verify(() => mockCredentialStore.saveToken('new_jwt')).called(1);
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
      'online_with_expired_session_refresh_fails_clears_and_returns_null',
      () async {
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCredentialStore.readCredentials(),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepo.restoreSession(),
        ).thenAnswer((_) async => Success(loginResponse));
        when(
          () => mockTokenVerifier.isExpired('jwt_token_123'),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepo.refreshToken(token: 'jwt_token_123'),
        ).thenAnswer((_) async => const Failure(UnexpectedError('error')));
        when(() => mockCredentialStore.deleteAll()).thenAnswer((_) async {});

        final result = await useCase();

        result.fold(
          onSuccess: (entity) => expect(entity, isNull),
          onFailure: (_) => fail('should be Success'),
        );
        verify(() => mockCredentialStore.deleteAll()).called(1);
      },
    );

    test('no_credentials_and_no_local_session_returns_null', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(
        () => mockCredentialStore.readCredentials(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepo.restoreSession(),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase();

      result.fold(
        onSuccess: (entity) => expect(entity, isNull),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('local_session_failure_propagates_error', () async {
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(
        () => mockCredentialStore.readCredentials(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepo.restoreSession(),
      ).thenAnswer((_) async => const Failure(UnexpectedError('error')));

      final result = await useCase();

      expect(result.isSuccess, isFalse);
    });
  });
}
