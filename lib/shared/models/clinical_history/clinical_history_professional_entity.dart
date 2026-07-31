import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_professional_entity.freezed.dart';

@freezed
abstract class ClinicalHistoryProfessionalEntity
    with _$ClinicalHistoryProfessionalEntity {
  const ClinicalHistoryProfessionalEntity._();

  const factory ClinicalHistoryProfessionalEntity({
    required String id,
    required String fullname,
    required String specialty,
  }) = _ClinicalHistoryProfessionalEntity;
}
