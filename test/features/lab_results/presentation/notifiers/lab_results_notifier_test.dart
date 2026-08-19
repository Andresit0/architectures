import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/usecases/load_lab_results_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/usecases/refresh_lab_results_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_state.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import '../../../../helpers/mocks.dart';

class _MockLoadUseCase extends Mock implements LoadLabResultsUseCase {}

class _MockRefreshUseCase extends Mock implements RefreshLabResultsUseCase {}

final _tNumeric1 = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 16.8,
      textValue: null,
    ),
    LabResultValueEntity(
      date: DateTime(2026, 6, 14),
      value: 15.4,
      textValue: null,
    ),
    LabResultValueEntity(
      date: DateTime(2025, 1, 20),
      value: 12.1,
      textValue: null,
    ),
  ],
);

final _tNumeric2 = LabResultEntity(
  id: 'lr_0002',
  testCode: 'GLU',
  testName: 'Glucosa',
  category: 'Química',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 70.0, high: 110.0),
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 128.0,
      textValue: null,
    ),
  ],
);

final _tText1 = LabResultEntity(
  id: 'lr_0004',
  testCode: 'GRUPO',
  testName: 'Grupo sanguíneo',
  category: 'Inmunohematología',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: null,
      textValue: 'A Positivo (A+)',
    ),
  ],
);

