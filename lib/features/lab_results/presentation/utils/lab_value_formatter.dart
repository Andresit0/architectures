import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

String formatLabValue(double? value, [String unit = '']) {
  if (value == null) return unit.isEmpty ? '' : unit;
  final text = value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return unit.isEmpty ? text : '$text $unit';
}

String labStatusLabel(AppLocalizations l10n, LabResultStatus status) {
  switch (status) {
    case LabResultStatus.normal:
      return l10n.labResultsStatusNormal;
    case LabResultStatus.high:
      return l10n.labResultsStatusHigh;
    case LabResultStatus.low:
      return l10n.labResultsStatusLow;
    case LabResultStatus.unknown:
      return l10n.labResultsStatusUnknown;
  }
}
