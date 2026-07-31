import 'package:freezed_annotation/freezed_annotation.dart';

import 'clinical_history_dto.dart';
import 'patient_dto.dart';
import 'token_dto.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required PatientDto patient,
    required TokenDto token,
    @JsonKey(name: 'clinical_history') @Default([]) List<ClinicalHistoryDto> clinicalHistory,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
