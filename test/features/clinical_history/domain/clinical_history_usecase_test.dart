import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/usecases/load_clinical_histories_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/usecases/refresh_clinical_histories_usecase.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _MockRepository extends Mock implements IClinicalHistoryRepository {}

const _tService = ClinicalHistoryServiceEntity(
  code: 'GEN',
  name: 'General Medicine',
  category: 'consultation',
);
const _tFacility = ClinicalHistoryFacilityEntity(
  id: 'FAC-001',
  name: 'Central Medical Center',
  city: 'Quito',
);
const _tEntity1 = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: _tService,
  facility: _tFacility,
  professional: null,
  encounterDate: '2026-01-15',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);
const _tList = [_tEntity1];

void main() {
  late _MockRepository repository;
  late LoadClinicalHistoriesUseCase loadUseCase;
  late RefreshClinicalHistoriesUseCase refreshUseCase;

  setUp(() {
    repository = _MockRepository();
    loadUseCase = LoadClinicalHistoriesUseCase(repository: repository);
    refreshUseCase = RefreshClinicalHistoriesUseCase(repository: repository);
  });

  group('LoadClinicalHistoriesUseCase', () {
    test('load_delegates_to_repository_and_returns_result_unchanged', () async {
      when(
        () => repository.loadClinicalHistories(),
      ).thenAnswer((_) async => const Success(_tList));

      final result = await loadUseCase(NoParams());

      verify(() => repository.loadClinicalHistories()).called(1);
      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, _tList),
        onFailure: (_) => fail('should be Success'),
      );
    });

    test('load_returns_failure_when_repository_fails', () async {
      when(
        () => repository.loadClinicalHistories(),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final result = await loadUseCase(NoParams());

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });
  });

  group('RefreshClinicalHistoriesUseCase', () {
    test(
      'refresh_delegates_to_repository_and_returns_result_unchanged',
      () async {
        when(
          () => repository.refreshClinicalHistories(),
        ).thenAnswer((_) async => const Success(_tList));

        final result = await refreshUseCase(NoParams());

        verify(() => repository.refreshClinicalHistories()).called(1);
        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tList),
          onFailure: (_) => fail('should be Success'),
        );
      },
    );

    test('refresh_returns_failure_when_repository_fails', () async {
      when(
        () => repository.refreshClinicalHistories(),
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
