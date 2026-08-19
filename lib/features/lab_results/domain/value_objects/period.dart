import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

enum Period {
  threeMonths,
  sixMonths,
  oneYear,
  all;

  Duration? get duration => switch (this) {
    threeMonths => const Duration(days: 92),
    sixMonths => const Duration(days: 183),
    oneYear => const Duration(days: 365),
    all => null,
  };
}

List<LabResultValueEntity> filterByPeriod(
  List<LabResultValueEntity> values,
  Period period,
) {
  if (values.isEmpty) return values;
  final duration = period.duration;
  if (duration == null) return values;
  final mostRecent = values
      .map((value) => value.date)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final cutoff = mostRecent.subtract(duration);
  return values.where((value) => !value.date.isBefore(cutoff)).toList();
}
