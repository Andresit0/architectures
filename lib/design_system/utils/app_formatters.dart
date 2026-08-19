import 'package:intl/intl.dart';

String formatClinicalDate(String value, {String? locale}) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat.yMMMd(locale).format(date);
}

String formatChartDate(DateTime date, {String? locale}) =>
    DateFormat.yMMMd(locale).format(date);

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = -1;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = value >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return '$text ${units[unit]}';
}
