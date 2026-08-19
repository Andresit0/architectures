import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import 'clinical_history_details_section.dart';

class ClinicalHistoryCard extends StatefulWidget {
  const ClinicalHistoryCard({super.key, required this.clinicalHistory});

  final ClinicalHistoryEntity clinicalHistory;

  @override
  State<ClinicalHistoryCard> createState() => _ClinicalHistoryCardState();
}

class _ClinicalHistoryCardState extends State<ClinicalHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final history = widget.clinicalHistory;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Semantics(
      button: true,
      expanded: _expanded,
      label: history.service.name,
      hint: _expanded
          ? l10n.clinicalHistoryDetailsCollapse
          : l10n.clinicalHistoryDetailsExpand,
      child: Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        _serviceIcon(history.service.category),
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.service.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            history.facility.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            history.facility.city,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (history.state != null)
                          InfoChip(
                            label: history.state!.label,
                            color: _stateColor(history.state!.status),
                          )
                        else
                          const SizedBox(height: 22),
                        const SizedBox(height: 8),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            size: 22,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatClinicalDate(history.encounterDate, locale: locale),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? ClinicalHistoryDetailsSection(history: history)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color? _stateColor(ClinicalHistoryStatus status) {
  switch (status) {
    case ClinicalHistoryStatus.ready:
      return AppColors.success;
    case ClinicalHistoryStatus.pending:
      return AppColors.warning;
    case ClinicalHistoryStatus.closed:
      return AppColors.gray;
    case ClinicalHistoryStatus.unknown:
      return null;
  }
}

IconData _serviceIcon(String category) {
  switch (category) {
    case 'consultation':
      return Icons.medical_services_outlined;
    case 'emergency':
      return Icons.local_hospital_outlined;
    case 'study':
      return Icons.science_outlined;
    default:
      return Icons.medical_information_outlined;
  }
}
