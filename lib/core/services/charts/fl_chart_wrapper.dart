import 'dart:math' as math;

import 'package:clean_architecture_sdd_harness/core/services/charts/models/trend_chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

abstract interface class ITrendChart {
  Widget lineChart({required TrendChartData data});
}

class FlChartTrendChart implements ITrendChart {
  const FlChartTrendChart();

  static const Color _lineColor = Color(0xFF1565C0);
  static const Color _bandColor = Color(0x221565C0);

  @override
  Widget lineChart({required TrendChartData data}) {
    return LineChart(_buildChartData(data));
  }

  LineChartData _buildChartData(TrendChartData data) {
    final spots = <FlSpot>[
      for (final point in data.points)
        FlSpot(point.date.millisecondsSinceEpoch.toDouble(), point.value),
    ];

    final low = data.referenceLow;
    final high = data.referenceHigh;
    final hasRange = low != null && high != null;

    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (final spot in spots) {
      minY = math.min(minY, spot.y);
      maxY = math.max(maxY, spot.y);
    }
    if (hasRange) {
      minY = math.min(minY, low);
      maxY = math.max(maxY, high);
    }
    if (spots.isEmpty || minY == double.infinity) minY = 0;
    if (spots.isEmpty || maxY == double.negativeInfinity) maxY = 1;

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _lineColor,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      ],
      minY: minY,
      maxY: maxY,
      rangeAnnotations: RangeAnnotations(
        horizontalRangeAnnotations: [
          if (hasRange)
            HorizontalRangeAnnotation(y1: low, y2: high, color: _bandColor),
        ],
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _buildBottomTitle(spots, data.xLabels),
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) => [
            for (final _ in touchedSpots)
              LineTooltipItem(
                data.tooltipLines.join('\n'),
                const TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  GetTitleWidgetFunction _buildBottomTitle(
    List<FlSpot> spots,
    List<String> xLabels,
  ) {
    return (value, meta) {
      final index = spots.indexWhere((spot) => spot.x == value);
      if (index < 0 || index >= xLabels.length) {
        return const SizedBox.shrink();
      }
      return SideTitleWidget(
        meta: meta,
        fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
        child: Text(xLabels[index], style: const TextStyle(fontSize: 10)),
      );
    };
  }
}
