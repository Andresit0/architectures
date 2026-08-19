import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/save_session_input.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class _MockSessionRepository extends Mock implements ILocalAuthRepository {}

class _MockTokenStore extends Mock implements ITokenStore {}

void main() {
  late _MockSessionRepository mockSessionRepo;
  late _MockTokenStore mockTokenStore;
  late SaveSessionUseCase saveSessionUseCase;

  const response = LoginResponseEntity(
    patient: PatientEntity(id: '1', name: 'John Doe'),
    token: TokenEntity(key: 'token123'),
    clinicalHistory: [],
  );

  setUpAll(() {
    registerFallbackValue(Email.raw('test@test.com'));
    registerFallbackValue(PasswordHash.raw('somehash'));
    registerFallbackValue(
      LoginResponseEntity(
        patient: PatientEntity(id: '', name: ''),
        token: TokenEntity(key: ''),
        clinicalHistory: [],
      ),
    );
    registerFallbackValue(
      SaveSessionInput(
        data: response,
        email: Email.raw('test@test.com'),
        passwordHash: PasswordHash.raw('somehash'),
        rememberMe: false,
      ),
    );
  });

  setUp(() {
    mockSessionRepo = _MockSessionRepository();
    mockTokenStore = _MockTokenStore();
    when(() => mockTokenStore.save(any())).thenAnswer((_) async {});
    saveSessionUseCase = SaveSessionUseCase(
      sessionRepository: mockSessionRepo,
      tokenStore: mockTokenStore,
    );
  });

  SaveSessionInput input({bool rememberMe = false}) => SaveSessionInput(
    data: response,
    email: Email.raw('test@test.com'),
    passwordHash: PasswordHash.raw('somehash'),
    rememberMe: rememberMe,
  );

  group('SaveSessionUseCase', () {
    test(
      'rememberMe=true delegates to saveSession and returns Success',
      () async {
        when(
          () => mockSessionRepo.saveSession(
            data: any(named: 'data'),
            email: any(named: 'email'),
            passwordHash: any(named: 'passwordHash'),
          ),
        ).thenAnswer((_) async => const Success(null));

        final result = await saveSessionUseCase(input(rememberMe: true));

        expect(result.isSuccess, isTrue);
        verify(
          () => mockSessionRepo.saveSession(
            data: any(named: 'data'),
            email: any(named: 'email'),
            passwordHash: any(named: 'passwordHash'),
          ),
        ).called(1);
        verifyNever(() => mockTokenStore.save(any()));
      },
    );

    test('rememberMe=true propagates a saveSession failure', () async {
      when(
        () => mockSessionRepo.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final result = await saveSessionUseCase(input(rememberMe: true));

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });

    test('rememberMe=false saves the token and returns Success', () async {
      final result = await saveSessionUseCase(input(rememberMe: false));

      expect(result.isSuccess, isTrue);
      verify(() => mockTokenStore.save('token123')).called(1);
      verifyNever(
        () => mockSessionRepo.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      );
    });

    test('rememberMe=false maps a token-store throw to Failure', () async {
      when(
        () => mockTokenStore.save(any()),
      ).thenThrow(Exception('storage down'));

      final result = await saveSessionUseCase(input(rememberMe: false));

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<UnexpectedError>()),
      );
    });
  });
}
