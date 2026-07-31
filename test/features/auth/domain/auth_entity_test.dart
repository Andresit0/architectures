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
    );

    test('equality works correctly', () {
      expect(
        entity,
        equals(const TokenEntity(
          type: 'Bearer',
          key: 'sample-jwt-token',
        )),
      );
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
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
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


    test('copyWith creates modified copy', () {
      final modifiedPatient = PatientEntity(id: '2', name: 'Jane Doe');
      final copy = entity.copyWith(patient: modifiedPatient);
      expect(copy.patient.id, '2');
      expect(copy.token.key, 'token');
    });


  });
}
