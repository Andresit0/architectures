import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

part 'lab_results_refresh_error_provider.g.dart';

@riverpod
class LabResultsRefreshError extends _$LabResultsRefreshError {
  @override
  AppError? build() => null;

  void set(AppError? error) => state = error;
}
