import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_state.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

void main() {
  group('LabResultsState', () {
    test('initial is the default idle variant', () {
      const state = LabResultsInitial();
      expect(state, isA<LabResultsInitial>());
    });

    test('loading is the in-progress variant', () {
      const state = LabResultsLoading();
      expect(state, isA<LabResultsLoading>());
    });

    test('loaded carries results, selection and period', () {
      const state = LabResultsLoaded(
        results: <LabResultEntity>[],
        selectedTestId: null,
        period: Period.all,
      );
      expect(state, isA<LabResultsLoaded>());
      expect(state.results, isEmpty);
      expect(state.selectedTestId, isNull);
      expect(state.period, Period.all);
    });

    test('loaded keeps the selection it is constructed with', () {
      const state = LabResultsLoaded(
        results: <LabResultEntity>[],
        selectedTestId: 'lr_0001',
        period: Period.sixMonths,
      );
      expect(state.selectedTestId, 'lr_0001');
      expect(state.period, Period.sixMonths);
    });

    test('failure carries an AppError', () {
      const error = NetworkError();
      const state = LabResultsFailure(error: error);
      expect(state, isA<LabResultsFailure>());
      expect(state.error, error);
      expect(state.error, isA<NetworkError>());
    });

    test('variants use value equality', () {
      const a = LabResultsLoading();
      const b = LabResultsLoading();
      expect(a, equals(b));
    });
  });
}
