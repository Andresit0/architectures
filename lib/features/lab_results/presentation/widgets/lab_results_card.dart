import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/utils/lab_value_formatter.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class LabResultsCard extends StatelessWidget {
  const LabResultsCard({super.key, required this.result});

  final LabResultEntity result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isNumeric = result.kind == LabResultKind.numeric;
    final latest = result.latestValue;

    return Card.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                isNumeric ? Icons.monitor_heart_outlined : Icons.notes_outlined,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.testName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isNumeric)
              _buildNumericValue(context, latest, l10n)
            else
              Flexible(
                child: Text(
                  latest?.textValue ?? '',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericValue(
    BuildContext context,
    LabResultValueEntity? latest,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unit = result.unit ?? '';

    final valueRow = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatLabValue(latest?.value),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (latest != null)
          Semantics(
            label:
                '${l10n.labResultsLatestValue}: ${formatLabValue(latest.value, unit)}',
            excludeSemantics: true,
            child: valueRow,
          )
        else
          valueRow,
        const SizedBox(height: 6),
        InfoChip(
          label: labStatusLabel(l10n, result.status),
          color: _statusColor(result.status),
        ),
      ],
    );
  }

  Color? _statusColor(LabResultStatus status) {
    switch (status) {
      case LabResultStatus.normal:
        return AppColors.success;
      case LabResultStatus.high:
        return AppColors.red;
      case LabResultStatus.low:
        return AppColors.warning;
      case LabResultStatus.unknown:
        return AppColors.gray;
    }
  }
}
