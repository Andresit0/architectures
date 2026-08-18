import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_state.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class LabResultsTestSelector extends ConsumerWidget {
  const LabResultsTestSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labResultsProvider);
    if (state is! LabResultsLoaded) return const SizedBox.shrink();

    final numeric = state.results
        .where((result) => result.kind == LabResultKind.numeric)
        .toList();
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      label: l10n.labResultsSelectTest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            for (final test in numeric) ...[
              ChoiceChip(
                label: Text(test.testName),
                selected: state.selectedTestId == test.id,
                onSelected: (_) =>
                    ref.read(labResultsProvider.notifier).selectTest(test.id),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
