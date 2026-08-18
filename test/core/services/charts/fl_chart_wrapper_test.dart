import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TrendChartData sampleData({bool withRange = true}) {
    return TrendChartData(
      points: [
        TrendPoint(date: DateTime(2024, 1, 1), value: 100),
        TrendPoint(date: DateTime(2024, 1, 2), value: 120),
        TrendPoint(date: DateTime(2024, 1, 3), value: 110),
      ],
      xLabels: const ['Jan', 'Feb', 'Mar'],
      referenceLow: withRange ? 90 : null,
      referenceHigh: withRange ? 140 : null,
      unit: 'mg/dL',
      tooltipLines: const ['Glucose', 'Unit: mg/dL'],
    );
  }

  group('trendChartProvider', () {
    test('provides a non-null ITrendChart', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final chart = container.read(trendChartProvider);

      expect(chart, isNotNull);
      expect(chart, isA<ITrendChart>());
    });

    test('provided instance renders a LineChart for valid data (smoke)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final chart = container.read(trendChartProvider);
      final widget = chart.lineChart(data: sampleData());

      expect(widget, isNotNull);
      expect(widget, isA<LineChart>());
    });
  });

  group('FlChartTrendChart.lineChart', () {
    test('returns a non-null Widget for valid TrendChartData', () {
      const chart = FlChartTrendChart();

      final widget = chart.lineChart(data: sampleData());

      expect(widget, isNotNull);
      expect(widget, isA<Widget>());
    });

    test(
      'includes the reference range band when referenceLow/High are set',
      () {
        const chart = FlChartTrendChart();

        final widget = chart.lineChart(data: sampleData(withRange: true));

        expect(widget, isA<LineChart>());
        final bands = (widget as LineChart)
            .data
            .rangeAnnotations
            .horizontalRangeAnnotations;
        expect(bands, hasLength(1));
        expect(bands.first.y1, 90);
        expect(bands.first.y2, 140);
      },
    );

    test('renders no band when the reference range is absent', () {
      const chart = FlChartTrendChart();

      final widget = chart.lineChart(data: sampleData(withRange: false));

      expect(widget, isA<LineChart>());
      final bands = (widget as LineChart)
          .data
          .rangeAnnotations
          .horizontalRangeAnnotations;
      expect(bands, isEmpty);
    });

    test(
      'bottom titles fit inside the axis box so edge labels do not collide with margins',
      () {
        const chart = FlChartTrendChart();

        final widget = chart.lineChart(data: sampleData());

        final bottomTitles =
            (widget as LineChart).data.titlesData.bottomTitles.sideTitles;
        final meta = TitleMeta(
          min: 0,
          max: 10,
          parentAxisSize: 100,
          axisPosition: 0,
          appliedInterval: 1,
          sideTitles: bottomTitles,
          formattedValue: 'Jan',
          axisSide: AxisSide.bottom,
          rotationQuarterTurns: 0,
        );

        final titleWidget = bottomTitles.getTitlesWidget(
          sampleData().points.first.date.millisecondsSinceEpoch.toDouble(),
          meta,
        );

        expect(titleWidget, isA<SideTitleWidget>());
        expect((titleWidget as SideTitleWidget).fitInside.enabled, isTrue);
      },
    );
  });
}
