import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/datasources/i_clinical_history_local_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/datasources/i_clinical_history_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/infrastructure/repositories/clinical_history_repository_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import '../../../helpers/mocks.dart';

class _MockRemoteDatasource extends Mock
    implements IClinicalHistoryRemoteDatasource {}

class _MockLocalDatasource extends Mock
    implements IClinicalHistoryLocalDatasource {}

const _tEntity = ClinicalHistoryEntity(
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
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);
const _tList = [_tEntity];

const _tCachedEntity = ClinicalHistoryEntity(
  id: 'ch2',
  encounterNumber: 'ENC-002',
  service: ClinicalHistoryServiceEntity(
    code: 'PED',
    name: 'Pediatrics',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-002',
    name: 'North Side Clinic',
    city: 'Guayaquil',
  ),
  professional: null,
  encounterDate: '2026-02-01',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'closed', label: 'Closed'),
);
const _tCachedList = [_tCachedEntity];

void main() {
  late _MockRemoteDatasource mockRemote;
  late _MockLocalDatasource mockLocal;
  late FakeLogger fakeLogger;
  late ClinicalHistoryRepositoryImpl repository;

  setUp(() {
    registerFallbackValue(<ClinicalHistoryEntity>[]);
    mockRemote = _MockRemoteDatasource();
    mockLocal = _MockLocalDatasource();
    fakeLogger = FakeLogger();
    repository = ClinicalHistoryRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
      logger: fakeLogger,
    );
  });

  group('loadClinicalHistories', () {
    test(
      'remote_success_returns_Success_writes_through_and_logs_origin_remote',
      () async {
        when(() => mockRemote.loadRemote()).thenAnswer((_) async => _tList);
        when(() => mockLocal.storeLocal(any())).thenAnswer((_) async {});

        final result = await repository.loadClinicalHistories();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tList),
          onFailure: (_) => fail('should be Success'),
        );
        verify(() => mockLocal.storeLocal(_tList)).called(1);
        expect(
          fakeLogger.infoMessages,
          contains('[clinical_history] load origin=remote'),
        );
      },
    );

    test(
      'remote_success_with_cache_write_failure_logs_and_returns_Success',
      () async {
        when(() => mockRemote.loadRemote()).thenAnswer((_) async => _tList);
        when(
          () => mockLocal.storeLocal(any()),
        ).thenThrow(Exception('db error'));

        final result = await repository.loadClinicalHistories();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tList),
          onFailure: (_) => fail('should be Success'),
        );
        verify(() => mockLocal.storeLocal(_tList)).called(1);
        expect(
          fakeLogger.errorMessages,
          contains('[clinical_history] cache write failed (load)'),
        );
      },
    );

    test(
      'network_failure_falls_back_to_cache_does_not_write_through_and_logs_origin_cache',
      () async {
        when(
          () => mockRemote.loadRemote(),
        ).thenThrow(const NoConnectionException());
        when(() => mockLocal.loadLocal()).thenAnswer((_) async => _tCachedList);

        final result = await repository.loadClinicalHistories();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tCachedList),
          onFailure: (_) => fail('should be Success'),
        );
        verifyNever(() => mockLocal.storeLocal(any()));
        expect(
          fakeLogger.infoMessages,
          contains('[clinical_history] load origin=cache'),
        );
      },
    );

    test('network_failure_with_empty_cache_returns_Failure', () async {
      when(
        () => mockRemote.loadRemote(),
      ).thenThrow(const NoConnectionException());
      when(
        () => mockLocal.loadLocal(),
      ).thenAnswer((_) async => const <ClinicalHistoryEntity>[]);

      final result = await repository.loadClinicalHistories();

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<NetworkError>()),
      );
    });

    test(
      'local_read_failure_surfaces_failure_with_stack_trace_and_origin_cache',
      () async {
        when(
          () => mockRemote.loadRemote(),
        ).thenThrow(const NoConnectionException());
        when(() => mockLocal.loadLocal()).thenThrow(Exception('db corrupt'));

        final result = await repository.loadClinicalHistories();

        expect(result.isSuccess, isFalse);
        result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) {
            expect(error, isA<UnexpectedError>());
            expect(
              error.stackTrace,
              isNotNull,
              reason: 'la falla local debe preservar su stack trace',
            );
          },
        );
        expect(
          fakeLogger.infoMessages,
          contains('[clinical_history] load origin=cache'),
        );
      },
    );

    test('api_error_does_not_fall_back_to_cache', () async {
      when(() => mockRemote.loadRemote()).thenThrow(const ApiException(401));
      when(() => mockLocal.loadLocal()).thenAnswer((_) async => _tCachedList);

      final result = await repository.loadClinicalHistories();

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
      verifyNever(() => mockLocal.loadLocal());
      verifyNever(() => mockLocal.storeLocal(any()));
    });
  });

  group('refreshClinicalHistories', () {
    test('remote_success_returns_Success_and_writes_through', () async {
      when(() => mockRemote.loadRemote()).thenAnswer((_) async => _tList);
      when(() => mockLocal.storeLocal(any())).thenAnswer((_) async {});

      final result = await repository.refreshClinicalHistories();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, _tList),
        onFailure: (_) => fail('should be Success'),
      );
      verify(() => mockLocal.storeLocal(_tList)).called(1);
    });

    test(
      'remote_failure_returns_Failure_and_does_not_fall_back_to_cache',
      () async {
        when(
          () => mockRemote.loadRemote(),
        ).thenThrow(const NoConnectionException());
        when(() => mockLocal.loadLocal()).thenAnswer((_) async => _tCachedList);

        final result = await repository.refreshClinicalHistories();

        expect(result.isSuccess, isFalse);
        result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<NetworkError>()),
        );
        verifyNever(() => mockLocal.loadLocal());
        verifyNever(() => mockLocal.storeLocal(any()));
      },
    );

    test('refresh_with_cache_write_failure_logs_and_returns_Success', () async {
      when(() => mockRemote.loadRemote()).thenAnswer((_) async => _tList);
      when(() => mockLocal.storeLocal(any())).thenThrow(Exception('db error'));

      final result = await repository.refreshClinicalHistories();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, _tList),
        onFailure: (_) => fail('should be Success'),
      );
      verify(() => mockLocal.storeLocal(_tList)).called(1);
      expect(
        fakeLogger.errorMessages,
        contains('[clinical_history] cache write failed (refresh)'),
      );
    });
  });
}
