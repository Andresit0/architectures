import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_result_value_dto.freezed.dart';
part 'lab_result_value_dto.g.dart';

@freezed
abstract class LabResultValueDto with _$LabResultValueDto {
  const factory LabResultValueDto({
    required DateTime date,
    required dynamic value,
  }) = _LabResultValueDto;

  factory LabResultValueDto.fromJson(Map<String, dynamic> json) =>
      _$LabResultValueDtoFromJson(json);
}
