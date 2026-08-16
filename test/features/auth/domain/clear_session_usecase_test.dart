import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/clear_session_usecase.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;
  late ClearSessionUseCase useCase;

  setUp(() {
    mockRepo = _MockAuthRepository();
    useCase = ClearSessionUseCase(repository: mockRepo);

    when(
      () => mockRepo.clearSession(),
    ).thenAnswer((_) async => const Success(null));
  });

  group('ClearSessionUseCase', () {
    test('delegates to repository and returns Success', () async {
      final result = await useCase();

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.clearSession()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockRepo.clearSession()).thenAnswer(
        (_) async => const Failure(
          UnexpectedError(
            'An unexpected error occurred. Please try again later.',
          ),
        ),
      );

      final result = await useCase();

      expect(result.isSuccess, isFalse);
    });
  });
}
