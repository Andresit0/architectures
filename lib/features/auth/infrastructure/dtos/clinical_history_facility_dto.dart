import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_facility_dto.freezed.dart';
part 'clinical_history_facility_dto.g.dart';

@freezed
abstract class ClinicalHistoryFacilityDto with _$ClinicalHistoryFacilityDto {
  const factory ClinicalHistoryFacilityDto({
    required String id,
    required String name,
    required String city,
  }) = _ClinicalHistoryFacilityDto;

  factory ClinicalHistoryFacilityDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryFacilityDtoFromJson(json);
}
