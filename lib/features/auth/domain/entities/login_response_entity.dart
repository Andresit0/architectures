import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';

import 'token_entity.dart';

part 'login_response_entity.freezed.dart';

@freezed
abstract class LoginResponseEntity with _$LoginResponseEntity {
  const LoginResponseEntity._();

  const factory LoginResponseEntity({
    required PatientEntity patient,
    required TokenEntity token,
    required List<ClinicalHistoryEntity> clinicalHistory,
  }) = _LoginResponseEntity;
}
