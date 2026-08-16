import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

void main() {
  group('ClinicalHistoryEntity (reused from shared/models)', () {
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
        id: 'DOC-1001',
        fullname: 'Dr. Sarah Johnson',
        specialty: 'Internal Medicine',
      ),
      encounterDate: '2026-01-15',
      createdAt: null,
      updatedAt: null,
      publishedAt: null,
      summary: 'Routine checkup',
      description: null,
      diagnosis: [
        ClinicalHistoryDiagnosisEntity(
          code: 'Z00.00',
          name: 'General adult medical examination',
        ),
      ],
      observations: ['Obs 1'],
      attachments: [
        ClinicalHistoryAttachmentEntity(
          id: 'FILE-001',
          type: 'pdf',
          name: 'medical-report.pdf',
          sizeBytes: 248530,
          url: 'https://example.com/report-001.pdf',
        ),
      ],
      state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
    );

    test('is constructible via the shared models barrel', () {
      expect(entity.id, 'ch1');
      expect(entity.encounterNumber, 'ENC-001');
      expect(entity.service.name, 'General Medicine');
      expect(entity.facility.city, 'Quito');
      expect(entity.professional!.fullname, 'Dr. Sarah Johnson');
      expect(entity.diagnosis.first.code, 'Z00.00');
      expect(entity.observations, ['Obs 1']);
      expect(entity.attachments.first.type, 'pdf');
      expect(entity.state!.label, 'Available');
    });

    test('equality uses value semantics', () {
      const same = ClinicalHistoryEntity(
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
          id: 'DOC-1001',
          fullname: 'Dr. Sarah Johnson',
          specialty: 'Internal Medicine',
        ),
        encounterDate: '2026-01-15',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Routine checkup',
        description: null,
        diagnosis: [
          ClinicalHistoryDiagnosisEntity(
            code: 'Z00.00',
            name: 'General adult medical examination',
          ),
        ],
        observations: ['Obs 1'],
        attachments: [
          ClinicalHistoryAttachmentEntity(
            id: 'FILE-001',
            type: 'pdf',
            name: 'medical-report.pdf',
            sizeBytes: 248530,
            url: 'https://example.com/report-001.pdf',
          ),
        ],
        state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
      );

      expect(entity, equals(same));
    });

    test('copyWith creates a modified copy', () {
      final copy = entity.copyWith(encounterNumber: 'ENC-002');
      expect(copy.encounterNumber, 'ENC-002');
      expect(copy.id, 'ch1');
    });
  });
}
