import 'lab_result_reference_range_entity.dart';

enum LabResultStatus { normal, high, low, unknown }

LabResultStatus deriveLabResultStatus(
  double? value,
  LabResultReferenceRangeEntity? range,
) {
  if (value == null || range == null) return LabResultStatus.unknown;
  if (value > range.high) return LabResultStatus.high;
  if (value < range.low) return LabResultStatus.low;
  return LabResultStatus.normal;
}
