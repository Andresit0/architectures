import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;
  late LoginUseCase loginUseCase;
  late RefreshTokenUseCase refreshTokenUseCase;

  setUp(() {
    mockRepo = _MockAuthRepository();
    loginUseCase = LoginUseCase(repository: mockRepo);
    refreshTokenUseCase = RefreshTokenUseCase(repository: mockRepo);
  });

  group('LoginUseCase', () {
    test('login_calls_repository_and_returns_data_on_success', () async {
      const response = LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'John Doe'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'token123',
          expiresInHours: 24,
          expirationDate: null,
        ),
        clinicalHistory: null,
      );
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Right(response));

      final result = await loginUseCase(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data, equals(response)),
      );
    });

    test('login_calls_repository_and_returns_failure_on_error', () async {
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Left(NoConnectionFailure()));

      final result = await loginUseCase(
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

  group('RefreshTokenUseCase', () {
    test('refreshToken_calls_repository_and_returns_data_on_success', () async {
      const token = TokenEntity(
        type: 'Bearer',
        key: 'newToken',
        expiresInHours: 24,
        expirationDate: null,
      );
      when(
        () => mockRepo.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => const Right(token));

      final result = await refreshTokenUseCase(token: 'oldToken');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data, equals(token)),
      );
    });

    test('refreshToken_calls_repository_and_returns_failure_on_error', () async {
      when(
        () => mockRepo.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => const Left(ApiFailure()));

      final result = await refreshTokenUseCase(token: 'oldToken');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });
}
