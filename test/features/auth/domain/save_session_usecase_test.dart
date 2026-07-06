import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;
  late SaveSessionUseCase useCase;

  const patient = PatientEntity(id: '1', name: 'John Doe');
  const token = TokenEntity(
    type: 'Bearer',
    key: 'jwt_token_123',
    expiresInHours: 24,
    expirationDate: null,
  );
  const loginResponse = LoginResponseEntity(
    patient: patient,
    token: token,
    clinicalHistory: null,
  );

  setUp(() {
    registerFallbackValue(const LoginResponseEntity(
      patient: PatientEntity(id: '', name: ''),
      token: TokenEntity(
        type: '', key: '', expiresInHours: 0, expirationDate: null,
      ),
      clinicalHistory: null,
    ));
    mockRepo = _MockAuthRepository();
    useCase = SaveSessionUseCase(repository: mockRepo);

    when(
      () => mockRepo.saveSession(
        data: any(named: 'data'),
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    ).thenAnswer((_) async => const Right(null));
  });

  group('SaveSessionUseCase', () {
    test('delegates to repository', () async {
      await useCase(
        data: loginResponse,
        email: 'test@test.com',
        passwordHash: 'hash',
      );

      verify(
        () => mockRepo.saveSession(
          data: loginResponse,
          email: 'test@test.com',
          passwordHash: 'hash',
        ),
      ).called(1);
    });

    test('returns Right when repository succeeds', () async {
      final result = await useCase(
        data: loginResponse,
        email: 'test@test.com',
        passwordHash: 'hash',
      );

      expect(result.isRight(), isTrue);
    });

    test('returns Left when repository fails', () async {
      when(
        () => mockRepo.saveSession(
          data: any(named: 'data'),
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Left(UnexpectedFailure()));

      final result = await useCase(
        data: loginResponse,
        email: 'test@test.com',
        passwordHash: 'hash',
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
