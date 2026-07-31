import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_password_hasher.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_store.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}
class _MockPasswordHasher extends Mock implements IPasswordHasher {}
class _MockTokenStore extends Mock implements ITokenStore {}

void main() {
  late _MockAuthRepository mockRepo;
  late _MockPasswordHasher mockPasswordHasher;
  late _MockTokenStore mockTokenStore;
  late LoginUseCase loginUseCase;
  late RefreshTokenUseCase refreshTokenUseCase;

  setUpAll(() {
    registerFallbackValue(Email.create('test@test.com'));
    registerFallbackValue(PasswordHash.create('somehash'));
    registerFallbackValue('');
    registerFallbackValue(LoginResponseEntity(
      patient: PatientEntity(id: '', name: ''),
      token: TokenEntity(
        type: '',
        key: '',
      ),
      clinicalHistory: [],
    ));
  });

  setUp(() {
    mockRepo = _MockAuthRepository();
    mockPasswordHasher = _MockPasswordHasher();
    mockTokenStore = _MockTokenStore();
    when(() => mockTokenStore.save(any())).thenAnswer((_) async {});
    loginUseCase = LoginUseCase(
      repository: mockRepo,
      passwordHasher: mockPasswordHasher,
      tokenStore: mockTokenStore,
    );
    refreshTokenUseCase = RefreshTokenUseCase(
      repository: mockRepo,
    );
  });

  group('LoginUseCase', () {
    test('login_calls_repository_and_returns_data_on_success', () async {
      const response = LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'John Doe'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'token123',
        ),
        clinicalHistory: [],
      );
      when(() => mockPasswordHasher.hash(any())).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(response));

      final result = await loginUseCase(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, equals(response)),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('login_calls_repository_and_returns_failure_on_error', () async {
      when(() => mockPasswordHasher.hash(any())).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError('No internet connection')));

      final result = await loginUseCase(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });

    test('login_rememberMe_calls_saveSession_on_success', () async {
      const response = LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'John Doe'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'token123',
        ),
        clinicalHistory: [],
      );
      when(() => mockPasswordHasher.hash(any())).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(response));
      when(
        () => mockRepo.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(null));

      final result = await loginUseCase(
        email: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      );

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.saveSession(
        data: any(named: 'data'),
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      )).called(1);
    });

    test('login_saves_token_on_success', () async {
      const response = LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'John Doe'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'token123',
        ),
        clinicalHistory: [],
      );
      when(() => mockPasswordHasher.hash(any())).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(response));
      when(() => mockTokenStore.save(any())).thenAnswer((_) async {});

      await loginUseCase(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => mockTokenStore.save('token123')).called(1);
    });

    test('login_saves_token_without_rememberMe', () async {
      const response = LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'John Doe'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'token123',
        ),
        clinicalHistory: [],
      );
      when(() => mockPasswordHasher.hash(any())).thenAnswer((_) async => 'hashed_password');
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(response));
      when(() => mockTokenStore.save(any())).thenAnswer((_) async {});

      final result = await loginUseCase(
        email: 'test@example.com',
        password: 'password123',
        rememberMe: false,
      );

      expect(result.isSuccess, isTrue);
      verify(() => mockTokenStore.save('token123')).called(1);
    });
  });

  group('RefreshTokenUseCase', () {
    test('refreshToken_calls_repository_and_returns_data_on_success', () async {
      const token = TokenEntity(
        type: 'Bearer',
        key: 'newToken',
      );
      when(
        () => mockRepo.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => const Success(token));

      final result = await refreshTokenUseCase(token: 'oldToken');

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, equals(token)),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('refreshToken_calls_repository_and_returns_failure_on_error', () async {
      when(
        () => mockRepo.refreshToken(token: any(named: 'token')),
      ).thenAnswer((_) async => const Failure(ApiError(
        'The server returned an error. Please try again later.',
      )));

      final result = await refreshTokenUseCase(token: 'oldToken');

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
    });
  });
}
