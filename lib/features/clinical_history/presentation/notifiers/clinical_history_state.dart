import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

part 'clinical_history_state.freezed.dart';

@freezed
sealed class ClinicalHistoryState with _$ClinicalHistoryState {
  const factory ClinicalHistoryState.initial() = ClinicalHistoryInitial;

  const factory ClinicalHistoryState.loading() = ClinicalHistoryLoading;

  const factory ClinicalHistoryState.loaded(
    List<ClinicalHistoryEntity> clinicalHistory,
  ) = ClinicalHistoryLoaded;

  const factory ClinicalHistoryState.failure(AppError error) =
      ClinicalHistoryFailure;
}
