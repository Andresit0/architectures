import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

void main() {
  group('PatientEntity', () {
    const entity = PatientEntity(
      id: '1',
      name: 'John Doe',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const PatientEntity(id: '1', name: 'John Doe')),
      );
    });

    test('inequality detects different values', () {
      expect(
        entity,
        isNot(equals(const PatientEntity(id: '2', name: 'Jane Doe'))),
      );
    });

    test('fromJson creates entity from JSON map', () {
      final json = {'id': '1', 'name': 'John Doe'};
      final result = PatientEntity.fromJson(json);
      expect(result.id, '1');
      expect(result.name, 'John Doe');
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(id: '2');
      expect(copy.id, '2');
      expect(copy.name, 'John Doe');
    });
  });
}