final _tList = [_tNumeric1, _tNumeric2, _tText1];
final _tListWithoutSelected = [_tNumeric2, _tText1];
final _tListKeepingSelected = [_tNumeric1, _tText1];
const _tEmpty = <LabResultEntity>[];

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
        loadLabResultsUseCaseProvider.overrideWith((ref) => mockLoadUseCase),
        refreshLabResultsUseCaseProvider.overrideWith(
          (ref) => mockRefreshUseCase,
        ),
        loggerProvider.overrideWithValue(fakeLogger),
      ],
    );
    container.listen<LabResultsState>(labResultsProvider, (previous, next) {});
    container.listen<AppError?>(
      labResultsRefreshErrorProvider,
      (previous, next) {},
    );
    addTearDown(container.dispose);
  });

  group('LabResultsNotifier', () {
    test('build_returns_initial_state', () {
      expect(container.read(labResultsProvider), isA<LabResultsInitial>());
    });

    test(
      'load_success_sets_loaded_state_with_selection_first_numeric_and_period_all',
      () async {
        when(
          () => mockLoadUseCase.call(any()),
        ).thenAnswer((_) async => Success(_tList));

        await container.read(labResultsProvider.notifier).load();

        final state = container.read(labResultsProvider);
        expect(state, isA<LabResultsLoaded>());
        final loaded = state as LabResultsLoaded;
        expect(loaded.results, _tList);
        expect(loaded.selectedTestId, 'lr_0001');
        expect(loaded.period, Period.all);
      },
    );

    test('load_failure_sets_failure_state', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      await container.read(labResultsProvider.notifier).load();

      final state = container.read(labResultsProvider);
      expect(state, isA<LabResultsFailure>());
      expect((state as LabResultsFailure).error, isA<NetworkError>());
      expect(fakeLogger.errorMessages, contains('[lab_results] load failed'));
    });

    test('load_empty_list_sets_loaded_with_empty_list', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => Success(_tEmpty));

      await container.read(labResultsProvider.notifier).load();

      final state = container.read(labResultsProvider);
      expect(state, isA<LabResultsLoaded>());
      final loaded = state as LabResultsLoaded;
      expect(loaded.results, isEmpty);
      expect(loaded.selectedTestId, isNull);
      expect(loaded.period, Period.all);
    });

    test('select_test_updates_selection_without_reload', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => Success(_tList));

      final notifier = container.read(labResultsProvider.notifier);
      await notifier.load();
      expect(
        (container.read(labResultsProvider) as LabResultsLoaded).selectedTestId,
        'lr_0001',
      );

      notifier.selectTest('lr_0002');

      final state = container.read(labResultsProvider);
      expect(state, isA<LabResultsLoaded>());
      expect((state as LabResultsLoaded).selectedTestId, 'lr_0002');
      expect((state).results, _tList);
      verify(() => mockLoadUseCase.call(any())).called(1);
      verifyNever(() => mockRefreshUseCase.call(any()));
    });

    test('set_period_updates_period_without_reload', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => Success(_tList));

      final notifier = container.read(labResultsProvider.notifier);
      await notifier.load();
      expect(
        (container.read(labResultsProvider) as LabResultsLoaded).period,
        Period.all,
      );

      notifier.setPeriod(Period.sixMonths);

      final state = container.read(labResultsProvider);
      expect(state, isA<LabResultsLoaded>());
      expect((state as LabResultsLoaded).period, Period.sixMonths);
      expect(state.results, _tList);
      verify(() => mockLoadUseCase.call(any())).called(1);
      verifyNever(() => mockRefreshUseCase.call(any()));
    });

    test(
      'refresh_success_replaces_loaded_state_and_keeps_valid_selection',
      () async {
        when(
          () => mockLoadUseCase.call(any()),
        ).thenAnswer((_) async => Success(_tList));
        when(
          () => mockRefreshUseCase.call(any()),
        ).thenAnswer((_) async => Success(_tListKeepingSelected));

        final notifier = container.read(labResultsProvider.notifier);
        await notifier.load();
        expect(
          (container.read(labResultsProvider) as LabResultsLoaded)
              .selectedTestId,
          'lr_0001',
        );

        await notifier.refresh();

        final state = container.read(labResultsProvider);
        expect(state, isA<LabResultsLoaded>());
        final loaded = state as LabResultsLoaded;
        expect(loaded.results, _tListKeepingSelected);
        expect(loaded.selectedTestId, 'lr_0001');
        expect(loaded.period, Period.all);
      },
    );

    test(
      'refresh_success_deselected_test_falls_back_to_first_numeric',
      () async {
        when(
          () => mockLoadUseCase.call(any()),
        ).thenAnswer((_) async => Success(_tList));
        when(
          () => mockRefreshUseCase.call(any()),
        ).thenAnswer((_) async => Success(_tListWithoutSelected));

        final notifier = container.read(labResultsProvider.notifier);
        await notifier.load();
        expect(
          (container.read(labResultsProvider) as LabResultsLoaded)
              .selectedTestId,
          'lr_0001',
        );

        await notifier.refresh();

        final state = container.read(labResultsProvider);
        expect(state, isA<LabResultsLoaded>());
        final loaded = state as LabResultsLoaded;
        expect(loaded.results, _tListWithoutSelected);
        expect(
          loaded.selectedTestId,
          'lr_0002',
          reason:
              'the removed selected test must fall back to the first '
              'numeric test of the new set',
        );
      },
    );

    test('refresh_failure_from_loaded_keeps_list_and_emits_error', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => Success(_tList));
      when(
        () => mockRefreshUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final notifier = container.read(labResultsProvider.notifier);
      await notifier.load();
      expect(container.read(labResultsProvider), isA<LabResultsLoaded>());

      await notifier.refresh();

      final state = container.read(labResultsProvider);
      expect(
        state,
        isA<LabResultsLoaded>(),
        reason: 'a failed refresh must keep the last loaded results visible',
      );
      expect((state as LabResultsLoaded).results, _tList);
      expect(
        container.read(labResultsRefreshErrorProvider),
        isA<NetworkError>(),
      );
      expect(
        fakeLogger.errorMessages,
        contains('[lab_results] refresh failed'),
      );
    });

    test('refresh_failure_without_loaded_list_sets_failure_state', () async {
      when(
        () => mockRefreshUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final notifier = container.read(labResultsProvider.notifier);
      await notifier.refresh();

      final state = container.read(labResultsProvider);
      expect(state, isA<LabResultsFailure>());
      expect((state as LabResultsFailure).error, isA<NetworkError>());
      expect(
        fakeLogger.errorMessages,
        contains('[lab_results] refresh failed'),
      );
    });

    test('reset_returns_initial_state', () async {
      when(
        () => mockLoadUseCase.call(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));

      final notifier = container.read(labResultsProvider.notifier);
      await notifier.load();
      expect(container.read(labResultsProvider), isA<LabResultsFailure>());

      notifier.reset();

      expect(container.read(labResultsProvider), isA<LabResultsInitial>());
    });
  });
}
