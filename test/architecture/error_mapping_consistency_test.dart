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

const _programmingErrors = <String, String>{
  'seam_not_bound_exception.dart': 'SeamNotBoundException',
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
          'seam_not_bound_exception.dart': 'SeamNotBoundException',
        };
        final exceptionFiles = Directory('lib/shared/exceptions')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_exception.dart'))
            .map((f) => f.uri.pathSegments.last)
            .toList();

        for (final fileName in exceptionFiles) {
          final className = fileToClass[fileName];
          if (_programmingErrors.containsKey(fileName)) {
            expect(
              className != null,
              isTrue,
              reason:
                  '$fileName declarado en _programmingErrors pero su clase '
                  'no está en fileToClass',
            );
            expect(
              _canonicalMapping.containsKey(className),
              isFalse,
              reason:
                  '$className es un Error de programación (fail-fast) — NO '
                  'debe mapearse en guard() ni localizeError()',
            );
            final source = File(
              'lib/shared/exceptions/$fileName',
            ).readAsStringSync();
            expect(
              source.contains('extends Error'),
              isTrue,
              reason:
                  '$className debe extender Error (no Exception) para que '
                  'guard() no lo convierta en Failure — ver MD/APP_EXCEPTION.md',
            );
          } else {
            expect(
              className != null && _canonicalMapping.containsKey(className),
              isTrue,
              reason:
                  '$fileName existe en shared/exceptions pero su clase no está '
                  'en _canonicalMapping — cubrir el mapping guard() + '
                  'localizeError()',
            );
          }
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
