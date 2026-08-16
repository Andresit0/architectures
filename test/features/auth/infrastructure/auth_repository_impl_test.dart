import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_local_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

class _MockRemoteDatasource extends Mock implements IAuthRemoteDatasource {}

class _MockLocalDatasource extends Mock implements ILocalAuthDatasource {}

final _loginResponseEntity = LoginResponseEntity(
  patient: PatientEntity(id: '1', name: 'John Doe'),
  token: TokenEntity(type: 'Bearer', key: 'token'),
  clinicalHistory: [],
);

const _tokenEntity = TokenEntity(type: 'Bearer', key: 'new_jwt_token');

void main() {
  late _MockRemoteDatasource mockRemote;
  late _MockLocalDatasource mockLocal;
  late AuthRepositoryImpl repository;

  setUp(() {
    registerFallbackValue(_loginResponseEntity);
    mockRemote = _MockRemoteDatasource();
    mockLocal = _MockLocalDatasource();
    repository = AuthRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('login', () {
    test('login_success_returns_Success', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => _loginResponseEntity);

      final result = await repository.login(
        email: Email.create('test@example.com'),
        passwordHash: PasswordHash.create('hash'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isA<LoginResponseEntity>());
          expect(entity.patient.id, '1');
          expect(entity.patient.name, 'John Doe');
          expect(entity.token.type, 'Bearer');
          expect(entity.token.key, 'token');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('login_failure_returns_Failure', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenThrow(const ApiException(401));

      final result = await repository.login(
        email: Email.create('test@example.com'),
        passwordHash: PasswordHash.create('hash'),
      );

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
    });

    test('login_fallback_to_local_when_no_connection', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenThrow(const NoConnectionException());
      when(
        () => mockLocal.restoreSession(),
      ).thenAnswer((_) async => _loginResponseEntity);

      final result = await repository.login(
        email: Email.create('test@example.com'),
        passwordHash: PasswordHash.create('hash'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isA<LoginResponseEntity>());
          expect(entity.patient.id, '1');
          expect(entity.token.key, 'token');
        },
        onFailure: (_) => fail('should be Success'),
      );
    });

    test(
      'login_returns_Failure_when_no_connection_and_no_local_data',
      () async {
        when(
          () => mockRemote.login(
            email: any(named: 'email'),
            passwordHash: any(named: 'passwordHash'),
          ),
        ).thenThrow(const NoConnectionException());
        when(() => mockLocal.restoreSession()).thenAnswer((_) async => null);

        final result = await repository.login(
          email: Email.create('test@example.com'),
          passwordHash: PasswordHash.create('hash'),
        );

        expect(result.isSuccess, isFalse);
        result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<NetworkError>()),
        );
      },
    );
  });

  group('refreshToken', () {
    test('refreshToken_success_returns_Success', () async {
      when(
        () => mockRemote.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => _tokenEntity);

      final result = await repository.refreshToken(token: 'old_token');

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isA<TokenEntity>());
          expect(entity.key, 'new_jwt_token');
        },
        onFailure: (_) => fail('Expected Success'),
      );
    });

    test('refreshToken_failure_returns_Failure', () async {
      when(
        () => mockRemote.refreshToken(token: any(named: 'token')),
      ).thenThrow(const ApiException(401));

      final result = await repository.refreshToken(token: 'old_token');

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
    });
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
        email: 'test@example.com',
        passwordHash: 'hash',
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
        email: 'a@b.com',
        passwordHash: 'hash',
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
