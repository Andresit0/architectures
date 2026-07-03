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

    test('fromJson creates entity from JSON map', () {
      final json = {
        'code': 'GEN',
        'name': 'General Medicine',
        'category': 'consultation',
      };
      final result = ClinicalHistoryServiceEntity.fromJson(json);
      expect(result.code, 'GEN');
      expect(result.name, 'General Medicine');
      expect(result.category, 'consultation');
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

    test('fromJson creates entity from JSON map', () {
      final json = {
        'id': 'FAC-001',
        'name': 'Central Medical Center',
        'city': 'Quito',
      };
      final result = ClinicalHistoryFacilityEntity.fromJson(json);
      expect(result.id, 'FAC-001');
      expect(result.name, 'Central Medical Center');
      expect(result.city, 'Quito');
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

    test('fromJson creates entity from JSON map', () {
      final json = {
        'id': 'DOC-1001',
        'fullname': 'Dr. Sarah Johnson',
        'specialty': 'Internal Medicine',
      };
      final result = ClinicalHistoryProfessionalEntity.fromJson(json);
      expect(result.id, 'DOC-1001');
      expect(result.fullname, 'Dr. Sarah Johnson');
      expect(result.specialty, 'Internal Medicine');
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

    test('fromJson creates entity from JSON map', () {
      final json = {
        'code': 'Z00.00',
        'name': 'General adult medical examination',
      };
      final result = ClinicalHistoryDiagnosisEntity.fromJson(json);
      expect(result.code, 'Z00.00');
      expect(result.name, 'General adult medical examination');
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

    test('fromJson creates entity from JSON map', () {
      final json = {
        'id': 'FILE-001',
        'type': 'pdf',
        'name': 'medical-report.pdf',
        'size_bytes': 248530,
        'url': 'https://example.com/report-001.pdf',
      };
      final result = ClinicalHistoryAttachmentEntity.fromJson(json);
      expect(result.id, 'FILE-001');
      expect(result.type, 'pdf');
      expect(result.name, 'medical-report.pdf');
      expect(result.sizeBytes, 248530);
      expect(result.url, 'https://example.com/report-001.pdf');
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

    test('fromJson creates entity from JSON map', () {
      final json = {'code': 'ready', 'label': 'Available'};
      final result = ClinicalHistoryStateEntity.fromJson(json);
      expect(result.code, 'ready');
      expect(result.label, 'Available');
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

    test('fromJson creates entity from JSON map', () {
      final json = {
        'id': 'ch1',
        'encounter_number': 'ENC-001',
        'service': {'code': 'GEN', 'name': 'General Medicine', 'category': 'consultation'},
        'facility': {'id': 'FAC-001', 'name': 'Central Medical Center', 'city': 'Quito'},
        'professional': {
          'id': 'DOC-1001',
          'fullname': 'Dr. Sarah Johnson',
          'specialty': 'Internal Medicine',
        },
        'encounter_date': '2026-01-15',
        'created_at': '2026-01-15T10:00:00.000Z',
        'updated_at': '2026-01-15T11:00:00.000Z',
        'summary': 'Routine checkup',
        'diagnosis': [
          {'code': 'Z00.00', 'name': 'General adult medical examination'},
        ],
        'observations': [],
        'attachments': [
          {
            'id': 'FILE-001',
            'type': 'pdf',
            'name': 'medical-report.pdf',
            'size_bytes': 248530,
            'url': 'https://example.com/report-001.pdf',
          },
        ],
      };
      final result = ClinicalHistoryEntity.fromJson(json);
      expect(result.id, 'ch1');
      expect(result.encounterNumber, 'ENC-001');
      expect(result.service.code, 'GEN');
      expect(result.facility.id, 'FAC-001');
      expect(result.professional?.id, 'DOC-1001');
      expect(result.encounterDate, '2026-01-15');
      expect(result.summary, 'Routine checkup');
      expect(result.description, isNull);
      expect(result.diagnosis.length, 1);
      expect(result.observations, isEmpty);
      expect(result.attachments.length, 1);
    });

    test('professional can be null', () {
      const entityWithoutProfessional = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: null,
        encounterDate: '2026-01-15',
        createdAt: null as dynamic,
        updatedAt: null as dynamic,
        publishedAt: null as dynamic,
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
