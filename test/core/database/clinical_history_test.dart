import 'package:clean_architecture_sdd_harness/core/database/_database.lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_attachment_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_diagnosis_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_professional_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';

void main() {
  late Database db;
  late ClinicalHistory store;

  const service = ClinicalHistoryServiceEntity(
    code: 'GEN',
    name: 'General Medicine',
    category: 'consultation',
  );
  const facility = ClinicalHistoryFacilityEntity(
    id: 'FAC-001',
    name: 'Central Medical Center',
    city: 'Quito',
  );
  const professional = ClinicalHistoryProfessionalEntity(
    id: 'DOC-1001',
    fullname: 'Dr. Sarah Johnson',
    specialty: 'Internal Medicine',
  );
  const diagnosis = [
    ClinicalHistoryDiagnosisEntity(
      code: 'Z00.00',
      name: 'General adult medical examination',
    ),
  ];
  const attachments = [
    ClinicalHistoryAttachmentEntity(
      id: 'FILE-001',
      type: 'pdf',
      name: 'medical-report.pdf',
      sizeBytes: 248530,
      url: 'https://example.com/report-001.pdf',
    ),
  ];
  const entity = ClinicalHistoryEntity(
    id: 'ch1',
    encounterNumber: 'ENC-001',
    service: service,
    facility: facility,
    professional: professional,
    encounterDate: '2026-01-15',
    createdAt: null,
    updatedAt: null,
    publishedAt: null,
    summary: 'Routine checkup',
    description: null,
    diagnosis: diagnosis,
    observations: [],
    attachments: attachments,
    state: null,
  );

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('memory');
    store = ClinicalHistory(database: Future.value(db));
    await store.deleteAll();
  });

  tearDown(() async => db.close());

  group('store', () {
    test('stores a single entity and can be retrieved', () async {
      await store.store(entity);

      final loaded = await store.load('ch1');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'ch1');
      expect(loaded.encounterNumber, 'ENC-001');
      expect(loaded.summary, 'Routine checkup');
    });

    test('replaces existing entity with same id (upsert)', () async {
      await store.store(entity);

      const updated = ClinicalHistoryEntity(
        id: 'ch1',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-01-20',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Follow-up visit',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );
      await store.store(updated);

      final loaded = await store.load('ch1');
      expect(loaded!.encounterNumber, 'ENC-002');
      expect(loaded.summary, 'Follow-up visit');

      final all = await store.loadAll();
      expect(all.length, 1);
    });
  });

  group('storeAll', () {
    test('stores multiple entities and replaces all previous data', () async {
      await store.storeAll([entity]);

      const entity2 = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-02-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Second visit',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );
      await store.storeAll([entity, entity2]);

      final all = await store.loadAll();
      expect(all.length, 2);
    });
  });

  group('load', () {
    test('returns null when entity does not exist', () async {
      final loaded = await store.load('nonexistent');
      expect(loaded, isNull);
    });

    test('returns entity when it exists', () async {
      await store.store(entity);

      final loaded = await store.load('ch1');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'ch1');
    });
  });

  group('loadAll', () {
    test('returns empty list when no entities stored', () async {
      final all = await store.loadAll();
      expect(all, isEmpty);
    });

    test('returns all stored entities', () async {
      const entity2 = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-02-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Second visit',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );

      await store.store(entity);
      await store.store(entity2);

      final all = await store.loadAll();
      expect(all.length, 2);
      expect(all.map((e) => e.id), containsAll(['ch1', 'ch2']));
    });
  });

  group('delete', () {
    test('deletes a specific entity by id', () async {
      await store.store(entity);
      expect(await store.load('ch1'), isNotNull);

      await store.delete('ch1');

      expect(await store.load('ch1'), isNull);
    });

    test('does not affect other entities', () async {
      const entity2 = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-02-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Second visit',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );

      await store.store(entity);
      await store.store(entity2);
      await store.delete('ch1');

      final all = await store.loadAll();
      expect(all.length, 1);
      expect(all.first.id, 'ch2');
    });
  });

  group('deleteAll', () {
    test('removes all stored entities', () async {
      const entity2 = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-02-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Second visit',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );

      await store.store(entity);
      await store.store(entity2);
      await store.deleteAll();

      final all = await store.loadAll();
      expect(all, isEmpty);
    });
  });

  group('update', () {
    test('updates fields of an existing entity', () async {
      await store.store(entity);

      const updated = ClinicalHistoryEntity(
        id: 'ch1',
        encounterNumber: 'ENC-001',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-01-15',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Updated summary',
        description: 'Added description after review',
        diagnosis: diagnosis,
        observations: ['Patient reported improvement'],
        attachments: attachments,
        state: null,
      );
      await store.update(updated);

      final loaded = await store.load('ch1');
      expect(loaded!.summary, 'Updated summary');
      expect(loaded.description, 'Added description after review');
      expect(loaded.observations, contains('Patient reported improvement'));
    });

    test('does nothing when entity does not exist (no error)', () async {
      const nonExistent = ClinicalHistoryEntity(
        id: 'ghost',
        encounterNumber: 'ENC-999',
        service: service,
        facility: facility,
        professional: professional,
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

      await store.update(nonExistent);

      final all = await store.loadAll();
      expect(all, isEmpty);
    });
  });

  group('updateAll', () {
    test('updates multiple entities', () async {
      const entity2 = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-02-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Second visit',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );

      await store.store(entity);
      await store.store(entity2);

      const updated1 = ClinicalHistoryEntity(
        id: 'ch1',
        encounterNumber: 'ENC-001',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-01-15',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Updated visit 1',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );
      const updated2 = ClinicalHistoryEntity(
        id: 'ch2',
        encounterNumber: 'ENC-002',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-02-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Updated visit 2',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );

      await store.updateAll([updated1, updated2]);

      final loaded1 = await store.load('ch1');
      final loaded2 = await store.load('ch2');
      expect(loaded1!.summary, 'Updated visit 1');
      expect(loaded2!.summary, 'Updated visit 2');
    });
  });
}
