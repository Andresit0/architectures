import 'package:clean_architecture_sdd_harness/core/database/tables/patient_info_providers.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('patientInfoStoreProvider', () {
    test('should be a Provider<IPatientInfoStore>', () {
      expect(patientInfoStoreProvider, isA<Provider<IPatientInfoStore>>());
    });
  });
}
