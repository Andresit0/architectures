import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/error/app_error.dart';
import '../../../../shared/models/clinical_history/clinical_history_entity.dart';
import '../../../../shared/models/patient/patient_entity.dart';
import '../../domain/entities/token_entity.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.loaded({
    required PatientEntity patient,
    required TokenEntity token,
    @Default(null) List<ClinicalHistoryEntity>? clinicalHistory,
  }) = AuthLoaded;
  const factory AuthState.failure(AppError error) = AuthFailure;
}
