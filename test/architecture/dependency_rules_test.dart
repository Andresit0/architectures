import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Architecture Dependency Rules', () {
    test(
        'Rule 1: domain/entities/ NO importa infrastructure, core, app, ni flutter',
        () {
      final files = Directory('lib/features/auth/domain/entities')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
              (f) => f.path.endsWith('.dart') && !f.path.contains('.freezed.dart'));

      for (final file in files) {
        final content = file.readAsStringSync();
        // Only check imports, not part directives
        final imports =
            content.split('\n').where((line) => line.startsWith('import'));

        for (final import in imports) {
          expect(import.contains('infrastructure/'), isFalse,
              reason: '${file.path} importa infrastructure/');
          expect(import.contains('core/'), isFalse,
              reason: '${file.path} importa core/');
          expect(import.contains('app/'), isFalse,
              reason: '${file.path} importa app/');
          expect(import.contains('package:flutter/'), isFalse,
              reason: '${file.path} importa flutter');
        }
      }
    });

    test(
        'Rule 2: shared/models/ NO importa infrastructure, core, app, ni flutter',
        () {
      final files = Directory('lib/shared/models')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
              (f) => f.path.endsWith('.dart') && !f.path.contains('.freezed.dart'));

      for (final file in files) {
        final content = file.readAsStringSync();
        final imports =
            content.split('\n').where((line) => line.startsWith('import'));

        for (final import in imports) {
          expect(import.contains('infrastructure/'), isFalse,
              reason: '${file.path} importa infrastructure/');
          expect(import.contains('core/'), isFalse,
              reason: '${file.path} importa core/');
          expect(import.contains('app/'), isFalse,
              reason: '${file.path} importa app/');
          expect(import.contains('package:flutter/'), isFalse,
              reason: '${file.path} importa flutter');
        }
      }
    });

    test('Rule 3: No .g.dart files in domain/entities/ or shared/models/', () {
      final domainG = Directory('lib/features/auth/domain/entities')
          .listSync()
          .where((f) => f.path.endsWith('.g.dart'));
      expect(domainG, isEmpty,
          reason: 'domain/entities/ contiene .g.dart');

      final sharedG = Directory('lib/shared/models')
          .listSync(recursive: true)
          .where((f) => f.path.endsWith('.g.dart'));
      expect(sharedG, isEmpty,
          reason: 'shared/models/ contiene .g.dart');
    });

    test('Rule 4: No Entity.fromJson() calls in lib/ (DTOs are the exception)',
        () {
      // Allow in DTOs: Dto.fromJson() is fine
      // Forbid in non-DTO files: Entity.fromJson()
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') &&
              !f.path.contains('.freezed.dart') &&
              !f.path.contains('.g.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        // Check for Entity.fromJson pattern (not Dto.fromJson)
        if (content.contains('Entity.fromJson(')) {
          fail('${file.path} contains Entity.fromJson()');
        }
      }
    });

    test('Rule 5: features/ NO importan de otros features/', () {
      final featureDirs = Directory('lib/features')
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path.split('/').last);

      for (final feature in featureDirs) {
        final featureFiles = Directory('lib/features/$feature')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) =>
                f.path.endsWith('.dart') &&
                !f.path.contains('.freezed.dart') &&
                !f.path.contains('.g.dart'));

        for (final file in featureFiles) {
          final content = file.readAsStringSync();
          final imports =
              content.split('\n').where((line) => line.startsWith('import'));

          for (final import in imports) {
            for (final otherFeature in featureDirs) {
              if (otherFeature != feature &&
                  import.contains('features/$otherFeature')) {
                fail('${file.path} importa features/$otherFeature/');
              }
            }
          }
        }
      }
    });

    test(
        'Rule 6: features/ NO importa paquetes externos directamente (solo via wrappers)',
        () {
      final externalPackages = [
        'package:dio',
        'package:sembast',
        'package:flutter_secure_storage',
        'package:dart_jsonwebtoken',
        'package:bcrypt',
        'package:encrypt',
        'package:crypto',
        'package:go_router',
        'package:internet_connection_checker_plus',
        'package:path_provider',
        'package:flutter_jailbreak_detection',
        'package:logger',
      ];

      final featureFiles = Directory('lib/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') &&
              !f.path.contains('.freezed.dart') &&
              !f.path.contains('.g.dart') &&
              !f.path.contains('/di/'));

      for (final file in featureFiles) {
        final content = file.readAsStringSync();
        final imports =
            content.split('\n').where((line) => line.startsWith('import'));

        for (final import in imports) {
          for (final pkg in externalPackages) {
            expect(import.contains(pkg), isFalse,
                reason:
                    '${file.path} importa $pkg directamente. Debe usar wrapper.');
          }
        }
      }
    });

    test('Rule 7: domain/ NO importa presentation/', () {
      final domainFiles = Directory('lib/features/auth/domain')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') &&
              !f.path.contains('.freezed.dart') &&
              !f.path.contains('.g.dart'));

      for (final file in domainFiles) {
        final content = file.readAsStringSync();
        final imports =
            content.split('\n').where((line) => line.startsWith('import'));
        for (final import in imports) {
          expect(import.contains('presentation/'), isFalse,
              reason: '${file.path} importa presentation/');
        }
      }
    });

    test('Rule 8: infrastructure/ NO importa presentation/', () {
      final infraFiles = Directory('lib/features/auth/infrastructure')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') &&
              !f.path.contains('.freezed.dart') &&
              !f.path.contains('.g.dart'));

      for (final file in infraFiles) {
        final content = file.readAsStringSync();
        final imports =
            content.split('\n').where((line) => line.startsWith('import'));
        for (final import in imports) {
          expect(import.contains('presentation/'), isFalse,
              reason: '${file.path} importa presentation/');
        }
      }
    });

    test(
        'Rule 9: domain/entities/ NO importa paquetes externos (solo shared/ y freezed_annotation)',
        () {
      final allowedPrefixes = [
        'package:clean_architecture_sdd_harness/shared/',
        'package:freezed_annotation/',
      ];

      final entityFiles = Directory('lib/features/auth/domain/entities')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') &&
              !f.path.contains('.freezed.dart'));

      for (final file in entityFiles) {
        final content = file.readAsStringSync();
        final imports =
            content.split('\n').where((line) => line.startsWith('import'));

        for (final import in imports) {
          final isAllowed = allowedPrefixes
              .any((prefix) => import.contains(prefix));
          final isDartSdk = import.contains('dart:');
          final isRelative = !import.contains('package:');
          if (!isAllowed && !isDartSdk && !isRelative) {
            fail('${file.path} importa "${import.trim()}" - no permitido');
          }
        }
      }
    });
  });
}
