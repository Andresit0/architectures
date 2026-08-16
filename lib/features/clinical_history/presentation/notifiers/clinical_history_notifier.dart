import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'clinical_history_refresh_error_provider.dart';
import 'clinical_history_state.dart';

part 'clinical_history_notifier.g.dart';

@riverpod
class ClinicalHistoryNotifier extends _$ClinicalHistoryNotifier {
  @override
  ClinicalHistoryState build() => const ClinicalHistoryInitial();

  Future<void> load() async {
    state = const ClinicalHistoryLoading();
    final result = await ref.read(loadClinicalHistoriesUseCaseProvider)(
      NoParams(),
    );
    await result.fold(
      onSuccess: (list) async {
        state = ClinicalHistoryLoaded(list);
      },
      onFailure: (error) async {
        ref
            .read(loggerProvider)
            .error(
              '[clinical_history] load failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = ClinicalHistoryFailure(error);
      },
    );
  }

  Future<void> refresh() async {
    ref.read(clinicalHistoryRefreshErrorProvider.notifier).set(null);
    final result = await ref.read(refreshClinicalHistoriesUseCaseProvider)(
      NoParams(),
    );
    await result.fold(
      onSuccess: (list) async {
        state = ClinicalHistoryLoaded(list);
      },
      onFailure: (error) async {
        ref
            .read(loggerProvider)
            .error(
              '[clinical_history] refresh failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        if (state is ClinicalHistoryLoaded) {
          ref.read(clinicalHistoryRefreshErrorProvider.notifier).set(error);
        } else {
          state = ClinicalHistoryFailure(error);
        }
      },
    );
  }

  void reset() => state = const ClinicalHistoryInitial();
}
