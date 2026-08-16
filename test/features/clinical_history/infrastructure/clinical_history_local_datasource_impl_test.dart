import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/infrastructure/datasources/clinical_history_local_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _MockStore extends Mock implements IClinicalHistoryStore {}

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

void main() {
  late _MockStore mockStore;
  late ClinicalHistoryLocalDatasourceImpl datasource;

  setUp(() {
    mockStore = _MockStore();
    datasource = ClinicalHistoryLocalDatasourceImpl(store: mockStore);
  });

  group('ClinicalHistoryLocalDatasourceImpl', () {
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
