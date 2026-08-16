@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_state.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/screens/clinical_history_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _FakeClinicalHistoryNotifier extends ClinicalHistoryNotifier {
  _FakeClinicalHistoryNotifier(this._initial) : super();

  final ClinicalHistoryState _initial;

  @override
  ClinicalHistoryState build() => _initial;

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}
}

const _tEntity1 = ClinicalHistoryEntity(
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
  professional: ClinicalHistoryProfessionalEntity(
    id: 'DOC-1001',
    fullname: 'Dr. Sarah Johnson',
    specialty: 'Internal Medicine',
  ),
  encounterDate: '2026-01-15',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: 'Routine checkup',
  description: 'Full description',
  diagnosis: [
    ClinicalHistoryDiagnosisEntity(
      code: 'Z00.00',
      name: 'General adult medical examination',
    ),
  ],
  observations: ['Obs 1', 'Obs 2'],
  attachments: [
    ClinicalHistoryAttachmentEntity(
      id: 'FILE-001',
      type: 'pdf',
      name: 'medical-report.pdf',
      sizeBytes: 248530,
      url: 'https://example.com/report-001.pdf',
    ),
  ],
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);

const _tEntity2 = ClinicalHistoryEntity(
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

const _tLoadedList = [_tEntity1, _tEntity2];

Widget _buildScreen(ClinicalHistoryState state) {
  return ProviderScope(
    overrides: [
      clinicalHistoryProvider.overrideWith(
        () => _FakeClinicalHistoryNotifier(state),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: AppTheme.material3.colorScheme,
        fontFamily: 'Roboto',
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ClinicalHistoryScreen(),
    ),
  );
}

void main() {
  testGoldens('ClinicalHistoryScreen golden test — loading state', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(const ClinicalHistoryLoading()));
    await tester.pump();

    await expectLater(
      find.byType(ClinicalHistoryScreen),
      matchesGoldenFile('goldens/clinical_history_screen_loading.png'),
    );
  });

  testGoldens('ClinicalHistoryScreen golden test — loaded state', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(ClinicalHistoryLoaded(_tLoadedList)));
    await tester.pump();

    await expectLater(
      find.byType(ClinicalHistoryScreen),
      matchesGoldenFile('goldens/clinical_history_screen_loaded.png'),
    );
  });

  testGoldens('ClinicalHistoryScreen golden test — empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(const ClinicalHistoryLoaded(<ClinicalHistoryEntity>[])),
    );
    await tester.pump();

    await expectLater(
      find.byType(ClinicalHistoryScreen),
      matchesGoldenFile('goldens/clinical_history_screen_empty.png'),
    );
  });
}
