import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/infrastructure/datasources/clinical_history_remote_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _MockDio extends Mock implements IDioWrapper {}

const _clinicalHistoryJson = <String, dynamic>{
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
      'published_at': null,
      'summary': null,
      'description': null,
      'diagnosis': <Map<String, dynamic>>[],
      'observations': <String>[],
      'attachments': <Map<String, dynamic>>[],
      'state': <String, dynamic>{'code': 'ready', 'label': 'Available'},
    },
  ],
};

void main() {
  late _MockDio mockDio;
  late ClinicalHistoryRemoteDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(EndpointSla.unknown);
  });

  setUp(() {
    mockDio = _MockDio();
    datasource = ClinicalHistoryRemoteDatasourceImpl(
      dio: mockDio,
      appUries: const AppUris(env: DevEnvironment()),
    );
  });

  group('ClinicalHistoryRemoteDatasourceImpl', () {
    test('loadRemote_success_returns_entities_parsed_via_dto', () async {
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenAnswer((_) async => const HttpSuccess(data: _clinicalHistoryJson));

      final result = await datasource.loadRemote();

      expect(result, isA<List<ClinicalHistoryEntity>>());
      expect(result.length, 1);
      expect(result.first.id, 'ch1');
      expect(result.first.encounterNumber, 'ENC-001');
      expect(result.first.service.name, 'General Medicine');
      expect(result.first.facility.city, 'Quito');
      expect(result.first.encounterDate, '2026-01-15');
      expect(result.first.state!.label, 'Available');
      verify(() => mockDio.get(any(), sla: any(named: 'sla'))).called(1);
    });

    test('loadRemote_401_throws_ApiException_and_propagates', () async {
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenThrow(const ApiException(401));

      expect(() => datasource.loadRemote(), throwsA(isA<ApiException>()));
    });

    test('loadRemote_network_failure_throws_NoConnectionException', () async {
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenThrow(const NoConnectionException());

      expect(
        () => datasource.loadRemote(),
        throwsA(isA<NoConnectionException>()),
      );
    });

    test(
      'loadRemote_throws_UnexpectedResponseException_when_response_is_not_a_json_object',
      () async {
        when(() => mockDio.get(any(), sla: any(named: 'sla'))).thenAnswer(
          (_) async => HttpSuccess<Map<String, dynamic>>(data: null),
        );

        expect(
          () => datasource.loadRemote(),
          throwsA(
            isA<UnexpectedResponseException>().having(
              (e) => e.details,
              'details',
              'clinical history response must be a JSON object',
            ),
          ),
        );
      },
    );

    test('loadRemote_uses_EndpointSla_standard', () async {
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenAnswer((_) async => const HttpSuccess(data: _clinicalHistoryJson));

      await datasource.loadRemote();

      verify(() => mockDio.get(any(), sla: EndpointSla.standard)).called(1);
    });
  });
}
