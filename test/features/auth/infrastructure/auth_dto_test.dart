import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/dtos/_dtos.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenDto', () {
    final validJson = {'type': 'Bearer', 'key': 'some-jwt-token'};

    test('fromJson creates TokenDto from valid JSON', () {
      final dto = TokenDto.fromJson(validJson);
      expect(dto.type, 'Bearer');
      expect(dto.key, 'some-jwt-token');
    });

    test('fromJson throws when field is missing', () {
      expect(
        () => TokenDto.fromJson({'type': 'Bearer'}),
        throwsA(isA<Object>()),
      );
      expect(
        () => TokenDto.fromJson({'key': 'some-jwt-token'}),
        throwsA(isA<Object>()),
      );
    });

    test('toJson roundtrip produces same values', () {
      final dto = TokenDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['type'], 'Bearer');
      expect(json['key'], 'some-jwt-token');
      final restored = TokenDto.fromJson(json);
      expect(restored, dto);
    });
  });

  group('PatientDto', () {
    final validJson = {'id': 'patient-1', 'name': 'John Doe'};

    test('fromJson creates PatientDto from valid JSON', () {
      final dto = PatientDto.fromJson(validJson);
      expect(dto.id, 'patient-1');
      expect(dto.name, 'John Doe');
    });

    test('toJson roundtrip produces same values', () {
      final dto = PatientDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['id'], 'patient-1');
      expect(json['name'], 'John Doe');
      final restored = PatientDto.fromJson(json);
      expect(restored, dto);
    });
  });

  group('ClinicalHistoryDto', () {
    final validJson = {
      'id': 'ch-1',
      'encounter_number': 'ENC-001',
      'service': {'code': 'SVC01', 'name': 'General', 'category': 'A'},
      'facility': {'id': 'fac-1', 'name': 'Hospital', 'city': 'City'},
      'professional': {
        'id': 'prof-1',
        'fullname': 'Dr. Smith',
        'specialty': 'Cardiology',
      },
      'encounter_date': '2024-01-15',
      'created_at': '2024-01-15T10:00:00.000Z',
      'updated_at': '2024-01-15T11:00:00.000Z',
      'published_at': '2024-01-15T12:00:00.000Z',
      'summary': 'Patient visit summary',
      'description': 'Detailed description',
      'diagnosis': [
        {'code': 'D01', 'name': 'Diagnosis 1'},
      ],
      'observations': ['Observation 1'],
      'attachments': [
        {
          'id': 'att-1',
          'type': 'pdf',
          'name': 'report.pdf',
          'size_bytes': 1024,
          'url': 'https://example.com/report.pdf',
        },
      ],
      'state': {'code': 'active', 'label': 'Active'},
    };

    test('fromJson creates ClinicalHistoryDto from valid JSON', () {
      final dto = ClinicalHistoryDto.fromJson(validJson);
      expect(dto.id, 'ch-1');
      expect(dto.encounterNumber, 'ENC-001');
      expect(dto.service.code, 'SVC01');
      expect(dto.facility.id, 'fac-1');
      expect(dto.professional!.fullname, 'Dr. Smith');
      expect(dto.encounterDate, '2024-01-15');
      expect(dto.createdAt, isA<DateTime>());
      expect(dto.diagnosis.length, 1);
      expect(dto.observations, ['Observation 1']);
      expect(dto.attachments.length, 1);
      expect(dto.state!.code, 'active');
    });

    test('toJson roundtrip produces same values', () {
      final dto = ClinicalHistoryDto.fromJson(validJson);
      final json = dto.toJson();
      final restored = ClinicalHistoryDto.fromJson(json);
      expect(restored, dto);
    });
  });

  group('LoginResponseDto', () {
    test('fromJson creates LoginResponseDto with nested objects', () {
      final json = {
        'patient': {'id': 'p-1', 'name': 'John'},
        'token': {'type': 'Bearer', 'key': 'token-123'},
        'clinical_history': [
          {
            'id': 'ch-1',
            'encounter_number': 'ENC-001',
            'service': {'code': 'SVC01', 'name': 'General', 'category': 'A'},
            'facility': {'id': 'fac-1', 'name': 'Hospital', 'city': 'City'},
            'professional': null,
            'encounter_date': '2024-01-15',
            'created_at': null,
            'updated_at': null,
            'published_at': null,
            'summary': null,
            'description': null,
            'diagnosis': [],
            'observations': [],
            'attachments': [],
            'state': null,
          },
        ],
      };

      final dto = LoginResponseDto.fromJson(json);
      expect(dto.patient.id, 'p-1');
      expect(dto.token.type, 'Bearer');
      expect(dto.clinicalHistory.length, 1);
      expect(dto.clinicalHistory.first.id, 'ch-1');
    });

    test('toJson roundtrip produces same values', () {
      final json = <String, dynamic>{
        'patient': <String, dynamic>{'id': '1', 'name': 'John Doe'},
        'token': <String, dynamic>{'type': 'Bearer', 'key': 'jwt_token'},
        'clinical_history': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'ch1',
            'encounter_number': 'ENC-001',
            'service': <String, dynamic>{
              'code': 'GEN',
              'name': 'General Medicine',
              'category': 'consultation',
            },
            'facility': <String, dynamic>{
              'id': 'FAC-001',
              'name': 'Central Medical Center',
              'city': 'Quito',
            },
            'professional': null,
            'encounter_date': '2026-01-15',
            'created_at': '2026-01-15T10:00:00.000Z',
            'updated_at': '2026-01-15T11:00:00.000Z',
            'published_at': '2026-01-15T12:00:00.000Z',
            'summary': null,
            'description': null,
            'diagnosis': <Map<String, dynamic>>[],
            'observations': <String>[],
            'attachments': <Map<String, dynamic>>[],
            'state': null,
          },
        ],
      };

      final dto = LoginResponseDto.fromJson(json);
      final jsonOut = dto.toJson();

      // Verify toJson preserves values
      expect(jsonOut['patient']['id'], '1');
      expect(jsonOut['token']['key'], 'jwt_token');
      final historyList = jsonOut['clinical_history'] as List;
      expect(historyList.length, 1);
      expect(
        (historyList[0] as Map<String, dynamic>)['encounter_number'],
        'ENC-001',
      );

      // Verify full roundtrip
      final restored = LoginResponseDto.fromJson(jsonOut);
      expect(restored, dto);
    });

    test('clinicalHistory defaults to empty list when absent', () {
      final json = {
        'patient': {'id': 'p-1', 'name': 'John'},
        'token': {'type': 'Bearer', 'key': 'token-123'},
      };

      final dto = LoginResponseDto.fromJson(json);
      expect(dto.clinicalHistory, isA<List<ClinicalHistoryDto>>());
      expect(dto.clinicalHistory, isEmpty);
    });
  });
}
