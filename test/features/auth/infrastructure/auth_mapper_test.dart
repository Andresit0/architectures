import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/dtos/_dtos.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/mappers/auth_mapper.dart';

void main() {
  group('AuthMapper', () {
    group('loginResponseFromDto', () {
      test('mapea todos los campos', () {
        final dto = LoginResponseDto(
          patient: PatientDto(id: '1', name: 'John'),
          token: TokenDto(type: 'Bearer', key: 'token'),
          clinicalHistory: [],
        );
        final entity = AuthMapper.loginResponseFromDto(dto);
        expect(entity.patient.id, '1');
        expect(entity.patient.name, 'John');
        expect(entity.token.type, 'Bearer');
        expect(entity.token.key, 'token');
        expect(entity.clinicalHistory, isEmpty);
      });

      test('mapea clinicalHistory con elementos', () {
        final dto = LoginResponseDto(
          patient: PatientDto(id: '1', name: 'John'),
          token: TokenDto(type: 'Bearer', key: 'token'),
          clinicalHistory: [
            ClinicalHistoryDto(
              id: 'ch1',
              encounterNumber: 'ENC-001',
              service: ClinicalHistoryServiceDto(
                code: 'SVC01',
                name: 'General',
                category: 'A',
              ),
              facility: ClinicalHistoryFacilityDto(
                id: 'fac-1',
                name: 'Hospital',
                city: 'City',
              ),
              professional: ClinicalHistoryProfessionalDto(
                id: 'prof-1',
                fullname: 'Dr. Smith',
                specialty: 'Cardiology',
              ),
              encounterDate: '2024-01-15',
              createdAt: DateTime(2024, 1, 15, 10),
              updatedAt: DateTime(2024, 1, 15, 11),
              publishedAt: DateTime(2024, 1, 15, 12),
              summary: 'Summary',
              description: 'Description',
              diagnosis: [
                ClinicalHistoryDiagnosisDto(code: 'D01', name: 'Diagnosis 1'),
              ],
              observations: ['Obs 1'],
              attachments: [
                ClinicalHistoryAttachmentDto(
                  id: 'att-1',
                  type: 'pdf',
                  name: 'report.pdf',
                  sizeBytes: 1024,
                  url: 'https://example.com/report.pdf',
                ),
              ],
              state: ClinicalHistoryStateDto(code: 'active', label: 'Active'),
            ),
          ],
        );
        final entity = AuthMapper.loginResponseFromDto(dto);
        expect(entity.clinicalHistory.length, 1);
        final ch = entity.clinicalHistory.first;
        expect(ch.id, 'ch1');
        expect(ch.encounterNumber, 'ENC-001');
        expect(ch.service.code, 'SVC01');
        expect(ch.service.name, 'General');
        expect(ch.facility.id, 'fac-1');
        expect(ch.professional!.fullname, 'Dr. Smith');
        expect(ch.encounterDate, '2024-01-15');
        expect(ch.createdAt, DateTime(2024, 1, 15, 10));
        expect(ch.diagnosis.length, 1);
        expect(ch.diagnosis.first.code, 'D01');
        expect(ch.observations, ['Obs 1']);
        expect(ch.attachments.length, 1);
        expect(ch.attachments.first.name, 'report.pdf');
        expect(ch.state!.code, 'active');
      });

      test('mapea clinicalHistory con professional null', () {
        final dto = LoginResponseDto(
          patient: PatientDto(id: '1', name: 'John'),
          token: TokenDto(type: 'Bearer', key: 'token'),
          clinicalHistory: [
            ClinicalHistoryDto(
              id: 'ch1',
              encounterNumber: 'ENC-001',
              service: ClinicalHistoryServiceDto(
                code: 'SVC01',
                name: 'General',
                category: 'A',
              ),
              facility: ClinicalHistoryFacilityDto(
                id: 'fac-1',
                name: 'Hospital',
                city: 'City',
              ),
              professional: null,
              encounterDate: '2024-01-15',
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
          ],
        );
        final entity = AuthMapper.loginResponseFromDto(dto);
        final ch = entity.clinicalHistory.first;
        expect(ch.professional, isNull);
        expect(ch.state, isNull);
        expect(ch.createdAt, isNull);
      });
    });

    group('tokenFromDto', () {
      test('mapea correctamente', () {
        final dto = TokenDto(type: 'Bearer', key: 'jwt');
        final entity = AuthMapper.tokenFromDto(dto);
        expect(entity.type, 'Bearer');
        expect(entity.key, 'jwt');
      });
    });

    group('patientFromDto', () {
      test('mapea correctamente', () {
        final dto = PatientDto(id: 'p1', name: 'John Doe');
        final entity = AuthMapper.patientFromDto(dto);
        expect(entity.id, 'p1');
        expect(entity.name, 'John Doe');
      });
    });

    group('sub-mappers', () {
      test('serviceFromDto mapea correctamente', () {
        final dto = ClinicalHistoryServiceDto(
          code: 'GEN',
          name: 'General Medicine',
          category: 'consultation',
        );
        final entity = AuthMapper.serviceFromDto(dto);
        expect(entity.code, 'GEN');
        expect(entity.name, 'General Medicine');
        expect(entity.category, 'consultation');
      });

      test('facilityFromDto mapea correctamente', () {
        final dto = ClinicalHistoryFacilityDto(
          id: 'fac-1',
          name: 'Hospital',
          city: 'Quito',
        );
        final entity = AuthMapper.facilityFromDto(dto);
        expect(entity.id, 'fac-1');
        expect(entity.name, 'Hospital');
        expect(entity.city, 'Quito');
      });

      test('professionalFromDto mapea correctamente', () {
        final dto = ClinicalHistoryProfessionalDto(
          id: 'prof-1',
          fullname: 'Dr. Smith',
          specialty: 'Cardiology',
        );
        final entity = AuthMapper.professionalFromDto(dto);
        expect(entity.id, 'prof-1');
        expect(entity.fullname, 'Dr. Smith');
        expect(entity.specialty, 'Cardiology');
      });

      test('diagnosisFromDto mapea correctamente', () {
        final dto = ClinicalHistoryDiagnosisDto(
          code: 'D01',
          name: 'Diagnosis 1',
        );
        final entity = AuthMapper.diagnosisFromDto(dto);
        expect(entity.code, 'D01');
        expect(entity.name, 'Diagnosis 1');
      });

      test('attachmentFromDto mapea correctamente', () {
        final dto = ClinicalHistoryAttachmentDto(
          id: 'att-1',
          type: 'pdf',
          name: 'report.pdf',
          sizeBytes: 1024,
          url: 'https://example.com/report.pdf',
        );
        final entity = AuthMapper.attachmentFromDto(dto);
        expect(entity.id, 'att-1');
        expect(entity.type, 'pdf');
        expect(entity.name, 'report.pdf');
        expect(entity.sizeBytes, 1024);
        expect(entity.url, 'https://example.com/report.pdf');
      });

      test('stateFromDto mapea correctamente', () {
        final dto = ClinicalHistoryStateDto(code: 'active', label: 'Active');
        final entity = AuthMapper.stateFromDto(dto);
        expect(entity.code, 'active');
        expect(entity.label, 'Active');
      });
    });

    group('VGV compliance', () {
      test('NO usa Entity.fromJson en ninguna parte', () {
        final sourceFile = File(
          'lib/features/auth/infrastructure/mappers/auth_mapper.dart',
        );
        final source = sourceFile.readAsStringSync();
        expect(
          source.contains('.fromJson'),
          isFalse,
          reason: 'El mapper no debe contener ninguna llamada a .fromJson',
        );
      });
    });
  });
}
