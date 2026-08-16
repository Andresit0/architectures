import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/error/_error.lib.dart';
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
  }) = AuthLoaded;
  const factory AuthState.failure(AppError error) = AuthFailure;
}
