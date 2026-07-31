import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';

class _MockDio extends Mock implements IDioWrapper {}

void main() {
  late _MockDio mockDio;
  late AuthRemoteDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(EndpointSla.unknown);
  });

  setUp(() {
    mockDio = _MockDio();
    datasource = AuthRemoteDatasourceImpl(dio: mockDio);
  });

  group('AuthRemoteDatasourceImpl', () {
    test('login_success_returns_LoginResponseEntity', () async {
      final responseJson = <String, dynamic>{
        'patient': <String, dynamic>{'id': '1', 'name': 'John Doe'},
        'token': <String, dynamic>{
          'type': 'Bearer',
          'key': 'jwt_token',
        },
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
            'encounter_date': '2026-01-15',
            'created_at': '2026-01-15T10:00:00.000Z',
            'updated_at': '2026-01-15T11:00:00.000Z',
            'diagnosis': <Map<String, dynamic>>[],
            'observations': <String>[],
            'attachments': <Map<String, dynamic>>[],
          },
        ],
      };
      when(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).thenAnswer((_) async => HttpResponse(data: responseJson));

      final result = await datasource.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      expect(result, isA<LoginResponseEntity>());
      expect(result.token.key, 'jwt_token');
      expect(result.patient.name, 'John Doe');
      expect(result.clinicalHistory, isNotNull);
      verify(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).called(1);
    });

    test('login_calls_dio', () async {
      final responseJson = <String, dynamic>{
        'patient': <String, dynamic>{'id': '1', 'name': 'John Doe'},
        'token': <String, dynamic>{
          'type': 'Bearer',
          'key': 'jwt_token',
        },
        'clinical_history': <Map<String, dynamic>>[],
      };
      when(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).thenAnswer((_) async => HttpResponse(data: responseJson));

      await datasource.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      verify(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).called(1);
    });

    test('login_401_throws_ApiException', () async {
      when(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).thenThrow(const ApiException(401));

      expect(
        () => datasource.login(
          email: 'test@example.com',
          passwordHash: 'hash',
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('refreshToken_success_returns_TokenEntity', () async {
      final responseJson = <String, dynamic>{
        'token': <String, dynamic>{
          'type': 'Bearer',
          'key': 'new_jwt_token',
        },
      };
      when(
        () => mockDio.post(
          any(),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).thenAnswer((_) async => HttpResponse(data: responseJson));

      final result = await datasource.refreshToken(token: 'old_token');

      expect(result, isA<TokenEntity>());
      expect(result.key, 'new_jwt_token');
      verify(
        () => mockDio.post(
          any(),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).called(1);
    });

    test('refreshToken_401_throws_ApiException', () async {
      when(
        () => mockDio.post(
          any(),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).thenThrow(const ApiException(401));

      expect(
        () => datasource.refreshToken(token: 'old_token'),
        throwsA(isA<ApiException>()),
      );
    });

    test('login_passes_EndpointSla_login', () async {
      final responseJson = <String, dynamic>{
        'patient': <String, dynamic>{'id': '1', 'name': 'John Doe'},
        'token': <String, dynamic>{
          'type': 'Bearer',
          'key': 'jwt_token',
        },
        'clinical_history': <Map<String, dynamic>>[],
      };
      when(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: any(named: 'sla'),
        ),
      ).thenAnswer((_) async => HttpResponse(data: responseJson));

      await datasource.login(
        email: 'test@example.com',
        passwordHash: 'hash',
      );

      verify(
        () => mockDio.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          sla: EndpointSla.login,
        ),
      ).called(1);
    });
  });
}
