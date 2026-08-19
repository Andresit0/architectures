import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_input.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_input.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/save_session_input.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockPasswordHasher extends Mock implements IPasswordHasher {}

class _MockSaveSessionUseCase extends Mock
    implements IUseCase<SaveSessionInput, void> {}

void main() {
  late _MockAuthRepository mockRepo;
  late _MockPasswordHasher mockPasswordHasher;
  late _MockSaveSessionUseCase mockSaveSessionUseCase;
  late LoginUseCase loginUseCase;
  late RefreshTokenUseCase refreshTokenUseCase;

  setUpAll(() {
    registerFallbackValue(Email.raw('test@test.com'));
    registerFallbackValue(PasswordHash.raw('somehash'));
    registerFallbackValue('');
    registerFallbackValue(
      SaveSessionInput(
        data: const LoginResponseEntity(
          patient: PatientEntity(id: '', name: ''),
          token: TokenEntity(key: ''),
          clinicalHistory: [],
        ),
        email: Email.raw('test@test.com'),
        passwordHash: PasswordHash.raw('somehash'),
        rememberMe: false,
      ),
    );
  });

  setUp(() {
    mockRepo = _MockAuthRepository();
    mockPasswordHasher = _MockPasswordHasher();
    mockSaveSessionUseCase = _MockSaveSessionUseCase();
    when(
      () => mockSaveSessionUseCase(any()),
    ).thenAnswer((_) async => const Success(null));
    loginUseCase = LoginUseCase(
      repository: mockRepo,
      passwordHasher: mockPasswordHasher,
      saveSessionUseCase: mockSaveSessionUseCase,
    );
    refreshTokenUseCase = RefreshTokenUseCase(repository: mockRepo);
  });

  group('LoginUseCase', () {
    const response = LoginResponseEntity(
      patient: PatientEntity(id: '1', name: 'John Doe'),
      token: TokenEntity(key: 'token123'),
      clinicalHistory: [],
    );

    void stubLoginSuccess() {
      when(
        () => mockPasswordHasher.hash(any()),
      ).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(response));
    }

    test('login_calls_repository_and_returns_data_on_success', () async {
      stubLoginSuccess();

      final result = await loginUseCase(
        LoginInput(email: 'test@example.com', password: 'password123'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, equals(response)),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('login_calls_repository_and_returns_failure_on_error', () async {
      when(
        () => mockPasswordHasher.hash(any()),
      ).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final result = await loginUseCase(
        LoginInput(email: 'test@example.com', password: 'password123'),
      );

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });

    test(
      'login_rememberMe_delegates_persistence_with_rememberMe_true',
      () async {
        stubLoginSuccess();

        await loginUseCase(
          LoginInput(
            email: 'test@example.com',
            password: 'password123',
            rememberMe: true,
          ),
        );

        verify(
          () => mockSaveSessionUseCase(
            any(
              that: isA<SaveSessionInput>().having(
                (s) => s.rememberMe,
                'rememberMe',
                isTrue,
              ),
            ),
          ),
        ).called(1);
      },
    );

    test('login_without_rememberMe_delegates_with_rememberMe_false', () async {
      stubLoginSuccess();

      await loginUseCase(
        LoginInput(email: 'test@example.com', password: 'password123'),
      );

      verify(
        () => mockSaveSessionUseCase(
          any(
            that: isA<SaveSessionInput>().having(
              (s) => s.rememberMe,
              'rememberMe',
              isFalse,
            ),
          ),
        ),
      ).called(1);
    });

    test('login_returns_failure_when_save_session_fails', () async {
      stubLoginSuccess();
      when(
        () => mockSaveSessionUseCase(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final result = await loginUseCase(
        LoginInput(email: 'test@example.com', password: 'password123'),
      );

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });

    test('login_returns_failure_when_hasher_throws', () async {
      when(
        () => mockPasswordHasher.hash(any()),
      ).thenThrow(Exception('hasher down'));

      final result = await loginUseCase(
        LoginInput(email: 'test@example.com', password: 'password123'),
      );

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

    test('login_hashes_the_validated_password_value', () async {
      stubLoginSuccess();

      await loginUseCase(
        LoginInput(email: 'test@example.com', password: 'password123'),
      );

      verify(() => mockPasswordHasher.hash('password123')).called(1);
    });
  });

  group('RefreshTokenUseCase', () {
    test('refreshToken_calls_repository_and_returns_data_on_success', () async {
      const token = TokenEntity(key: 'newToken');
      when(
        () => mockRepo.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => const Success(token));

      final result = await refreshTokenUseCase(
        RefreshTokenInput(token: 'oldToken'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, equals(token)),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test(
      'refreshToken_calls_repository_and_returns_failure_on_error',
      () async {
        when(
          () => mockRepo.refreshToken(token: any(named: 'token')),
        ).thenAnswer((_) async => const Failure(ApiError()));

        final result = await refreshTokenUseCase(
          RefreshTokenInput(token: 'oldToken'),
        );

        expect(result.isSuccess, isFalse);
        result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<ApiError>()),
        );
      },
    );
  });
}
