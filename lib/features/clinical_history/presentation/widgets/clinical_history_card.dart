import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

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
                      ? _buildDetails(context, history)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ClinicalHistoryEntity history) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        if (history.professional != null) ...[
          _SectionHeader(
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
          _SectionHeader(
            icon: Icons.notes_outlined,
            label: l10n.clinicalHistoryDetailsSummary,
          ),
          const SizedBox(height: 6),
          Text(history.summary!),
          const SizedBox(height: 12),
        ],
        if (history.description != null) ...[
          _SectionHeader(
            icon: Icons.description_outlined,
            label: l10n.clinicalHistoryDetailsDescription,
          ),
          const SizedBox(height: 6),
          Text(history.description!),
          const SizedBox(height: 12),
        ],
        if (history.diagnosis.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.health_and_safety_outlined,
            label: l10n.clinicalHistoryDetailsDiagnosis,
          ),
          const SizedBox(height: 6),
          for (final diagnosis in history.diagnosis)
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
        if (history.observations.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.format_list_bulleted_outlined,
            label: l10n.clinicalHistoryDetailsObservations,
          ),
          const SizedBox(height: 6),
          for (final observation in history.observations)
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
        if (history.attachments.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.attach_file_outlined,
            label: l10n.clinicalHistoryDetailsAttachments,
          ),
          const SizedBox(height: 6),
          for (final attachment in history.attachments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _attachmentIcon(attachment.type),
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatBytes(attachment.sizeBytes),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    attachment.type,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

IconData _attachmentIcon(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    case 'image':
    case 'png':
    case 'jpg':
    case 'jpeg':
      return Icons.image_outlined;
    default:
      return Icons.attach_file_outlined;
  }
}
