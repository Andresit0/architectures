import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import 'clinical_history_section_header.dart';

class ClinicalHistoryDiagnosisSection extends StatelessWidget {
  const ClinicalHistoryDiagnosisSection({
    super.key,
    required this.diagnosis,
    required this.headerLabel,
  });

  final List<ClinicalHistoryDiagnosisEntity> diagnosis;
  final String headerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicalHistorySectionHeader(
          icon: Icons.health_and_safety_outlined,
          label: headerLabel,
        ),
        const SizedBox(height: 6),
        for (final diagnosis in diagnosis)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diagnosis.code,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(diagnosis.name)),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
