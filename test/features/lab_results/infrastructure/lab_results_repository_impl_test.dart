import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/datasources/i_lab_results_local_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/datasources/i_lab_results_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/repositories/lab_results_repository_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import '../../../helpers/mocks.dart';

class _MockRemoteDatasource extends Mock
    implements ILabResultsRemoteDatasource {}

class _MockLocalDatasource extends Mock implements ILabResultsLocalDatasource {}

final _tNumericEntity = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 16.8,
      textValue: null,
    ),
    LabResultValueEntity(
      date: DateTime(2026, 6, 14),
      value: 15.4,
      textValue: null,
    ),
  ],
);

final _tList = [_tNumericEntity];

final _tTextEntity = LabResultEntity(
  id: 'lr_0005',
  testCode: 'GRUPO',
  testName: 'Grupo sanguíneo',
  category: 'Inmunohematología',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: null,
      textValue: 'A Positivo (A+)',
    ),
  ],
);

final _tCachedList = [_tTextEntity];

void main() {
  late _MockRemoteDatasource mockRemote;
  late _MockLocalDatasource mockLocal;
  late FakeLogger fakeLogger;
  late LabResultsRepositoryImpl repository;

  setUp(() {
    registerFallbackValue(<LabResultEntity>[]);
    mockRemote = _MockRemoteDatasource();
    mockLocal = _MockLocalDatasource();
    fakeLogger = FakeLogger();
    repository = LabResultsRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
      logger: fakeLogger,
    );
  });

  group('loadLabResults', () {
    test(
      'remote_success_returns_Success_writes_through_and_logs_origin_remote',
      () async {
        when(() => mockRemote.loadRemote()).thenAnswer((_) async => _tList);
        when(() => mockLocal.storeLocal(any())).thenAnswer((_) async {});

        final result = await repository.loadLabResults();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tList),
          onFailure: (_) => fail('should be Success'),
        );
        verify(() => mockLocal.storeLocal(_tList)).called(1);
        expect(
          fakeLogger.infoMessages,
          contains('[lab_results] load origin=remote'),
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

        final result = await repository.loadLabResults();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tList),
          onFailure: (_) => fail('should be Success'),
        );
        verify(() => mockLocal.storeLocal(_tList)).called(1);
        expect(
          fakeLogger.errorMessages,
          contains('[lab_results] cache write failed (load)'),
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

        final result = await repository.loadLabResults();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, _tCachedList),
          onFailure: (_) => fail('should be Success'),
        );
        verifyNever(() => mockLocal.storeLocal(any()));
        expect(
          fakeLogger.infoMessages,
          contains('[lab_results] load origin=cache'),
        );
      },
    );

    test('network_failure_with_empty_cache_returns_Failure', () async {
      when(
        () => mockRemote.loadRemote(),
      ).thenThrow(const NoConnectionException());
      when(
        () => mockLocal.loadLocal(),
      ).thenAnswer((_) async => const <LabResultEntity>[]);

      final result = await repository.loadLabResults();

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

        final result = await repository.loadLabResults();

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
          contains('[lab_results] load origin=cache'),
        );
      },
    );

    test('api_error_does_not_fall_back_to_cache', () async {
      when(() => mockRemote.loadRemote()).thenThrow(const ApiException(401));
      when(() => mockLocal.loadLocal()).thenAnswer((_) async => _tCachedList);

      final result = await repository.loadLabResults();

      expect(result.isSuccess, isFalse);
      result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
      verifyNever(() => mockLocal.loadLocal());
      verifyNever(() => mockLocal.storeLocal(any()));
    });
  });

  group('refreshLabResults', () {
    test('remote_success_returns_Success_and_writes_through', () async {
      when(() => mockRemote.loadRemote()).thenAnswer((_) async => _tList);
      when(() => mockLocal.storeLocal(any())).thenAnswer((_) async {});

      final result = await repository.refreshLabResults();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, _tList),
        onFailure: (_) => fail('should be Success'),
      );
      verify(() => mockLocal.storeLocal(_tList)).called(1);
      expect(
        fakeLogger.infoMessages,
        contains('[lab_results] refresh origin=remote'),
      );
    });

    test(
      'remote_failure_returns_Failure_and_does_not_fall_back_to_cache',
      () async {
        when(
          () => mockRemote.loadRemote(),
        ).thenThrow(const NoConnectionException());
        when(() => mockLocal.loadLocal()).thenAnswer((_) async => _tCachedList);

        final result = await repository.refreshLabResults();

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

      final result = await repository.refreshLabResults();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, _tList),
        onFailure: (_) => fail('should be Success'),
      );
      verify(() => mockLocal.storeLocal(_tList)).called(1);
      expect(
        fakeLogger.errorMessages,
        contains('[lab_results] cache write failed (refresh)'),
      );
    });
  });
}
