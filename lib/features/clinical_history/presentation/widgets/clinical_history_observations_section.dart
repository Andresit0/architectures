import 'package:flutter/material.dart';

import 'clinical_history_section_header.dart';

class ClinicalHistoryObservationsSection extends StatelessWidget {
  const ClinicalHistoryObservationsSection({
    super.key,
    required this.observations,
    required this.headerLabel,
  });

  final List<String> observations;
  final String headerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicalHistorySectionHeader(
          icon: Icons.format_list_bulleted_outlined,
          label: headerLabel,
        ),
        const SizedBox(height: 6),
        for (final observation in observations)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(observation)),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
