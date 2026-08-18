import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/repositories/i_lab_results_repository.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/usecases/load_lab_results_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/usecases/refresh_lab_results_usecase.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _MockRepository extends Mock implements ILabResultsRepository {}

const _tRange = LabResultReferenceRangeEntity(low: 13.0, high: 17.0);

final _tResult = LabResultEntity(
  id: 'res-001',
  testCode: 'GLU',
  testName: 'Glucose',
  category: 'Chemistry',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: _tRange,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 1, 15),
      value: 14.8,
      textValue: null,
    ),
  ],
);

final _tList = [_tResult];

void main() {
  late _MockRepository repository;
  late LoadLabResultsUseCase loadUseCase;
  late RefreshLabResultsUseCase refreshUseCase;

  setUp(() {
    repository = _MockRepository();
    loadUseCase = LoadLabResultsUseCase(repository: repository);
    refreshUseCase = RefreshLabResultsUseCase(repository: repository);
  });

  group('LoadLabResultsUseCase', () {
    test('load_delegates_to_repository_and_returns_result_unchanged', () async {
      when(
        () => repository.loadLabResults(),
      ).thenAnswer((_) async => Success(_tList));

      final result = await loadUseCase(NoParams());

      verify(() => repository.loadLabResults()).called(1);
      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, _tList),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('load_returns_failure_when_repository_fails', () async {
      when(
        () => repository.loadLabResults(),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final result = await loadUseCase(NoParams());

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });
  });

  group('RefreshLabResultsUseCase', () {
    test(
      'refresh_delegates_to_repository_and_returns_result_unchanged',
      () async {
        when(
          () => repository.refreshLabResults(),
        ).thenAnswer((_) async => Success(_tList));

        final result = await refreshUseCase(NoParams());

        verify(() => repository.refreshLabResults()).called(1);
        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tList),
          onFailure: (_) => fail('should be Success'),
        );
      },
    );

    test('refresh_returns_failure_when_repository_fails', () async {
      when(
        () => repository.refreshLabResults(),
      ).thenAnswer((_) async => const Failure(ApiError()));

      final result = await refreshUseCase(NoParams());

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
    });
  });
}
