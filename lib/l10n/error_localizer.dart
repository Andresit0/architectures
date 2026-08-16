import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

String localizeError(AppError error, AppLocalizations l10n) => switch (error) {
  NetworkError() => l10n.errorNetwork,
  ApiError() => l10n.errorServer,
  ServerUnreachableError() => l10n.errorServer,
  TimeoutError() => l10n.errorTimeout,
  UnexpectedError() => l10n.errorUnknown,
  DeviceSecurityError() => l10n.errorDeviceSecurity,
  ValidationError(:final field) => switch (field) {
    'email' => l10n.errorInvalidEmail,
    'password' => l10n.errorPasswordTooShort,
    _ => l10n.errorInvalidCredentials,
  },
};
