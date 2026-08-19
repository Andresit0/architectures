import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_auth_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/repositories/auth_remote_repository_impl.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class _MockRemoteDatasource extends Mock implements IAuthRemoteDatasource {}

final _loginResponseEntity = LoginResponseEntity(
  patient: PatientEntity(id: '1', name: 'John Doe'),
  token: TokenEntity(key: 'token'),
  clinicalHistory: [],
);

const _tokenEntity = TokenEntity(key: 'new_jwt_token');

void main() {
  late _MockRemoteDatasource mockRemote;
  late AuthRemoteRepositoryImpl repository;

  setUp(() {
    mockRemote = _MockRemoteDatasource();
    repository = AuthRemoteRepositoryImpl(remoteDatasource: mockRemote);
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
        email: Email.raw('test@example.com'),
        passwordHash: PasswordHash.raw('hash'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (entity) {
          expect(entity, isA<LoginResponseEntity>());
          expect(entity.patient.id, '1');
          expect(entity.patient.name, 'John Doe');
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
        email: Email.raw('test@example.com'),
        passwordHash: PasswordHash.raw('hash'),
      );

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
    });

    test(
      'login_offline_returns_NetworkError (strictly remote, no local fallback)',
      () async {
        when(
          () => mockRemote.login(
            email: any(named: 'email'),
            passwordHash: any(named: 'passwordHash'),
          ),
        ).thenThrow(const NoConnectionException());

        final result = await repository.login(
          email: Email.raw('test@example.com'),
          passwordHash: PasswordHash.raw('hash'),
        );

        expect(result.isSuccess, isFalse);
        result.fold(
          onSuccess: (_) =>
              fail('login must be strictly remote (online-first)'),
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
}
