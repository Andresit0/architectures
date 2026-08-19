import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

part 'clinical_history_refresh_error_provider.g.dart';

@riverpod
class ClinicalHistoryRefreshError extends _$ClinicalHistoryRefreshError {
  @override
  AppError? build() => null;

  void set(AppError? error) => state = error;
}
