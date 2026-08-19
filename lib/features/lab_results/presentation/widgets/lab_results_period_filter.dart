import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_period_provider.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

class LabResultsPeriodFilter extends ConsumerWidget {
  const LabResultsPeriodFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(labResultsPeriodProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.labResultsPeriodLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final period in Period.values)
                ChoiceChip(
                  label: Text(_periodLabel(l10n, period)),
                  selected: selected == period,
                  onSelected: (_) {
                    ref.read(labResultsPeriodProvider.notifier).set(period);
                    ref.read(labResultsProvider.notifier).setPeriod(period);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _periodLabel(AppLocalizations l10n, Period period) {
    switch (period) {
      case Period.threeMonths:
        return l10n.labResultsPeriod3Months;
      case Period.sixMonths:
        return l10n.labResultsPeriod6Months;
      case Period.oneYear:
        return l10n.labResultsPeriod1Year;
      case Period.all:
        return l10n.labResultsPeriodAll;
    }
  }
}
