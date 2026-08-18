import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

part 'lab_results_state.freezed.dart';

@freezed
sealed class LabResultsState with _$LabResultsState {
  const factory LabResultsState.initial() = LabResultsInitial;

  const factory LabResultsState.loading() = LabResultsLoading;

  const factory LabResultsState.loaded({
    required List<LabResultEntity> results,
    String? selectedTestId,
    required Period period,
  }) = LabResultsLoaded;

  const factory LabResultsState.failure({required AppError error}) =
      LabResultsFailure;
}
