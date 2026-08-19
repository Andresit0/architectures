class TrendPoint {
  const TrendPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class TrendChartData {
  const TrendChartData({
    required this.points,
    this.xLabels = const [],
    this.referenceLow,
    this.referenceHigh,
    this.unit = '',
    this.tooltipLines = const [],
  });

  final List<TrendPoint> points;
  final List<String> xLabels;
  final double? referenceLow;
  final double? referenceHigh;
  final String unit;
  final List<String> tooltipLines;
}
