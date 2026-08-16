import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/credential_login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import '../../../helpers/mocks.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockCredentialStore extends Mock implements ICredentialStore {}

void main() {
  late _MockAuthRepository mockRepo;
  late _MockCredentialStore mockCredentialStore;
  late FakeLogger fakeLogger;
  late CredentialLoginUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Email.raw('fallback@test.com'));
    registerFallbackValue(PasswordHash.raw('fallback_hash'));
  });

  setUp(() {
    mockRepo = _MockAuthRepository();
    mockCredentialStore = _MockCredentialStore();
    fakeLogger = FakeLogger();
    useCase = CredentialLoginUseCase(
      repository: mockRepo,
      credentialStore: mockCredentialStore,
      logger: fakeLogger,
    );
  });

  test('returns_null_success_when_no_credentials_stored', () async {
    when(
      () => mockCredentialStore.readCredentials(),
    ).thenAnswer((_) async => null);

    final result = await useCase(NoParams());

    result.fold(
      onSuccess: (data) => expect(data, isNull),
      onFailure: (_) => fail('should be Success(null)'),
    );
    verifyNever(
      () => mockRepo.login(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    );
    expect(fakeLogger.errorMessages, isEmpty);
  });

  test('returns_login_data_when_credentials_are_valid', () async {
    when(() => mockCredentialStore.readCredentials()).thenAnswer(
      (_) async => (email: 'test@example.com', passwordHash: 'hash'),
    );
    const response = LoginResponseEntity(
      patient: PatientEntity(id: '1', name: 'John Doe'),
      token: TokenEntity(key: 'token123'),
      clinicalHistory: [],
    );
    when(
      () => mockRepo.login(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    ).thenAnswer((_) async => const Success(response));

    final result = await useCase(NoParams());

    result.fold(
      onSuccess: (data) => expect(data, equals(response)),
      onFailure: (_) => fail('should be Success'),
    );
  });

  test('returns_success_null_and_logs_when_stored_email_is_invalid', () async {
    when(
      () => mockCredentialStore.readCredentials(),
    ).thenAnswer((_) async => (email: 'not-an-email', passwordHash: 'hash'));

    final result = await useCase(NoParams());

    result.fold(
      onSuccess: (data) => expect(data, isNull),
      onFailure: (_) => fail('should be Success(null)'),
    );
    expect(
      fakeLogger.errorMessages,
      contains('[auth] stored credentials failed validation'),
    );
    expect(fakeLogger.errorTechnicalMessages, contains('invalid email'));
    verifyNever(
      () => mockRepo.login(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    );
  });

  test(
    'returns_success_null_and_logs_when_stored_passwordHash_is_empty',
    () async {
      when(
        () => mockCredentialStore.readCredentials(),
      ).thenAnswer((_) async => (email: 'test@example.com', passwordHash: ''));

      final result = await useCase(NoParams());

      result.fold(
        onSuccess: (data) => expect(data, isNull),
        onFailure: (_) => fail('should be Success(null)'),
      );
      expect(
        fakeLogger.errorMessages,
        contains('[auth] stored credentials failed validation'),
      );
      expect(
        fakeLogger.errorTechnicalMessages,
        contains('invalid passwordHash'),
      );
      verifyNever(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      );
    },
  );

  test('returns_failure_when_credential_store_throws', () async {
    when(
      () => mockCredentialStore.readCredentials(),
    ).thenThrow(Exception('storage down'));

    final result = await useCase(NoParams());

    expect(result.isSuccess, isFalse);
    result.fold(
      onSuccess: (_) => fail('should be Failure'),
      onFailure: (error) => expect(error, isA<UnexpectedError>()),
    );
    verifyNever(
      () => mockRepo.login(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    );
  });
}
