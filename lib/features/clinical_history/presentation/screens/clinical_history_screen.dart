import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_state.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/l10n/error_localizer.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

import '../widgets/clinical_history_card.dart';

class ClinicalHistoryScreen extends ConsumerWidget {
  const ClinicalHistoryScreen({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clinicalHistoryProvider);

    ref.listen<ClinicalHistoryState>(clinicalHistoryProvider, (_, next) {
      if (next is ClinicalHistoryFailure) {
        _showErrorSnackBar(context, next.error);
      }
    });

    ref.listen<AppError?>(clinicalHistoryRefreshErrorProvider, (_, next) {
      if (next == null) return;
      _showErrorSnackBar(context, next);
    });

    if (state is ClinicalHistoryInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(clinicalHistoryProvider.notifier).load();
      });
      return Scaffold(
        appBar: _buildAppBar(context, ref),
        body: const SkeletonList(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: switch (state) {
        ClinicalHistoryLoading() => const SkeletonList(),
        ClinicalHistoryInitial() => const SkeletonList(),
        ClinicalHistoryLoaded(:final clinicalHistory) =>
          clinicalHistory.isEmpty
              ? _buildEmptyState(context, ref)
              : Column(
                  children: [
                    _buildHeader(context, clinicalHistory.length),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref
                            .read(clinicalHistoryProvider.notifier)
                            .refresh(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: clinicalHistory.length,
                          itemBuilder: (context, index) => ClinicalHistoryCard(
                            clinicalHistory: clinicalHistory[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ClinicalHistoryFailure(:final error) => _buildErrorState(
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

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.clinicalHistory),
      actions: [
        IconButton(
          tooltip: l10n.clinicalHistoryLabResults,
          icon: const Icon(Icons.biotech_outlined),
          onPressed: () =>
              ref.read(appNavigatorProvider).go(AppRoute.labResults),
        ),
        if (onLogout != null)
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.history, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            l10n.clinicalHistoryCount(count),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.event_note_outlined,
      title: l10n.clinicalHistoryEmpty,
      actionLabel: l10n.clinicalHistoryRetry,
      onActionPressed: () => ref.read(clinicalHistoryProvider.notifier).load(),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, AppError error) {
    final l10n = AppLocalizations.of(context)!;
    return ErrorState(
      message: localizeError(error, l10n),
      actionLabel: l10n.clinicalHistoryRetry,
      onActionPressed: () => ref.read(clinicalHistoryProvider.notifier).load(),
    );
  }
}
