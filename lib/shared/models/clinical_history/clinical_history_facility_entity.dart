import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_facility_entity.freezed.dart';
part 'clinical_history_facility_entity.g.dart';

@freezed
abstract class ClinicalHistoryFacilityEntity with _$ClinicalHistoryFacilityEntity {
  const ClinicalHistoryFacilityEntity._();

  const factory ClinicalHistoryFacilityEntity({
    required String id,
    required String name,
    required String city,
  }) = _ClinicalHistoryFacilityEntity;

  factory ClinicalHistoryFacilityEntity.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryFacilityEntityFromJson(json);
}
