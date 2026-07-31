import 'package:clean_architecture_sdd_harness/l10n/app_localizations_en.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('localizeError', () {
    test('returns errorNetwork for NetworkError', () {
      const error = NetworkError.technical();
      expect(localizeError(error, l10n), l10n.errorNetwork);
    });

    test('returns errorServer for ApiError', () {
      const error = ApiError.technical();
      expect(localizeError(error, l10n), l10n.errorServer);
    });

    test('returns errorServer for ServerUnreachableError', () {
      const error = ServerUnreachableError.technical();
      expect(localizeError(error, l10n), l10n.errorServer);
    });

    test('returns errorUnknown for UnexpectedError', () {
      const error = UnexpectedError.technical();
      expect(localizeError(error, l10n), l10n.errorUnknown);
    });

    test('returns errorUnknown for DeviceSecurityError', () {
      const error = DeviceSecurityError.technical();
      expect(localizeError(error, l10n), l10n.errorUnknown);
    });

    test('returns errorInvalidCredentials for ValidationError', () {
      const error = ValidationError.technical();
      expect(localizeError(error, l10n), l10n.errorInvalidCredentials);
    });
  });
}
