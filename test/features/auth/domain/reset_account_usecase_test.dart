import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/reset_account_usecase.dart';

class _MockLocalAuthRepository extends Mock implements ILocalAuthRepository {}

void main() {
  late _MockLocalAuthRepository mockRepo;
  late ResetAccountUseCase useCase;

  setUp(() {
    mockRepo = _MockLocalAuthRepository();
    useCase = ResetAccountUseCase(repository: mockRepo);

    when(
      () => mockRepo.resetAccount(),
    ).thenAnswer((_) async => const Success(null));
  });

  group('ResetAccountUseCase', () {
    test('delegates to repository and returns Success', () async {
      final result = await useCase(NoParams());

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.resetAccount()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(
        () => mockRepo.resetAccount(),
      ).thenAnswer((_) async => const Failure(UnexpectedError()));

      final result = await useCase(NoParams());

      expect(result.isSuccess, isFalse);
    });
  });
}
