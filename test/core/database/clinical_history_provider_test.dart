import 'package:clean_architecture_sdd_harness/core/database/tables/clinical_history.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('clinicalHistoryStoreProvider', () {
    test('should be a Provider<IClinicalHistoryStore>', () {
      expect(clinicalHistoryStoreProvider, isA<Provider<IClinicalHistoryStore>>());
    });
  });
}
