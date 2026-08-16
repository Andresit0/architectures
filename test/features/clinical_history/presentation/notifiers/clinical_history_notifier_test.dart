import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/usecases/load_clinical_histories_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/usecases/refresh_clinical_histories_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_state.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import '../../../../helpers/mocks.dart';

class _MockLoadUseCase extends Mock implements LoadClinicalHistoriesUseCase {}

class _MockRefreshUseCase extends Mock
    implements RefreshClinicalHistoriesUseCase {}

const _tEntity1 = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: ClinicalHistoryServiceEntity(
    code: 'GEN',
    name: 'General Medicine',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-001',
    name: 'Central Medical Center',
    city: 'Quito',
  ),
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
const _tEntity2 = ClinicalHistoryEntity(
  id: 'ch2',
  encounterNumber: 'ENC-002',
  service: ClinicalHistoryServiceEntity(
    code: 'PED',
    name: 'Pediatrics',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-002',
    name: 'North Side Clinic',
    city: 'Guayaquil',
  ),
  professional: null,
  encounterDate: '2026-02-01',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'closed', label: 'Closed'),
);
const _tList = [_tEntity1, _tEntity2];
const _tNewList = [_tEntity2];
const _tEmpty = <ClinicalHistoryEntity>[];

void main() {
  late ProviderContainer container;
  late _MockLoadUseCase mockLoadUseCase;
  late _MockRefreshUseCase mockRefreshUseCase;
  late FakeLogger fakeLogger;

  setUp(() {
    registerFallbackValue(const NoParams());
    mockLoadUseCase = _MockLoadUseCase();
    mockRefreshUseCase = _MockRefreshUseCase();
    fakeLogger = FakeLogger();
    container = ProviderContainer(
      overrides: [
        loadClinicalHistoriesUseCaseProvider.overrideWith(
          (ref) => mockLoadUseCase,
        ),
        refreshClinicalHistoriesUseCaseProvider.overrideWith(
          (ref) => mockRefreshUseCase,
        ),
        loggerProvider.overrideWithValue(fakeLogger),
      ],
    );
    container.listen<ClinicalHistoryState>(
      clinicalHistoryProvider,
      (previous, next) {},
    );
    container.listen<AppError?>(
      clinicalHistoryRefreshErrorProvider,
      (previous, next) {},
    );
    addTearDown(container.dispose);
  });

  group('ClinicalHistoryNotifier', () {
    test('build_returns_initial_state', () {
      expect(
        container.read(clinicalHistoryProvider),
        isA<ClinicalHistoryInitial>(),
      );
    });

    test('load_success_sets_loaded_state', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Success(_tList));

      await container.read(clinicalHistoryProvider.notifier).load();

      final state = container.read(clinicalHistoryProvider);
      expect(state, isA<ClinicalHistoryLoaded>());
      expect((state as ClinicalHistoryLoaded).clinicalHistory, _tList);
    });

    test('load_failure_sets_failure_state', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      await container.read(clinicalHistoryProvider.notifier).load();

      final state = container.read(clinicalHistoryProvider);
      expect(state, isA<ClinicalHistoryFailure>());
      expect((state as ClinicalHistoryFailure).error, isA<NetworkError>());
      expect(
        fakeLogger.errorMessages,
        contains('[clinical_history] load failed'),
      );
    });

    test('load_empty_list_sets_loaded_with_empty_list', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Success(_tEmpty));

      await container.read(clinicalHistoryProvider.notifier).load();

      final state = container.read(clinicalHistoryProvider);
      expect(state, isA<ClinicalHistoryLoaded>());
      expect((state as ClinicalHistoryLoaded).clinicalHistory, isEmpty);
    });

    test('refresh_success_replaces_loaded_state', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Success(_tList));
      when(
        () => mockRefreshUseCase.call(any()),
      ).thenAnswer((_) async => const Success(_tNewList));

      final notifier = container.read(clinicalHistoryProvider.notifier);
      await notifier.load();
      expect(
        (container.read(clinicalHistoryProvider) as ClinicalHistoryLoaded)
            .clinicalHistory,
        _tList,
      );

      await notifier.refresh();

      final state = container.read(clinicalHistoryProvider);
      expect(state, isA<ClinicalHistoryLoaded>());
      expect((state as ClinicalHistoryLoaded).clinicalHistory, _tNewList);
    });

    test('refresh_keeps_loaded_state_while_in_flight', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Success(_tList));
      final completer = Completer<Result<List<ClinicalHistoryEntity>>>();
      when(
        () => mockRefreshUseCase.call(any()),
      ).thenAnswer((_) => completer.future);

      final notifier = container.read(clinicalHistoryProvider.notifier);
      await notifier.load();
      expect(
        container.read(clinicalHistoryProvider),
        isA<ClinicalHistoryLoaded>(),
      );

      final refreshFuture = notifier.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(clinicalHistoryProvider),
        isA<ClinicalHistoryLoaded>(),
        reason:
            'refresh must keep the current list visible while in flight '
            '(no intermediate Loading that would blank the list)',
      );

      completer.complete(const Success(_tNewList));
      await refreshFuture;
      final state =
          container.read(clinicalHistoryProvider) as ClinicalHistoryLoaded;
      expect(state.clinicalHistory, _tNewList);
    });

    test('refresh_failure_from_loaded_keeps_list_and_emits_error', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Success(_tList));
      when(
        () => mockRefreshUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final notifier = container.read(clinicalHistoryProvider.notifier);
      await notifier.load();
      expect(
        container.read(clinicalHistoryProvider),
        isA<ClinicalHistoryLoaded>(),
      );

      await notifier.refresh();

      final state = container.read(clinicalHistoryProvider);
      expect(
        state,
        isA<ClinicalHistoryLoaded>(),
        reason: 'a failed refresh must keep the last loaded list visible',
      );
      expect((state as ClinicalHistoryLoaded).clinicalHistory, _tList);
      expect(
        container.read(clinicalHistoryRefreshErrorProvider),
        isA<NetworkError>(),
      );
      expect(
        fakeLogger.errorMessages,
        contains('[clinical_history] refresh failed'),
      );
    });

    test('refresh_failure_without_loaded_list_sets_failure_state', () async {
      when(
        () => mockRefreshUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final notifier = container.read(clinicalHistoryProvider.notifier);
      await notifier.refresh();

      final state = container.read(clinicalHistoryProvider);
      expect(state, isA<ClinicalHistoryFailure>());
      expect((state as ClinicalHistoryFailure).error, isA<NetworkError>());
      expect(
        fakeLogger.errorMessages,
        contains('[clinical_history] refresh failed'),
      );
    });

    test('reset_returns_initial_state', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final notifier = container.read(clinicalHistoryProvider.notifier);
      await notifier.load();
      expect(
        container.read(clinicalHistoryProvider),
        isA<ClinicalHistoryFailure>(),
      );

      notifier.reset();

      expect(
        container.read(clinicalHistoryProvider),
        isA<ClinicalHistoryInitial>(),
      );
    });
  });
}
