import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_local_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

class _MockRemoteDatasource extends Mock implements IAuthRemoteDatasource {}

class _MockLocalDatasource extends Mock implements ILocalAuthDatasource {}

final _loginResponseEntity = LoginResponseEntity(
  patient: PatientEntity(id: '1', name: 'John Doe'),
  token: TokenEntity(
    type: 'Bearer',
    key: 'token',
    expiresInHours: 24,
    expirationDate: null,
  ),
  clinicalHistory: null,
);

const _tokenEntity = TokenEntity(
  type: 'Bearer',
  key: 'new_jwt_token',
  expiresInHours: 24,
  expirationDate: null,
);

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
    test('login_success_returns_Right', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => _loginResponseEntity);

      final result = await repository.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (entity) {
          expect(entity, isA<LoginResponseEntity>());
          expect(entity.patient.id, '1');
          expect(entity.patient.name, 'John Doe');
          expect(entity.token.type, 'Bearer');
          expect(entity.token.key, 'token');
          expect(entity.token.expiresInHours, 24);
        },
      );
    });

    test('login_failure_returns_Left', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenThrow(const ApiException(401));

      final result = await repository.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (_) => fail('should be Left'),
      );
    });

    test('login_fallback_to_local_when_no_connection', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenThrow(const NoConnectionException());
      when(() => mockLocal.restoreSession())
          .thenAnswer((_) async => _loginResponseEntity);

      final result = await repository.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (entity) {
          expect(entity, isA<LoginResponseEntity>());
          expect(entity.patient.id, '1');
          expect(entity.token.key, 'token');
        },
      );
    });

    test('login_returns_left_when_no_connection_and_no_local_data', () async {
      when(
        () => mockRemote.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenThrow(const NoConnectionException());
      when(() => mockLocal.restoreSession())
          .thenAnswer((_) async => null);

      final result = await repository.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NoConnectionFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });

  group('refreshToken', () {
    test('refreshToken_success_returns_Right', () async {
      when(
        () => mockRemote.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => _tokenEntity);

      final result = await repository.refreshToken(token: 'old_token');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (entity) {
          expect(entity, isA<TokenEntity>());
          expect(entity.key, 'new_jwt_token');
        },
      );
    });

    test('refreshToken_failure_returns_Left', () async {
      when(
        () => mockRemote.refreshToken(token: any(named: 'token')),
      ).thenThrow(const ApiException(401));

      final result = await repository.refreshToken(token: 'old_token');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });

  group('saveSession', () {
    test('saveSession_success_returns_Right', () async {
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

      expect(result.isRight(), isTrue);
    });

    test('saveSession_failure_returns_UnexpectedFailure', () async {
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

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });

  group('clearSession', () {
    test('clearSession_success_returns_Right', () async {
      when(() => mockLocal.clearSession()).thenAnswer((_) async {});

      final result = await repository.clearSession();

      expect(result.isRight(), isTrue);
    });

    test('clearSession_failure_returns_UnexpectedFailure', () async {
      when(() => mockLocal.clearSession())
          .thenThrow(Exception('storage error'));

      final result = await repository.clearSession();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });

  group('restoreSession', () {
    test('restoreSession_valid_returns_Right_with_entity', () async {
      when(() => mockLocal.restoreSession())
          .thenAnswer((_) async => _loginResponseEntity);

      final result = await repository.restoreSession();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (entity) {
          expect(entity, isNotNull);
          expect(entity!.patient.id, '1');
          expect(entity.token.key, 'token');
        },
      );
    });

    test('restoreSession_no_session_returns_null', () async {
      when(() => mockLocal.restoreSession())
          .thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      result.fold(
        (_) => fail('should be Right'),
        (entity) => expect(entity, isNull),
      );
    });

    test('restoreSession_failure_returns_UnexpectedFailure', () async {
      when(() => mockLocal.restoreSession())
          .thenThrow(Exception('db error'));

      final result = await repository.restoreSession();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });
}
