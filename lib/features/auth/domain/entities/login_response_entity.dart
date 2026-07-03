import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/models/patient/patient_entity.dart';
import 'token_entity.dart';
import '../../../../shared/models/clinical_history/clinical_history_entity.dart';

part 'login_response_entity.freezed.dart';
part 'login_response_entity.g.dart';

@freezed
abstract class LoginResponseEntity with _$LoginResponseEntity {
  const LoginResponseEntity._();

  const factory LoginResponseEntity({
    required PatientEntity patient,
    required TokenEntity token,
    @JsonKey(name: 'clinical_history') required List<ClinicalHistoryEntity>? clinicalHistory,
  }) = _LoginResponseEntity;

  factory LoginResponseEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseEntityFromJson(json);
}
