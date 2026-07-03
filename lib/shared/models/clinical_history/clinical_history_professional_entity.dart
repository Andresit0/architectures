import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_professional_entity.freezed.dart';
part 'clinical_history_professional_entity.g.dart';

@freezed
abstract class ClinicalHistoryProfessionalEntity
    with _$ClinicalHistoryProfessionalEntity {
  const ClinicalHistoryProfessionalEntity._();

  const factory ClinicalHistoryProfessionalEntity({
    required String id,
    @JsonKey(name: 'fullname') required String fullname,
    required String specialty,
  }) = _ClinicalHistoryProfessionalEntity;

  factory ClinicalHistoryProfessionalEntity.fromJson(
          Map<String, dynamic> json) =>
      _$ClinicalHistoryProfessionalEntityFromJson(json);
}
