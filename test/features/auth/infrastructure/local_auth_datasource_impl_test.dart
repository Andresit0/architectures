import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/datasources/local_auth_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/database/_database.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

class _MockPatientInfoStore extends Mock implements IPatientInfoStore {}

class _MockClinicalHistoryStore extends Mock implements IClinicalHistoryStore {}

class _MockTokenService extends Mock implements ITokenService {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockInternetService extends Mock implements IInternetService {}

final _patientEntity = PatientEntity(id: '1', name: 'John Doe');

final _loginResponse = LoginResponseEntity(
  patient: _patientEntity,
  token: TokenEntity(
    type: 'Bearer',
    key: 'jwt_token_123',
    expiresInHours: 24,
    expirationDate: null,
  ),
  clinicalHistory: null,
);

void main() {
  late _MockPatientInfoStore mockPatientInfo;
  late _MockClinicalHistoryStore mockClinicalHistory;
  late _MockTokenService mockTokenService;
  late _MockAppDatabase mockAppDatabase;
  late _MockInternetService mockInternetService;
  late LocalAuthDatasourceImpl datasource;

  setUp(() {
    registerFallbackValue(const PatientEntity(id: '', name: ''));
    registerFallbackValue(<ClinicalHistoryEntity>[]);
    mockPatientInfo = _MockPatientInfoStore();
    mockClinicalHistory = _MockClinicalHistoryStore();
    mockTokenService = _MockTokenService();
    mockAppDatabase = _MockAppDatabase();
    mockInternetService = _MockInternetService();
    datasource = LocalAuthDatasourceImpl(
      patientInfo: mockPatientInfo,
      clinicalHistory: mockClinicalHistory,
      tokenService: mockTokenService,
      appDatabase: mockAppDatabase,
      internetService: mockInternetService,
    );

    when(() => mockPatientInfo.save(any())).thenAnswer((_) async {});
    when(() => mockClinicalHistory.storeAll(any())).thenAnswer((_) async {});
    when(() => mockTokenService.save(any())).thenAnswer((_) async {});
    when(
      () => mockTokenService.saveCredentials(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    ).thenAnswer((_) async {});
  });

  group('LocalAuthDatasourceImpl', () {
    group('saveSession', () {
      test('calls all storage services', () async {
        await datasource.saveSession(
          data: _loginResponse,
          email: 'test@example.com',
          passwordHash: 'hash',
        );

        verify(() => mockPatientInfo.save(_patientEntity)).called(1);
        verify(() => mockClinicalHistory.storeAll([])).called(1);
        verify(() => mockTokenService.save('jwt_token_123')).called(1);
        verify(
          () => mockTokenService.saveCredentials(
            email: 'test@example.com',
            passwordHash: 'hash',
          ),
        ).called(1);
      });

      test('stores clinical history list when present', () async {
        when(() => mockClinicalHistory.storeAll(any())).thenAnswer((_) async {});

        await datasource.saveSession(
          data: _loginResponse.copyWith(
            clinicalHistory: [
              ClinicalHistoryEntity(
                id: 'ch1',
                encounterNumber: 'ENC-001',
                service: ClinicalHistoryServiceEntity(
                  code: 'GEN',
                  name: 'General Medicine',
                  category: 'consultation',
                ),
                facility: ClinicalHistoryFacilityEntity(
                  id: 'FAC-001',
                  name: 'Central Medical Center',
                  city: 'Quito',
                ),
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
            ],
          ),
          email: 'test@example.com',
          passwordHash: 'hash',
        );

        verify(() => mockClinicalHistory.storeAll(any())).called(1);
      });

      test('propagates exception from patientInfo', () async {
        when(() => mockPatientInfo.save(any())).thenThrow(Exception('db error'));

        expect(
          () => datasource.saveSession(
            data: _loginResponse,
            email: 'a@b.com',
            passwordHash: 'hash',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('clearSession', () {
      test('calls deleteAll and resetDatabase', () async {
        when(() => mockTokenService.deleteAll()).thenAnswer((_) async {});
        when(() => mockAppDatabase.resetDatabase()).thenAnswer((_) async {});

        await datasource.clearSession();

        verify(() => mockTokenService.deleteAll()).called(1);
        verify(() => mockAppDatabase.resetDatabase()).called(1);
      });

      test('propagates exception from deleteAll', () async {
        when(() => mockTokenService.deleteAll())
            .thenThrow(Exception('storage error'));

        expect(
          () => datasource.clearSession(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('restoreSession', () {
      test('returns LoginResponseEntity when valid session exists', () async {
        when(() => mockPatientInfo.load()).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenService.read()).thenAnswer((_) async => 'valid_jwt');
        when(() => mockTokenService.isTokenExpired('valid_jwt'))
            .thenAnswer((_) async => false);
        when(() => mockClinicalHistory.loadAll()).thenAnswer((_) async => []);

        final result = await datasource.restoreSession();

        expect(result, isNotNull);
        expect(result!.patient.id, '1');
        expect(result.token.key, 'valid_jwt');
        expect(result.clinicalHistory, isNull);
      });

      test('returns null when no patient stored', () async {
        when(() => mockPatientInfo.load()).thenAnswer((_) async => null);
        when(() => mockTokenService.read()).thenAnswer((_) async => 'irrelevant');

        final result = await datasource.restoreSession();

        expect(result, isNull);
      });

      test('returns null when no token stored', () async {
        when(() => mockPatientInfo.load()).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenService.read()).thenAnswer((_) async => null);

        final result = await datasource.restoreSession();

        expect(result, isNull);
      });

      test('clears storage and returns null when token expired and online', () async {
        when(() => mockPatientInfo.load()).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenService.read()).thenAnswer((_) async => 'expired');
        when(() => mockTokenService.isTokenExpired('expired'))
            .thenAnswer((_) async => true);
        when(() => mockInternetService.isConnected())
            .thenAnswer((_) async => true);
        when(() => mockTokenService.deleteAll()).thenAnswer((_) async => {});

        final result = await datasource.restoreSession();

        verify(() => mockTokenService.deleteAll()).called(1);
        expect(result, isNull);
      });

      test('returns session when token expired but offline', () async {
        when(() => mockPatientInfo.load()).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenService.read()).thenAnswer((_) async => 'expired');
        when(() => mockTokenService.isTokenExpired('expired'))
            .thenAnswer((_) async => true);
        when(() => mockInternetService.isConnected())
            .thenAnswer((_) async => false);
        when(() => mockClinicalHistory.loadAll()).thenAnswer((_) async => []);

        final result = await datasource.restoreSession();

        verifyNever(() => mockTokenService.deleteAll());
        verify(() => mockInternetService.isConnected()).called(1);
        expect(result, isNotNull);
        expect(result!.token.key, 'expired');
      });

      test('propagates exception from patientInfo load', () async {
        when(() => mockPatientInfo.load()).thenThrow(Exception('db error'));

        expect(
          () => datasource.restoreSession(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
