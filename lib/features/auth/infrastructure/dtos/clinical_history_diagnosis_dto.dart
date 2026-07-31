import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_diagnosis_dto.freezed.dart';
part 'clinical_history_diagnosis_dto.g.dart';

@freezed
abstract class ClinicalHistoryDiagnosisDto with _$ClinicalHistoryDiagnosisDto {
  const factory ClinicalHistoryDiagnosisDto({
    required String code,
    required String name,
  }) = _ClinicalHistoryDiagnosisDto;

  factory ClinicalHistoryDiagnosisDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryDiagnosisDtoFromJson(json);
}
