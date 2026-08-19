import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/datasources/local_auth_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class _MockPatientInfoStore extends Mock implements IPatientInfoStore {}

class _MockClinicalHistoryStore extends Mock implements IClinicalHistoryStore {}

class _MockTokenStore extends Mock implements ITokenStore {}

class _MockCredentialStore extends Mock implements ICredentialStore {}

class _MockAppDatabase extends Mock implements IAppDatabase {}

final _patientEntity = PatientEntity(id: '1', name: 'John Doe');

final _loginResponse = LoginResponseEntity(
  patient: _patientEntity,
  token: TokenEntity(key: 'jwt_token_123'),
  clinicalHistory: [],
);

void main() {
  late _MockPatientInfoStore mockPatientInfo;
  late _MockClinicalHistoryStore mockClinicalHistory;
  late _MockTokenStore mockTokenStore;
  late _MockCredentialStore mockCredentialStore;
  late _MockAppDatabase mockAppDatabase;
  late LocalAuthDatasourceImpl datasource;

  setUp(() {
    registerFallbackValue(const PatientEntity(id: '', name: ''));
    registerFallbackValue(<ClinicalHistoryEntity>[]);
    mockPatientInfo = _MockPatientInfoStore();
    mockClinicalHistory = _MockClinicalHistoryStore();
    mockTokenStore = _MockTokenStore();
    mockCredentialStore = _MockCredentialStore();
    mockAppDatabase = _MockAppDatabase();
    datasource = LocalAuthDatasourceImpl(
      patientInfo: mockPatientInfo,
      clinicalHistoryReader: mockClinicalHistory,
      clinicalHistoryWriter: mockClinicalHistory,
      tokenStore: mockTokenStore,
      credentialStore: mockCredentialStore,
      appDatabase: mockAppDatabase,
    );

    when(() => mockPatientInfo.save(any())).thenAnswer((_) async {});
    when(() => mockClinicalHistory.storeAll(any())).thenAnswer((_) async {});
    when(() => mockTokenStore.save(any())).thenAnswer((_) async {});
    when(
      () => mockCredentialStore.saveCredentials(
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
        verify(() => mockTokenStore.save('jwt_token_123')).called(1);
        verify(
          () => mockCredentialStore.saveCredentials(
            email: 'test@example.com',
            passwordHash: 'hash',
          ),
        ).called(1);
      });

      test('stores clinical history list when present', () async {
        when(
          () => mockClinicalHistory.storeAll(any()),
        ).thenAnswer((_) async {});

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
        when(
          () => mockPatientInfo.save(any()),
        ).thenThrow(Exception('db error'));

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
      test('clears token, credentials and all session stores', () async {
        when(() => mockTokenStore.delete()).thenAnswer((_) async {});
        when(
          () => mockCredentialStore.deleteCredentials(),
        ).thenAnswer((_) async {});
        when(() => mockPatientInfo.delete()).thenAnswer((_) async {});
        when(() => mockClinicalHistory.deleteAll()).thenAnswer((_) async {});

        await datasource.clearSession();

        verify(() => mockTokenStore.delete()).called(1);
        verify(() => mockCredentialStore.deleteCredentials()).called(1);
        verify(() => mockPatientInfo.delete()).called(1);
        verify(() => mockClinicalHistory.deleteAll()).called(1);
      });

      test('propagates exception from delete', () async {
        when(
          () => mockTokenStore.delete(),
        ).thenThrow(Exception('storage error'));

        expect(() => datasource.clearSession(), throwsA(isA<Exception>()));
      });
    });

    group('resetAccount', () {
      test('clears session and wipes the database', () async {
        when(() => mockTokenStore.delete()).thenAnswer((_) async {});
        when(
          () => mockCredentialStore.deleteCredentials(),
        ).thenAnswer((_) async {});
        when(() => mockPatientInfo.delete()).thenAnswer((_) async {});
        when(() => mockClinicalHistory.deleteAll()).thenAnswer((_) async {});
        when(() => mockAppDatabase.resetDatabase()).thenAnswer((_) async {});

        await datasource.resetAccount();

        verify(() => mockTokenStore.delete()).called(1);
        verify(() => mockCredentialStore.deleteCredentials()).called(1);
        verify(() => mockPatientInfo.delete()).called(1);
        verify(() => mockClinicalHistory.deleteAll()).called(1);
        verify(() => mockAppDatabase.resetDatabase()).called(1);
      });

      test('propagates exception from database wipe', () async {
        when(() => mockTokenStore.delete()).thenAnswer((_) async {});
        when(
          () => mockCredentialStore.deleteCredentials(),
        ).thenAnswer((_) async {});
        when(() => mockPatientInfo.delete()).thenAnswer((_) async {});
        when(() => mockClinicalHistory.deleteAll()).thenAnswer((_) async {});
        when(
          () => mockAppDatabase.resetDatabase(),
        ).thenThrow(Exception('db error'));

        expect(() => datasource.resetAccount(), throwsA(isA<Exception>()));
      });
    });

    group('restoreSession', () {
      test('returns LoginResponseEntity when valid session exists', () async {
        when(
          () => mockPatientInfo.load(),
        ).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenStore.read()).thenAnswer((_) async => 'valid_jwt');
        when(() => mockClinicalHistory.loadAll()).thenAnswer((_) async => []);

        final result = await datasource.restoreSession();

        expect(result, isNotNull);
        expect(result!.patient.id, '1');
        expect(result.token.key, 'valid_jwt');
        expect(result.clinicalHistory, isEmpty);
      });

      test('restores the persisted clinical history', () async {
        const ch = ClinicalHistoryEntity(
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
        );
        when(
          () => mockPatientInfo.load(),
        ).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenStore.read()).thenAnswer((_) async => 'valid_jwt');
        when(() => mockClinicalHistory.loadAll()).thenAnswer((_) async => [ch]);

        final result = await datasource.restoreSession();

        expect(result, isNotNull);
        expect(result!.clinicalHistory, [ch]);
      });

      test('returns null when no patient stored', () async {
        when(() => mockPatientInfo.load()).thenAnswer((_) async => null);
        when(() => mockTokenStore.read()).thenAnswer((_) async => 'irrelevant');

        final result = await datasource.restoreSession();

        expect(result, isNull);
      });

      test('returns null when no token stored', () async {
        when(
          () => mockPatientInfo.load(),
        ).thenAnswer((_) async => _patientEntity);
        when(() => mockTokenStore.read()).thenAnswer((_) async => null);

        final result = await datasource.restoreSession();

        expect(result, isNull);
      });

      test(
        'returns session even when token is expired (no policy in datasource)',
        () async {
          when(
            () => mockPatientInfo.load(),
          ).thenAnswer((_) async => _patientEntity);
          when(() => mockTokenStore.read()).thenAnswer((_) async => 'expired');
          when(() => mockClinicalHistory.loadAll()).thenAnswer((_) async => []);

          final result = await datasource.restoreSession();

          expect(result, isNotNull);
          expect(result!.token.key, 'expired');
        },
      );

      test('propagates exception from patientInfo load', () async {
        when(() => mockPatientInfo.load()).thenThrow(Exception('db error'));

        expect(() => datasource.restoreSession(), throwsA(isA<Exception>()));
      });
    });
  });
}
