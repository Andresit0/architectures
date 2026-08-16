import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_service_dto.freezed.dart';
part 'clinical_history_service_dto.g.dart';

@freezed
abstract class ClinicalHistoryServiceDto with _$ClinicalHistoryServiceDto {
  const factory ClinicalHistoryServiceDto({
    required String code,
    required String name,
    required String category,
  }) = _ClinicalHistoryServiceDto;

  factory ClinicalHistoryServiceDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryServiceDtoFromJson(json);
}
