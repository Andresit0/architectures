import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_result_reference_range_entity.freezed.dart';

@freezed
abstract class LabResultReferenceRangeEntity
    with _$LabResultReferenceRangeEntity {
  const LabResultReferenceRangeEntity._();

  const factory LabResultReferenceRangeEntity({
    required double low,
    required double high,
  }) = _LabResultReferenceRangeEntity;
}
