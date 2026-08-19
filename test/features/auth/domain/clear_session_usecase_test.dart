import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/clear_session_usecase.dart';

class _MockLocalAuthRepository extends Mock implements ILocalAuthRepository {}

void main() {
  late _MockLocalAuthRepository mockRepo;
  late ClearSessionUseCase useCase;

  setUp(() {
    mockRepo = _MockLocalAuthRepository();
    useCase = ClearSessionUseCase(repository: mockRepo);

    when(
      () => mockRepo.clearSession(),
    ).thenAnswer((_) async => const Success(null));
  });

  group('ClearSessionUseCase', () {
    test('delegates to repository and returns Success', () async {
      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.clearSession()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(
        () => mockRepo.clearSession(),
      ).thenAnswer((_) async => const Failure(UnexpectedError()));

      final result = await useCase(NoParams());

      expect(result.isSuccess, isFalse);
    });
  });
}
