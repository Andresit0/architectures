import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';

part 'lab_results_period_provider.g.dart';

@riverpod
class LabResultsPeriod extends _$LabResultsPeriod {
  @override
  Period build() => Period.all;

  void set(Period period) => state = period;
}
