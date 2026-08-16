import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_local_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/repositories/auth_local_repository_impl.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class _MockLocalDatasource extends Mock implements ILocalAuthDatasource {}

final _loginResponseEntity = LoginResponseEntity(
  patient: PatientEntity(id: '1', name: 'John Doe'),
  token: TokenEntity(key: 'token'),
  clinicalHistory: [],
);

void main() {
  late _MockLocalDatasource mockLocal;
  late AuthLocalRepositoryImpl repository;

  setUp(() {
    registerFallbackValue(_loginResponseEntity);
    mockLocal = _MockLocalDatasource();
    repository = AuthLocalRepositoryImpl(localDatasource: mockLocal);
  });

  group('saveSession', () {
    test('saveSession_success_returns_Success', () async {
      when(
        () => mockLocal.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.saveSession(
        data: _loginResponseEntity,
        email: Email.raw('test@example.com'),
        passwordHash: PasswordHash.raw('hash'),
      );

      expect(result.isSuccess, isTrue);
    });

    test('saveSession_failure_returns_UnexpectedError', () async {
      when(
        () => mockLocal.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenThrow(Exception('db error'));

      final result = await repository.saveSession(
        data: _loginResponseEntity,
        email: Email.raw('a@b.com'),
        passwordHash: PasswordHash.raw('hash'),
      );

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (f) => expect(f, isA<UnexpectedError>()),
      );
    });
  });

  group('clearSession', () {
    test('clearSession_success_returns_Success', () async {
      when(() => mockLocal.clearSession()).thenAnswer((_) async {});

      final result = await repository.clearSession();

      expect(result.isSuccess, isTrue);
    });

    test('clearSession_failure_returns_UnexpectedError', () async {
      when(
        () => mockLocal.clearSession(),
      ).thenThrow(Exception('storage error'));

      final result = await repository.clearSession();

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (f) => expect(f, isA<UnexpectedError>()),
      );
    });
  });

  group('resetAccount', () {
    test('resetAccount_success_returns_Success', () async {
      when(() => mockLocal.resetAccount()).thenAnswer((_) async {});

      final result = await repository.resetAccount();

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.resetAccount()).called(1);
    });

    test('resetAccount_failure_returns_UnexpectedError', () async {
      when(() => mockLocal.resetAccount()).thenThrow(Exception('wipe error'));

      final result = await repository.resetAccount();

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (f) => expect(f, isA<UnexpectedError>()),
      );
    });
  });

  group('restoreSession', () {
    test('restoreSession_valid_returns_Success_with_entity', () async {
      when(
        () => mockLocal.restoreSession(),
      ).thenAnswer((_) async => _loginResponseEntity);

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isNotNull);
          expect(entity!.patient.id, '1');
          expect(entity.token.key, 'token');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('restoreSession_no_session_returns_null', () async {
      when(() => mockLocal.restoreSession()).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      result.fold(
        onSuccess: (entity) => expect(entity, isNull),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('restoreSession_failure_returns_UnexpectedError', () async {
      when(() => mockLocal.restoreSession()).thenThrow(Exception('db error'));

      final result = await repository.restoreSession();

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (f) => expect(f, isA<UnexpectedError>()),
      );
    });
  });
}
