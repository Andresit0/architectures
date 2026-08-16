import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
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

Widget _buildCard() => MaterialApp(
  theme: AppTheme.material3,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: ClinicalHistoryCard(clinicalHistory: _tEntity)),
);

void main() {
  testWidgets('shows collapsed summary info (service, facility, date, state)', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();

    expect(find.text('General Medicine'), findsOneWidget);
    expect(find.text('Central Medical Center'), findsOneWidget);
    expect(find.text('Quito'), findsOneWidget);
    expect(find.text('Jan 15, 2026'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.byType(InfoChip), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('renders the state chip with the typed-status color', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();

    final chip = tester.widget<InfoChip>(find.byType(InfoChip));
    expect(chip.color, AppColors.success);
  });

  testWidgets('tapping the card expands details and tapping again collapses', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCard());
    await tester.pump();

    expect(find.text('Dr. Sarah Johnson'), findsNothing);
    expect(find.text('Routine checkup'), findsNothing);
    expect(find.text('medical-report.pdf'), findsNothing);

    await tester.tap(find.byType(ClinicalHistoryCard));
    await tester.pump();

    expect(find.text('Professional'), findsOneWidget);
    expect(find.text('Dr. Sarah Johnson'), findsOneWidget);
    expect(find.text('Internal Medicine'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Routine checkup'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Full description'), findsOneWidget);
    expect(find.text('Diagnosis'), findsOneWidget);
    expect(find.text('Z00.00'), findsOneWidget);
    expect(find.text('General adult medical examination'), findsOneWidget);
    expect(find.text('Observations'), findsOneWidget);
    expect(find.text('Obs 1'), findsOneWidget);
    expect(find.text('Obs 2'), findsOneWidget);
    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('medical-report.pdf'), findsOneWidget);
    expect(find.text('pdf'), findsOneWidget);

    await tester.tap(find.byType(ClinicalHistoryCard), warnIfMissed: false);
    await tester.pump();

    expect(find.text('Dr. Sarah Johnson'), findsNothing);
    expect(find.text('Routine checkup'), findsNothing);
  });
}
