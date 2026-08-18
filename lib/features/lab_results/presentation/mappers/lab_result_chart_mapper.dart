import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/utils/lab_value_formatter.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class LabResultChartMapper {
  const LabResultChartMapper();

  TrendChartData toTrendChartData({
    required LabResultEntity result,
    required List<LabResultValueEntity> values,
    required String Function(DateTime date) formatDate,
    required String Function(LabResultStatus status) statusLabel,
    required String referenceRangeLabel,
  }) {
    final numericValues = values.where((v) => v.value != null).toList();
    final unit = result.unit ?? '';
    return TrendChartData(
      points: [
        for (final value in numericValues)
          TrendPoint(date: value.date, value: value.value!),
      ],
      xLabels: [for (final value in numericValues) formatDate(value.date)],
      referenceLow: result.referenceRange?.low,
      referenceHigh: result.referenceRange?.high,
      unit: unit,
      tooltipLines: [
        for (final value in numericValues)
          _tooltipLine(
            value: value,
            unit: unit,
            range: result.referenceRange,
            formatDate: formatDate,
            statusLabel: statusLabel,
            referenceRangeLabel: referenceRangeLabel,
          ),
      ],
    );
  }

  String _tooltipLine({
    required LabResultValueEntity value,
    required String unit,
    required LabResultReferenceRangeEntity? range,
    required String Function(DateTime) formatDate,
    required String Function(LabResultStatus) statusLabel,
    required String referenceRangeLabel,
  }) {
    final lines = <String>[
      formatDate(value.date),
      formatLabValue(value.value, unit),
    ];
    if (range != null) {
      lines.add(
        '$referenceRangeLabel: '
        '${formatLabValue(range.low)}–${formatLabValue(range.high)}',
      );
    }
    lines.add(statusLabel(deriveLabResultStatus(value.value, range)));
    return lines.join('\n');
  }
}
