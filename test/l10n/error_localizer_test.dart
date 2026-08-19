import 'package:clean_architecture_sdd_harness/l10n/error_localizer.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations_en.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations_es.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('localizeError', () {
    test('returns errorNetwork for NetworkError', () {
      const error = NetworkError();
      expect(localizeError(error, l10n), l10n.errorNetwork);
    });

    test('returns errorServer for ApiError', () {
      const error = ApiError();
      expect(localizeError(error, l10n), l10n.errorServer);
    });

    test('returns errorServer for ServerUnreachableError', () {
      const error = ServerUnreachableError();
      expect(localizeError(error, l10n), l10n.errorServer);
    });

    test('returns errorTimeout for TimeoutError', () {
      const error = TimeoutError();
      expect(localizeError(error, l10n), l10n.errorTimeout);
    });

    test('returns errorUnknown for UnexpectedError', () {
      const error = UnexpectedError();
      expect(localizeError(error, l10n), l10n.errorUnknown);
    });

    test('returns errorDeviceSecurity for DeviceSecurityError', () {
      const error = DeviceSecurityError();
      expect(localizeError(error, l10n), l10n.errorDeviceSecurity);
    });

    test('returns errorInvalidCredentials for ValidationError', () {
      const error = ValidationError();
      expect(localizeError(error, l10n), l10n.errorInvalidCredentials);
    });
  });

  group('localizeError (es)', () {
    final es = AppLocalizationsEs();

    test('returns errorUnknown for UnexpectedError with technical message', () {
      const error = UnexpectedError(technicalMessage: 'details');
      expect(localizeError(error, es), es.errorUnknown);
    });
  });
}
