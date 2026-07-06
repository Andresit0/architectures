import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

void main() {
  group('TokenEntity', () {
    const entity = TokenEntity(
      type: 'Bearer',
      key: 'sample-jwt-token',
      expiresInHours: 24,
      expirationDate: null,
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const TokenEntity(
          type: 'Bearer',
          key: 'sample-jwt-token',
          expiresInHours: 24,
          expirationDate: null,
        )),
      );
    });

    test('fromJson creates entity from JSON map', () {
      final json = {
        'type': 'Bearer',
        'key': 'sample-jwt-token',
        'expires_in_hours': 24,
        'expiration_date': '2026-06-26T00:00:00.000',
      };
      final result = TokenEntity.fromJson(json);
      expect(result.type, 'Bearer');
      expect(result.key, 'sample-jwt-token');
      expect(result.expiresInHours, 24);
    });

    test('copyWith creates modified copy', () {
      final copy = entity.copyWith(key: 'new-token');
      expect(copy.key, 'new-token');
      expect(copy.type, 'Bearer');
    });
  });

  group('LoginResponseEntity', () {
    const patient = PatientEntity(id: '1', name: 'John Doe');
    const token = TokenEntity(
      type: 'Bearer',
      key: 'token',
      expiresInHours: 24,
      expirationDate: null,
    );
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
    const clinicalHistory = [
      ClinicalHistoryEntity(
        id: 'ch1',
        encounterNumber: 'ENC-001',
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
      ),
    ];

    const entity = LoginResponseEntity(
      patient: patient,
      token: token,
      clinicalHistory: clinicalHistory,
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const LoginResponseEntity(
          patient: patient,
          token: token,
          clinicalHistory: clinicalHistory,
        )),
      );
    });

    test('fromJson creates entity from JSON map', () {
      final json = {
        'patient': {'id': '1', 'name': 'John Doe'},
        'token': {
          'type': 'Bearer',
          'key': 'token',
          'expires_in_hours': 24,
          'expiration_date': null,
        },
        'clinical_history': [
          {
            'id': 'ch1',
            'encounter_number': 'ENC-001',
            'service': {'code': 'GEN', 'name': 'General Medicine', 'category': 'consultation'},
            'facility': {
              'id': 'FAC-001',
              'name': 'Central Medical Center',
              'city': 'Quito',
            },
            'encounter_date': '2026-01-15',
            'created_at': '2026-01-15T10:00:00.000Z',
            'updated_at': '2026-01-15T11:00:00.000Z',
            'diagnosis': [],
            'observations': [],
            'attachments': [],
          },
        ],
      };
      final result = LoginResponseEntity.fromJson(json);
      expect(result.patient.id, '1');
      expect(result.token.key, 'token');
      expect(result.clinicalHistory, isNotNull);
      expect(result.clinicalHistory!.length, 1);
      expect(result.clinicalHistory!.first.service.code, 'GEN');
    });

    test('copyWith creates modified copy', () {
      final modifiedPatient = PatientEntity(id: '2', name: 'Jane Doe');
      final copy = entity.copyWith(patient: modifiedPatient);
      expect(copy.patient.id, '2');
      expect(copy.token.key, 'token');
    });

    test('clinicalHistory can be null', () {
      const entityWithoutHistory = LoginResponseEntity(
        patient: patient,
        token: token,
        clinicalHistory: null,
      );
      expect(entityWithoutHistory.clinicalHistory, isNull);
    });
  });
}
