import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_diagnosis_entity.freezed.dart';

@freezed
abstract class ClinicalHistoryDiagnosisEntity
    with _$ClinicalHistoryDiagnosisEntity {
  const ClinicalHistoryDiagnosisEntity._();

  const factory ClinicalHistoryDiagnosisEntity({
    required String code,
    required String name,
  }) = _ClinicalHistoryDiagnosisEntity;
}
