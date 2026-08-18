import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_state.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_card.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_chart_pane.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_non_numeric_list.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_period_filter.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_test_selector.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/l10n/error_localizer.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class LabResultsScreen extends ConsumerWidget {
  const LabResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labResultsProvider);

    ref.listen<LabResultsState>(labResultsProvider, (_, next) {
      if (next is LabResultsFailure) {
        _showErrorSnackBar(context, next.error);
      }
    });

    ref.listen<AppError?>(labResultsRefreshErrorProvider, (_, next) {
      if (next == null) return;
      _showErrorSnackBar(context, next);
    });

    if (state is LabResultsInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(labResultsProvider.notifier).load();
      });
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const SkeletonList(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: switch (state) {
        LabResultsLoading() => const SkeletonList(),
        LabResultsInitial() => const SkeletonList(),
        LabResultsLoaded(
          :final results,
          :final selectedTestId,
          :final period,
        ) =>
          _buildLoaded(context, ref, results, selectedTestId, period),
        LabResultsFailure(:final error) => _buildErrorState(
          context,
          ref,
          error,
        ),
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(localizeError(error, AppLocalizations.of(context)!)),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  AppBar _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(title: Text(l10n.labResults));
  }

  Widget _buildLoaded(
    BuildContext context,
    WidgetRef ref,
    List<LabResultEntity> results,
    String? selectedTestId,
    Period period,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (results.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    final numeric = results
        .where((result) => result.kind == LabResultKind.numeric)
        .toList();
    final nonNumeric = results
        .where((result) => result.kind == LabResultKind.text)
        .toList();
    LabResultEntity? selected;
    for (final test in numeric) {
      if (test.id == selectedTestId) {
        selected = test;
        break;
      }
    }

    return RefreshIndicator(
      semanticsLabel: l10n.labResultsRefresh,
      onRefresh: () => ref.read(labResultsProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (numeric.isNotEmpty) ...[
              const LabResultsTestSelector(),
              const LabResultsPeriodFilter(),
              if (selected != null)
                LabResultsChartPane(result: selected, period: period),
              for (final test in numeric) LabResultsCard(result: test),
            ],
            if (nonNumeric.isNotEmpty) ...[
              const SizedBox(height: 8),
              LabResultsNonNumericList(results: nonNumeric),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.biotech_outlined,
      title: l10n.labResultsEmpty,
      actionLabel: l10n.clinicalHistoryRetry,
      onActionPressed: () => ref.read(labResultsProvider.notifier).load(),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, AppError error) {
    final l10n = AppLocalizations.of(context)!;
    return ErrorState(
      message: localizeError(error, l10n),
      actionLabel: l10n.clinicalHistoryRetry,
      onActionPressed: () => ref.read(labResultsProvider.notifier).load(),
    );
  }
}
