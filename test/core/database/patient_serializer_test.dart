import 'package:clean_architecture_sdd_harness/core/database/serializers/patient_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatientSerializer round-trip', () {
    const entity = PatientEntity(id: 'PT-98765', name: 'John Doe');

    test('entity survives toMap + fromMap', () {
      final map = PatientSerializer.toMap(entity);
      final restored = PatientSerializer.fromMap(map);

      expect(restored, entity);
    });

    test('toMap covers every entity field', () {
      final map = PatientSerializer.toMap(entity);

      expect(map, {'id': 'PT-98765', 'name': 'John Doe'});
    });
  });
}
