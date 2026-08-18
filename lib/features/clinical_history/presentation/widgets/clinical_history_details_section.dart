import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import 'clinical_history_attachments_section.dart';
import 'clinical_history_diagnosis_section.dart';
import 'clinical_history_observations_section.dart';
import 'clinical_history_section_header.dart';

class ClinicalHistoryDetailsSection extends StatelessWidget {
  const ClinicalHistoryDetailsSection({super.key, required this.history});

  final ClinicalHistoryEntity history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        if (history.professional != null) ...[
          ClinicalHistorySectionHeader(
            icon: Icons.person_outline,
            label: l10n.clinicalHistoryDetailsProfessional,
          ),
          const SizedBox(height: 6),
          Text(
            history.professional!.fullname,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            history.professional!.specialty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (history.summary != null) ...[
          ClinicalHistorySectionHeader(
            icon: Icons.notes_outlined,
            label: l10n.clinicalHistoryDetailsSummary,
          ),
          const SizedBox(height: 6),
          Text(history.summary!),
          const SizedBox(height: 12),
        ],
        if (history.description != null) ...[
          ClinicalHistorySectionHeader(
            icon: Icons.description_outlined,
            label: l10n.clinicalHistoryDetailsDescription,
          ),
          const SizedBox(height: 6),
          Text(history.description!),
          const SizedBox(height: 12),
        ],
        if (history.diagnosis.isNotEmpty)
          ClinicalHistoryDiagnosisSection(
            diagnosis: history.diagnosis,
            headerLabel: l10n.clinicalHistoryDetailsDiagnosis,
          ),
        if (history.observations.isNotEmpty)
          ClinicalHistoryObservationsSection(
            observations: history.observations,
            headerLabel: l10n.clinicalHistoryDetailsObservations,
          ),
        if (history.attachments.isNotEmpty)
          ClinicalHistoryAttachmentsSection(
            attachments: history.attachments,
            headerLabel: l10n.clinicalHistoryDetailsAttachments,
          ),
      ],
    );
  }
}
