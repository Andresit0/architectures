import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/datasources/lab_results_remote_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _MockDio extends Mock implements IDioWrapper {}

const _numericJson = <String, dynamic>{
  'id': 'lr_0001',
  'test_code': 'HB',
  'test_name': 'Hemoglobina',
  'category': 'Hematología',
  'unit': 'g/dL',
  'kind': 'numeric',
  'reference_range': <String, dynamic>{'low': 13.0, 'high': 17.0},
  'values': <Map<String, dynamic>>[
    <String, dynamic>{'date': '2026-08-10', 'value': 16.8},
    <String, dynamic>{'date': '2026-06-14', 'value': 15.4},
  ],
};

const _textJson = <String, dynamic>{
  'id': 'lr_0005',
  'test_code': 'GRUPO',
  'test_name': 'Grupo sanguíneo',
  'category': 'Inmunohematología',
  'unit': null,
  'kind': 'text',
  'reference_range': null,
  'values': <Map<String, dynamic>>[
    <String, dynamic>{'date': '2026-08-10', 'value': 'A Positivo (A+)'},
  ],
};

const _labResultsJson = <String, dynamic>{
  'lab_results': <Map<String, dynamic>>[_numericJson, _textJson],
};

void main() {
  late _MockDio mockDio;
  late LabResultsRemoteDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(EndpointSla.unknown);
  });

  setUp(() {
    mockDio = _MockDio();
    datasource = LabResultsRemoteDatasourceImpl(
      dio: mockDio,
      appUries: const AppUris(env: DevEnvironment()),
    );
  });

  group('LabResultsRemoteDatasourceImpl', () {
    test('loadRemote_success_returns_entities_parsed_via_dto', () async {
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenAnswer((_) async => const HttpSuccess(data: _labResultsJson));

      final result = await datasource.loadRemote();

      expect(result, isA<List<LabResultEntity>>());
      expect(result.length, 2);
      expect(result.first.id, 'lr_0001');
      expect(result.first.testCode, 'HB');
      expect(result.first.kind, LabResultKind.numeric);
      expect(result.first.unit, 'g/dL');
      expect(result.first.referenceRange, isNotNull);
      expect(result.first.values, hasLength(2));
      expect(result.first.values.first.value, 16.8);
      expect(result.first.values.first.textValue, isNull);
      expect(result.last.kind, LabResultKind.text);
      expect(result.last.values.single.textValue, 'A Positivo (A+)');
      verify(() => mockDio.get(any(), sla: any(named: 'sla'))).called(1);
    });

    test('loadRemote_numeric_with_range_parses_range_and_values', () async {
      when(() => mockDio.get(any(), sla: any(named: 'sla'))).thenAnswer(
        (_) async => const HttpSuccess(
          data: <String, dynamic>{
            'lab_results': <Map<String, dynamic>>[_numericJson],
          },
        ),
      );

      final result = await datasource.loadRemote();

      final entity = result.single;
      expect(entity.kind, LabResultKind.numeric);
      expect(entity.referenceRange!.low, 13.0);
      expect(entity.referenceRange!.high, 17.0);
      expect(entity.values, hasLength(2));
      for (final value in entity.values) {
        expect(value.value, isNotNull);
        expect(value.textValue, isNull);
      }
    });

    test('loadRemote_numeric_without_range_parses_null_range', () async {
      const json = <String, dynamic>{
        'lab_results': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'lr_0004',
            'test_code': 'PCR',
            'test_name': 'Proteína C reactiva',
            'category': 'Inmunología',
            'unit': 'mg/L',
            'kind': 'numeric',
            'reference_range': null,
            'values': <Map<String, dynamic>>[
              <String, dynamic>{'date': '2026-08-10', 'value': 2.4},
            ],
          },
        ],
      };
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenAnswer((_) async => const HttpSuccess(data: json));

      final entity = (await datasource.loadRemote()).single;

      expect(entity.referenceRange, isNull);
    });

    test('loadRemote_text_parses_text_values', () async {
      when(() => mockDio.get(any(), sla: any(named: 'sla'))).thenAnswer(
        (_) async => const HttpSuccess(
          data: <String, dynamic>{
            'lab_results': <Map<String, dynamic>>[_textJson],
          },
        ),
      );

      final entity = (await datasource.loadRemote()).single;

      expect(entity.kind, LabResultKind.text);
      expect(entity.unit, isNull);
      expect(entity.referenceRange, isNull);
      expect(entity.values.single.value, isNull);
      expect(entity.values.single.textValue, 'A Positivo (A+)');
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
          (_) async => const HttpSuccess<Map<String, dynamic>>(data: null),
        );

        expect(
          () => datasource.loadRemote(),
          throwsA(
            isA<UnexpectedResponseException>().having(
              (e) => e.details,
              'details',
              'lab results response must be a JSON object',
            ),
          ),
        );
      },
    );

    test('loadRemote_uses_EndpointSla_standard', () async {
      when(
        () => mockDio.get(any(), sla: any(named: 'sla')),
      ).thenAnswer((_) async => const HttpSuccess(data: _labResultsJson));

      await datasource.loadRemote();

      verify(() => mockDio.get(any(), sla: EndpointSla.standard)).called(1);
    });
  });
}
