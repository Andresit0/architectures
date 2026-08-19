import 'package:clean_architecture_sdd_harness/core/database/sembast_db_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/clinical_history.dart';
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

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('memory');
    store = ClinicalHistory(database: Future.value(SembastDbWrapper(db)));
    await store.deleteAll();
  });

  tearDown(() async => db.close());

  group('storeAll', () {
    test('stores multiple entities and replaces all previous data', () async {
      await store.storeAll([entity]);

      await store.storeAll([entity, entity2]);

      final all = await store.loadAll();
      expect(all.length, 2);
    });
  });

  group('storeAll idempotence by id', () {
    test('duplicate ids do not create duplicate records', () async {
      const updated1 = ClinicalHistoryEntity(
        id: 'ch1',
        encounterNumber: 'ENC-003',
        service: service,
        facility: facility,
        professional: professional,
        encounterDate: '2026-03-01',
        createdAt: null,
        updatedAt: null,
        publishedAt: null,
        summary: 'Repeated upsert',
        description: null,
        diagnosis: diagnosis,
        observations: [],
        attachments: attachments,
        state: null,
      );

      await store.storeAll([entity, updated1, entity2]);

      final all = await store.loadAll();
      expect(all.length, 2);
      final ch1 = all.singleWhere((e) => e.id == 'ch1');
      expect(ch1.encounterNumber, 'ENC-003');
    });
  });

  group('loadAll', () {
    test('returns empty list when no entities stored', () async {
      final all = await store.loadAll();
      expect(all, isEmpty);
    });

    test('returns all stored entities', () async {
      await store.storeAll([entity, entity2]);

      final all = await store.loadAll();
      expect(all.length, 2);
      expect(all.map((e) => e.id), containsAll(['ch1', 'ch2']));
    });
  });

  group('deleteAll', () {
    test('removes all stored entities', () async {
      await store.storeAll([entity, entity2]);

      await store.deleteAll();

      final all = await store.loadAll();
      expect(all, isEmpty);
    });
  });
}
