import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/design_system/utils/app_formatters.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import 'clinical_history_section_header.dart';

class ClinicalHistoryAttachmentsSection extends StatelessWidget {
  const ClinicalHistoryAttachmentsSection({
    super.key,
    required this.attachments,
    required this.headerLabel,
  });

  final List<ClinicalHistoryAttachmentEntity> attachments;
  final String headerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicalHistorySectionHeader(
          icon: Icons.attach_file_outlined,
          label: headerLabel,
        ),
        const SizedBox(height: 6),
        for (final attachment in attachments)
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
                      Text(attachment.name, style: theme.textTheme.bodyMedium),
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
    );
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
