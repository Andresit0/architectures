import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/core/network/contracts/_contracts.lib.dart';

void main() {
  group('ClinicalHistoryMapper', () {
    group('fromDtoList', () {
      test('mapea lista con elementos y sub-entidades anidadas', () {
        final dto = ClinicalHistoryDto(
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
        );

        final entities = ClinicalHistoryMapper.fromDtoList([dto]);
        expect(entities.length, 1);
        final ch = entities.first;
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

      test('mapea lista vacía', () {
        final entities = ClinicalHistoryMapper.fromDtoList([]);
        expect(entities, isEmpty);
      });
    });

    group('fromDto', () {
      test('mapea professional y state null como null', () {
        final dto = ClinicalHistoryDto(
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
        );

        final ch = ClinicalHistoryMapper.fromDto(dto);
        expect(ch.professional, isNull);
        expect(ch.state, isNull);
        expect(ch.createdAt, isNull);
      });

      test('mapea sub-entidades de diagnóstico, adjuntos y observaciones', () {
        final dto = ClinicalHistoryDto(
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
          createdAt: null,
          updatedAt: null,
          publishedAt: null,
          summary: null,
          description: null,
          diagnosis: [
            ClinicalHistoryDiagnosisDto(code: 'D02', name: 'Diagnosis 2'),
          ],
          observations: ['Obs A', 'Obs B'],
          attachments: [
            ClinicalHistoryAttachmentDto(
              id: 'att-2',
              type: 'jpg',
              name: 'photo.jpg',
              sizeBytes: 2048,
              url: 'https://example.com/photo.jpg',
            ),
          ],
          state: ClinicalHistoryStateDto(code: 'closed', label: 'Closed'),
        );

        final ch = ClinicalHistoryMapper.fromDto(dto);
        expect(ch.diagnosis.length, 1);
        expect(ch.diagnosis.first.code, 'D02');
        expect(ch.observations, ['Obs A', 'Obs B']);
        expect(ch.attachments.length, 1);
        expect(ch.attachments.first.type, 'jpg');
        expect(ch.attachments.first.sizeBytes, 2048);
        expect(ch.state!.label, 'Closed');
        expect(ch.professional!.specialty, 'Cardiology');
      });
    });
  });
}
