import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

LabResultValueEntity _value(DateTime date, double value) =>
    LabResultValueEntity(date: date, value: value, textValue: null);

void main() {
  group('Period', () {
    test('duration maps each period to the expected calendar window', () {
      expect(Period.threeMonths.duration, const Duration(days: 92));
      expect(Period.sixMonths.duration, const Duration(days: 183));
      expect(Period.oneYear.duration, const Duration(days: 365));
    });

    test('all has no duration (the filter keeps every value)', () {
      expect(Period.all.duration, isNull);
    });
  });

  group('filterByPeriod', () {
    final values = [
      _value(DateTime(2025, 12, 1), 90.0),
      _value(DateTime(2026, 4, 1), 92.0),
      _value(DateTime(2026, 5, 10), 95.0),
      _value(DateTime(2026, 6, 15), 98.0),
      _value(DateTime(2026, 8, 10), 101.0),
    ];

    test(
      'threeMonths keeps only values within 3 months of the most recent date',
      () {
        final filtered = filterByPeriod(values, Period.threeMonths);

        expect(filtered, [
          _value(DateTime(2026, 5, 10), 95.0),
          _value(DateTime(2026, 6, 15), 98.0),
          _value(DateTime(2026, 8, 10), 101.0),
        ]);
      },
    );

    test('oneYear keeps values within 1 year of the most recent date', () {
      final filtered = filterByPeriod(values, Period.oneYear);

      expect(filtered, values);
    });

    test('all returns the values unchanged', () {
      final filtered = filterByPeriod(values, Period.all);

      expect(filtered, values);
    });

    test('empty list returns empty for any period', () {
      expect(
        filterByPeriod(<LabResultValueEntity>[], Period.threeMonths),
        isEmpty,
      );
      expect(filterByPeriod(<LabResultValueEntity>[], Period.oneYear), isEmpty);
    });
  });
}
