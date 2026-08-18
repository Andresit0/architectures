import 'package:freezed_annotation/freezed_annotation.dart';

import 'lab_result_kind.dart';
import 'lab_result_reference_range_entity.dart';
import 'lab_result_status.dart';
import 'lab_result_value_entity.dart';

part 'lab_result_entity.freezed.dart';

@freezed
abstract class LabResultEntity with _$LabResultEntity {
  const LabResultEntity._();

  const factory LabResultEntity({
    required String id,
    required String testCode,
    required String testName,
    required String category,
    required String? unit,
    required LabResultKind kind,
    required LabResultReferenceRangeEntity? referenceRange,
    required List<LabResultValueEntity> values,
  }) = _LabResultEntity;

  LabResultValueEntity? get latestValue {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  LabResultStatus get status {
    final latest = latestValue;
    if (latest == null) return LabResultStatus.unknown;
    return deriveLabResultStatus(latest.value, referenceRange);
  }
}
