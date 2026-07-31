import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_attachment_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_diagnosis_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_professional_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_state_entity.dart';

void main() {
  group('ClinicalHistoryServiceEntity', () {
    const entity = ClinicalHistoryServiceEntity(
      code: 'GEN',
      name: 'General Medicine',
      category: 'consultation',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryServiceEntity(
          code: 'GEN',
          name: 'General Medicine',
          category: 'consultation',
        )),
      );
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(name: 'Cardiology');
      expect(copy.name, 'Cardiology');
      expect(copy.code, 'GEN');
    });

  });

  group('ClinicalHistoryFacilityEntity', () {
    const entity = ClinicalHistoryFacilityEntity(
      id: 'FAC-001',
      name: 'Central Medical Center',
      city: 'Quito',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryFacilityEntity(
          id: 'FAC-001',
          name: 'Central Medical Center',
          city: 'Quito',
        )),
      );
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(name: 'North Side Clinic');
      expect(copy.name, 'North Side Clinic');
      expect(copy.id, 'FAC-001');
    });

  });

  group('ClinicalHistoryProfessionalEntity', () {
    const entity = ClinicalHistoryProfessionalEntity(
      id: 'DOC-1001',
      fullname: 'Dr. Sarah Johnson',
      specialty: 'Internal Medicine',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryProfessionalEntity(
          id: 'DOC-1001',
          fullname: 'Dr. Sarah Johnson',
          specialty: 'Internal Medicine',
        )),
      );
    });


    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(fullname: 'Dr. Jane Smith');
      expect(copy.fullname, 'Dr. Jane Smith');
      expect(copy.id, 'DOC-1001');
    });
  });

  group('ClinicalHistoryDiagnosisEntity', () {
    const entity = ClinicalHistoryDiagnosisEntity(
      code: 'Z00.00',
      name: 'General adult medical examination',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryDiagnosisEntity(
          code: 'Z00.00',
          name: 'General adult medical examination',
        )),
      );
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(name: 'Follow-up examination');
      expect(copy.name, 'Follow-up examination');
      expect(copy.code, 'Z00.00');
    });

  });

  group('ClinicalHistoryAttachmentEntity', () {
    const entity = ClinicalHistoryAttachmentEntity(
      id: 'FILE-001',
      type: 'pdf',
      name: 'medical-report.pdf',
      sizeBytes: 248530,
      url: 'https://example.com/report-001.pdf',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryAttachmentEntity(
          id: 'FILE-001',
          type: 'pdf',
          name: 'medical-report.pdf',
          sizeBytes: 248530,
          url: 'https://example.com/report-001.pdf',
        )),
      );
    });


    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(name: 'lab-results.pdf');
      expect(copy.name, 'lab-results.pdf');
      expect(copy.id, 'FILE-001');
    });
  });

  group('ClinicalHistoryStateEntity', () {
    const entity = ClinicalHistoryStateEntity(
      code: 'ready',
      label: 'Available',
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryStateEntity(
          code: 'ready',
          label: 'Available',
        )),
      );
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(label: 'Completed');
      expect(copy.label, 'Completed');
      expect(copy.code, 'ready');
    });

  });

  group('ClinicalHistoryEntity', () {
    const service = ClinicalHistoryServiceEntity(
      code: 'GEN',
      name: 'General Medicine',
      category: 'consultation',
    );
    const facility = ClinicalHistoryFacilityEntity(
      id: 'FAC-001',
      name: 'Central Medical Center',
      city: 'Quito',
    );
    const professional = ClinicalHistoryProfessionalEntity(
      id: 'DOC-1001',
      fullname: 'Dr. Sarah Johnson',
      specialty: 'Internal Medicine',
    );
    const diagnosis = [
      ClinicalHistoryDiagnosisEntity(
        code: 'Z00.00',
        name: 'General adult medical examination',
      ),
    ];
    const attachments = [
      ClinicalHistoryAttachmentEntity(
        id: 'FILE-001',
        type: 'pdf',
        name: 'medical-report.pdf',
        sizeBytes: 248530,
        url: 'https://example.com/report-001.pdf',
      ),
    ];
    const entity = ClinicalHistoryEntity(
      id: 'ch1',
      encounterNumber: 'ENC-001',
      service: service,
      facility: facility,
      professional: professional,
      encounterDate: '2026-01-15',
      createdAt: null,
      updatedAt: null,
      publishedAt: null,
      summary: 'Routine checkup',
      description: null,
      diagnosis: diagnosis,
      observations: [],
      attachments: attachments,
      state: null,
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const ClinicalHistoryEntity(
          id: 'ch1',
          encounterNumber: 'ENC-001',
          service: service,
          facility: facility,
          professional: professional,
          encounterDate: '2026-01-15',
          createdAt: null,
          updatedAt: null,
          publishedAt: null,
          summary: 'Routine checkup',
          description: null,
          diagnosis: diagnosis,
          observations: [],
          attachments: attachments,
          state: null,
        )),
      );
    });


    test('professional can be null', () {
      const entityWithoutProfessional = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: null,
        encounterDate: '2026-01-15',
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
      expect(entityWithoutProfessional.professional, isNull);
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(encounterNumber: 'ENC-002');
      expect(copy.encounterNumber, 'ENC-002');
      expect(copy.id, 'ch1');
    });
  });
}
