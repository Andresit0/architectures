import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/mappers/lab_result_chart_mapper.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

final _result = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: const [],
);

final _values = <LabResultValueEntity>[
  LabResultValueEntity(
    date: DateTime(2026, 8, 10),
    value: 16.8,
    textValue: null,
  ),
  LabResultValueEntity(
    date: DateTime(2026, 6, 14),
    value: null,
    textValue: null,
  ),
  LabResultValueEntity(
    date: DateTime(2026, 3, 22),
    value: 15.4,
    textValue: null,
  ),
];

String _formatDate(DateTime date) => 'D${date.day}/${date.month}';

String _statusLabel(LabResultStatus status) => 'status:${status.name}';

void main() {
  group('LabResultChartMapper', () {
    const mapper = LabResultChartMapper();

    test('maps points and xLabels from numeric values, filtering nulls', () {
      final data = mapper.toTrendChartData(
        result: _result,
        values: _values,
        formatDate: _formatDate,
        statusLabel: _statusLabel,
        referenceRangeLabel: 'Range',
      );

      expect(data.points, hasLength(2));
      expect(data.points[0].date, DateTime(2026, 8, 10));
      expect(data.points[0].value, 16.8);
      expect(data.points[1].date, DateTime(2026, 3, 22));
      expect(data.points[1].value, 15.4);
      expect(data.xLabels, ['D10/8', 'D22/3']);
    });

    test('excludes null-value entries from points, xLabels and tooltips', () {
      final data = mapper.toTrendChartData(
        result: _result,
        values: _values,
        formatDate: _formatDate,
        statusLabel: _statusLabel,
        referenceRangeLabel: 'Range',
      );

      expect(
        data.points.map((p) => p.date),
        isNot(contains(DateTime(2026, 6, 14))),
      );
      expect(data.xLabels, isNot(contains('D14/6')));
      expect(data.tooltipLines, hasLength(2));
    });

    test('maps the reference band and unit', () {
      final data = mapper.toTrendChartData(
        result: _result,
        values: _values,
        formatDate: _formatDate,
        statusLabel: _statusLabel,
        referenceRangeLabel: 'Range',
      );

      expect(data.referenceLow, 13.0);
      expect(data.referenceHigh, 17.0);
      expect(data.unit, 'g/dL');
    });

    test('falls back to an empty unit when the result has none', () {
      final noUnit = LabResultEntity(
        id: 'lr_x',
        testCode: 'X',
        testName: 'X',
        category: 'X',
        unit: null,
        kind: LabResultKind.numeric,
        referenceRange: null,
        values: const [],
      );

      final data = mapper.toTrendChartData(
        result: noUnit,
        values: _values,
        formatDate: _formatDate,
        statusLabel: _statusLabel,
        referenceRangeLabel: 'Range',
      );

      expect(data.unit, '');
    });

    test(
      'tooltip includes date, value+unit, range and status with a range',
      () {
        final data = mapper.toTrendChartData(
          result: _result,
          values: _values,
          formatDate: _formatDate,
          statusLabel: _statusLabel,
          referenceRangeLabel: 'Range',
        );

        final first = data.tooltipLines.first;
        expect(first, contains('D10/8'));
        expect(first, contains('16.8 g/dL'));
        expect(first, contains('Range: 13–17'));
        expect(first, contains('status:normal'));
      },
    );

    test('tooltip omits the range when the result has none', () {
      final noRange = LabResultEntity(
        id: 'lr_x',
        testCode: 'X',
        testName: 'X',
        category: 'X',
        unit: 'mg/dL',
        kind: LabResultKind.numeric,
        referenceRange: null,
        values: const [],
      );

      final data = mapper.toTrendChartData(
        result: noRange,
        values: _values,
        formatDate: _formatDate,
        statusLabel: _statusLabel,
        referenceRangeLabel: 'Range',
      );

      final first = data.tooltipLines.first;
      expect(first, contains('16.8 mg/dL'));
      expect(first, isNot(contains('Range')));
    });

    test('invokes the status label callback with the derived status', () {
      LabResultStatus? lastStatus;
      mapper.toTrendChartData(
        result: _result,
        values: _values,
        formatDate: _formatDate,
        statusLabel: (status) {
          lastStatus = status;
          return 'status:${status.name}';
        },
        referenceRangeLabel: 'Range',
      );

      expect(lastStatus, LabResultStatus.normal);
    });
  });
}
