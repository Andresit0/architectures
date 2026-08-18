import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_result_value_entity.freezed.dart';

@freezed
abstract class LabResultValueEntity with _$LabResultValueEntity {
  const LabResultValueEntity._();

  const factory LabResultValueEntity({
    required DateTime date,
    double? value,
    String? textValue,
  }) = _LabResultValueEntity;
}
