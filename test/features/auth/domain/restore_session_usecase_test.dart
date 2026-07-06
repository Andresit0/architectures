import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;
  late RestoreSessionUseCase useCase;

  const loginResponse = LoginResponseEntity(
    patient: PatientEntity(id: '1', name: 'John Doe'),
    token: TokenEntity(
      type: 'Bearer',
      key: 'jwt_token_123',
      expiresInHours: 24,
      expirationDate: null,
    ),
    clinicalHistory: null,
  );

  setUp(() {
    mockRepo = _MockAuthRepository();
    useCase = RestoreSessionUseCase(repository: mockRepo);
  });

  group('RestoreSessionUseCase', () {
    test('returns Right with LoginResponseEntity when session valid', () async {
      when(() => mockRepo.restoreSession())
          .thenAnswer((_) async => Right(loginResponse));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (entity) {
          expect(entity, isNotNull);
          expect(entity!.patient.name, 'John Doe');
        },
      );
    });

    test('returns Right(null) when no session', () async {
      when(() => mockRepo.restoreSession())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      result.fold(
        (_) => fail('should be Right'),
        (entity) => expect(entity, isNull),
      );
    });

    test('returns Left when repository fails', () async {
      when(() => mockRepo.restoreSession())
          .thenAnswer((_) async => const Left(UnexpectedFailure()));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
    });
  });
}
