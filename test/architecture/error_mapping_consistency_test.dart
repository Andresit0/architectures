import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _canonicalMapping = <String, String>{
  'ApiException': 'ApiError',
  'NoConnectionException': 'NetworkError',
  'ServerUnreachableException': 'ServerUnreachableError',
  'UnexpectedResponseException': 'UnexpectedError',
  'AppTimeoutException': 'TimeoutError',
  'DeviceSecurityException': 'DeviceSecurityError',
};

void main() {
  group('Error mapping consistency', () {
    final guardSource = File(
      'lib/shared/error/result_guard.dart',
    ).readAsStringSync();
    final localizerSource = File(
      'lib/l10n/error_localizer.dart',
    ).readAsStringSync();

    test('every exception in shared/exceptions is mapped in guard()', () {
      for (final exception in _canonicalMapping.keys) {
        expect(
          guardSource.contains(exception),
          isTrue,
          reason:
              '$exception no tiene catch en guard() — añadirlo a '
              'result_guard.dart y a _canonicalMapping',
        );
      }
    });

    test('guard() handles the raw dart:async TimeoutException', () {
      expect(
        guardSource.contains('TimeoutException'),
        isTrue,
        reason: 'guard() debe mapear TimeoutException (dart:async)',
      );
    });

    test('every AppError subtype is localized in localizeError()', () {
      for (final error in _canonicalMapping.values) {
        expect(
          localizerSource.contains(error),
          isTrue,
          reason:
              '$error no tiene branch en localizeError() — añadirlo a '
              'error_localizer.dart y a _canonicalMapping',
        );
      }
    });

    test(
      'every exception file in shared/exceptions is in the canonical list',
      () {
        const fileToClass = <String, String>{
          'api_exception.dart': 'ApiException',
          'device_security_exception.dart': 'DeviceSecurityException',
          'no_connection_exception.dart': 'NoConnectionException',
          'server_unreachable_exception.dart': 'ServerUnreachableException',
          'app_timeout_exception.dart': 'AppTimeoutException',
          'unexpected_response_exception.dart': 'UnexpectedResponseException',
        };
        final exceptionFiles = Directory('lib/shared/exceptions')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_exception.dart'))
            .map((f) => f.uri.pathSegments.last)
            .toList();

        for (final fileName in exceptionFiles) {
          final className = fileToClass[fileName];
          expect(
            className != null && _canonicalMapping.containsKey(className),
            isTrue,
            reason:
                '$fileName existe en shared/exceptions pero su clase no está '
                'en _canonicalMapping — cubrir el mapping guard() + '
                'localizeError()',
          );
        }
      },
    );

    test(
      'every exception file is exported by the barrel _exceptions.lib.dart',
      () {
        final barrelSource = File(
          'lib/shared/exceptions/_exceptions.lib.dart',
        ).readAsStringSync();
        final exceptionFiles = Directory('lib/shared/exceptions')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_exception.dart'))
            .map((f) => f.uri.pathSegments.last)
            .toList();

        for (final fileName in exceptionFiles) {
          expect(
            barrelSource.contains("export '$fileName'"),
            isTrue,
            reason:
                '$fileName no está exportado en _exceptions.lib.dart — '
                'archivo huérfano (código muerto)',
          );
        }
      },
    );
  });
}
