import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_state.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

void main() {
  group('ClinicalHistoryState', () {
    test('initial is the default idle variant', () {
      const state = ClinicalHistoryInitial();
      expect(state, isA<ClinicalHistoryInitial>());
    });

    test('loading is the in-progress variant', () {
      const state = ClinicalHistoryLoading();
      expect(state, isA<ClinicalHistoryLoading>());
    });

    test('loaded carries the entity list', () {
      const list = <ClinicalHistoryEntity>[];
      const state = ClinicalHistoryLoaded(list);
      expect(state, isA<ClinicalHistoryLoaded>());
      expect(state.clinicalHistory, isEmpty);
    });

    test('failure carries an AppError', () {
      const error = NetworkError();
      const state = ClinicalHistoryFailure(error);
      expect(state, isA<ClinicalHistoryFailure>());
      expect(state.error, error);
      expect(state.error, isA<NetworkError>());
    });

    test('variants use value equality', () {
      const a = ClinicalHistoryLoading();
      const b = ClinicalHistoryLoading();
      expect(a, equals(b));
    });
  });
}
