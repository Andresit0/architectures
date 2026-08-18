import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/design_system/utils/app_formatters.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/mappers/lab_result_chart_mapper.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/utils/lab_value_formatter.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class LabResultsChartPane extends ConsumerWidget {
  const LabResultsChartPane({
    super.key,
    required this.result,
    required this.period,
  });

  final LabResultEntity result;
  final Period period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final filtered = filterByPeriod(result.values, period);
    final data = const LabResultChartMapper().toTrendChartData(
      result: result,
      values: filtered,
      formatDate: (date) => formatChartDate(date, locale: locale),
      statusLabel: (status) => labStatusLabel(l10n, status),
      referenceRangeLabel: l10n.labResultsReferenceRange,
    );
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.labResultsChartTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 200,
              child: ref.watch(trendChartProvider).lineChart(data: data),
            ),
          ),
        ],
      ),
    );
  }
}
