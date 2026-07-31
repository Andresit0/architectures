import 'package:clean_architecture_sdd_harness/core/database/tables/patient_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('patientInfoStoreProvider', () {
    test('should be a Provider<IPatientInfoStore>', () {
      expect(patientInfoStoreProvider, isA<Provider<IPatientInfoStore>>());
    });
  });
}
