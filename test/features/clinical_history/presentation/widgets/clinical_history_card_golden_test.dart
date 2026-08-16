@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/widgets/clinical_history_card.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

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

Widget _buildCard() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: AppTheme.material3.colorScheme,
      fontFamily: 'Roboto',
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: ClinicalHistoryCard(clinicalHistory: _tEntity),
        ),
      ),
    ),
  );
}

void main() {
  testGoldens('ClinicalHistoryCard golden test — collapsed', (tester) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();

    await expectLater(
      find.byType(ClinicalHistoryCard),
      matchesGoldenFile('goldens/clinical_history_card_collapsed.png'),
    );
  });

  testGoldens('ClinicalHistoryCard golden test — expanded', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildCard());
    await tester.pump();

    await tester.tap(find.byType(ClinicalHistoryCard));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ClinicalHistoryCard),
      matchesGoldenFile('goldens/clinical_history_card_expanded.png'),
    );
  });
}
