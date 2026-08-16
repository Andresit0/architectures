import 'package:clean_architecture_sdd_harness/core/database/serializers/clinical_history_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalHistorySerializer round-trip', () {
    test('fully populated entity survives toMap + fromMap', () {
      const entity = ClinicalHistoryEntity(
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
        professional: ClinicalHistoryProfessionalEntity(
          id: 'PRO-1',
          fullname: 'Dr. Smith',
          specialty: 'Cardiology',
        ),
        encounterDate: '2026-01-15',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Follow up',
        description: 'Patient recovered as expected',
        diagnosis: [
          ClinicalHistoryDiagnosisEntity(code: 'D1', name: 'Hypertension'),
        ],
        observations: ['BP stable'],
        attachments: [
          ClinicalHistoryAttachmentEntity(
            id: 'ATT-1',
            type: 'pdf',
            name: 'report.pdf',
            sizeBytes: 2048,
            url: 'https://cdn.example.com/report.pdf',
          ),
        ],
        state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
      );

      final map = ClinicalHistorySerializer.toMap(entity);
      final restored = ClinicalHistorySerializer.fromMap(map);

      expect(restored, entity);
    });

    test('entity with nullable fields survives round-trip', () {
      const entity = ClinicalHistoryEntity(
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
        state: null,
      );

      final map = ClinicalHistorySerializer.toMap(entity);
      final restored = ClinicalHistorySerializer.fromMap(map);

      expect(restored, entity);
    });

    test('toMap covers every entity field', () {
      const entity = ClinicalHistoryEntity(
        id: 'ch3',
        encounterNumber: 'ENC-003',
        service: ClinicalHistoryServiceEntity(
          code: 'CAR',
          name: 'Cardiology',
          category: 'consultation',
        ),
        facility: ClinicalHistoryFacilityEntity(
          id: 'FAC-003',
          name: 'Heart Center',
          city: 'Lima',
        ),
        professional: null,
        encounterDate: '2026-03-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'x',
        description: 'y',
        diagnosis: [],
        observations: [],
        attachments: [],
        state: null,
      );

      final map = ClinicalHistorySerializer.toMap(entity);

      expect(
        map.keys,
        containsAll([
          'id',
          'encounter_number',
          'service',
          'facility',
          'encounter_date',
          'summary',
          'description',
          'diagnosis',
          'observations',
          'attachments',
        ]),
      );
      expect(map['service'], isA<Map<String, dynamic>>());
      expect(map['facility'], isA<Map<String, dynamic>>());
    });
  });
}
