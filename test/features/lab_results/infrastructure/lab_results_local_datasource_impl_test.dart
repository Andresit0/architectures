import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/datasources/lab_results_local_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _MockStore extends Mock implements ILabResultsStore {}

final _tEntity = LabResultEntity(
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
  ],
);

final _tList = [_tEntity];

void main() {
  late _MockStore mockStore;
  late LabResultsLocalDatasourceImpl datasource;

  setUp(() {
    registerFallbackValue(<LabResultEntity>[]);
    mockStore = _MockStore();
    datasource = LabResultsLocalDatasourceImpl(store: mockStore);
  });

  group('LabResultsLocalDatasourceImpl', () {
    test('loadLocal_returns_cached_entities_from_store', () async {
      when(() => mockStore.loadAll()).thenAnswer((_) async => _tList);

      final result = await datasource.loadLocal();

      expect(result, _tList);
      verify(() => mockStore.loadAll()).called(1);
    });

    test('storeLocal_delegates_to_store', () async {
      when(() => mockStore.storeAll(any())).thenAnswer((_) async {});

      await datasource.storeLocal(_tList);

      verify(() => mockStore.storeAll(_tList)).called(1);
    });
  });
}
