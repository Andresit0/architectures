import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'lab_results_period_provider.dart';
import 'lab_results_refresh_error_provider.dart';
import 'lab_results_state.dart';

part 'lab_results_notifier.g.dart';

@riverpod
class LabResultsNotifier extends _$LabResultsNotifier {
  @override
  LabResultsState build() => const LabResultsInitial();

  Future<void> load() async {
    state = const LabResultsLoading();
    final result = await ref.read(loadLabResultsUseCaseProvider)(
      const NoParams(),
    );
    await result.fold(
      onSuccess: (list) async {
        state = LabResultsLoaded(
          results: list,
          selectedTestId: _firstNumericId(list),
          period: ref.read(labResultsPeriodProvider),
        );
      },
      onFailure: (error) async {
        ref
            .read(loggerProvider)
            .error(
              '[lab_results] load failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = LabResultsFailure(error: error);
      },
    );
  }

  Future<void> refresh() async {
    ref.read(labResultsRefreshErrorProvider.notifier).set(null);
    final result = await ref.read(refreshLabResultsUseCaseProvider)(
      const NoParams(),
    );
    await result.fold(
      onSuccess: (list) async {
        final current = state;
        final selectedTestId = current is LabResultsLoaded
            ? current.selectedTestId
            : null;
        state = LabResultsLoaded(
          results: list,
          selectedTestId: _revalidateSelection(list, selectedTestId),
          period: current is LabResultsLoaded
              ? current.period
              : ref.read(labResultsPeriodProvider),
        );
      },
      onFailure: (error) async {
        ref
            .read(loggerProvider)
            .error(
              '[lab_results] refresh failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        if (state is LabResultsLoaded) {
          ref.read(labResultsRefreshErrorProvider.notifier).set(error);
        } else {
          state = LabResultsFailure(error: error);
        }
      },
    );
  }

  void selectTest(String id) {
    final current = state;
    if (current is LabResultsLoaded) {
      state = LabResultsLoaded(
        results: current.results,
        selectedTestId: id,
        period: current.period,
      );
    }
  }

  void setPeriod(Period period) {
    final current = state;
    if (current is LabResultsLoaded) {
      state = LabResultsLoaded(
        results: current.results,
        selectedTestId: current.selectedTestId,
        period: period,
      );
    }
  }

  void reset() {
    state = const LabResultsInitial();
    ref.read(labResultsRefreshErrorProvider.notifier).set(null);
  }

  String? _firstNumericId(List<LabResultEntity> results) {
    for (final result in results) {
      if (result.kind == LabResultKind.numeric) return result.id;
    }
    return null;
  }

  String? _revalidateSelection(
    List<LabResultEntity> results,
    String? selectedTestId,
  ) {
    if (selectedTestId != null &&
        results.any((result) => result.id == selectedTestId)) {
      return selectedTestId;
    }
    return _firstNumericId(results);
  }
}
