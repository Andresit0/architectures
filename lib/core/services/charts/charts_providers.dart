import 'package:clean_architecture_sdd_harness/core/services/charts/fl_chart_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trendChartProvider = Provider<ITrendChart>(
  (ref) => const FlChartTrendChart(),
);
