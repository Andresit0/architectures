import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

List<Directory> _featureDirs() =>
    Directory('lib/features').listSync().whereType<Directory>().toList();

List<File> _dartFilesIn(Directory dir) {
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where(
        (f) => !f.path.contains('.freezed.dart') && !f.path.contains('.g.dart'),
      )
      .toList();
}

List<String> _imports(File f) => f
    .readAsStringSync()
    .split('\n')
    .where((line) => line.startsWith('import'))
    .toList();

const _externalPackages = [
  'package:dio',
  'package:sembast',
  'package:flutter_secure_storage',
  'package:dart_jsonwebtoken',
  'package:bcrypt',
  'package:encrypt',
  'package:crypto',
  'package:fl_chart',
  'package:go_router',
  'package:internet_connection_checker_plus',
  'package:path_provider',
  'package:flutter_jailbreak_detection',
  'package:logger',
];

void main() {
  group('Architecture Dependency Rules', () {
    test(
      'Rule 1: domain/ NO importa infrastructure, core, app, presentation, ni flutter',
      () {
        for (final feature in _featureDirs()) {
          for (final file in _dartFilesIn(
            Directory('${feature.path}/domain'),
          )) {
            for (final import in _imports(file)) {
              for (final forbidden in [
                'infrastructure/',
                'core/',
                'app/',
                'presentation/',
                'package:flutter/',
              ]) {
                expect(
                  import.contains(forbidden),
                  isFalse,
                  reason: '${file.path} importa $forbidden',
                );
              }
            }
          }
        }
      },
    );

    test(
      'Rule 2: shared/models/ NO importa infrastructure, core, app, ni flutter',
      () {
        for (final file in _dartFilesIn(Directory('lib/shared/models'))) {
          for (final import in _imports(file)) {
            for (final forbidden in [
              'infrastructure/',
              'core/',
              'app/',
              'package:flutter/',
            ]) {
              expect(
                import.contains(forbidden),
                isFalse,
                reason: '${file.path} importa $forbidden',
              );
            }
          }
        }
      },
    );

    test('Rule 3: No .g.dart files in domain/ or shared/models/', () {
      for (final feature in _featureDirs()) {
        final domainG = Directory(
          '${feature.path}/domain',
        ).listSync().where((f) => f.path.endsWith('.g.dart'));
        expect(
          domainG,
          isEmpty,
          reason: '${feature.path}/domain contiene .g.dart',
        );
      }

      final sharedG = Directory(
        'lib/shared/models',
      ).listSync(recursive: true).where((f) => f.path.endsWith('.g.dart'));
      expect(sharedG, isEmpty, reason: 'shared/models/ contiene .g.dart');
    });

    test(
      'Rule 4: No Entity.fromJson() calls in lib/ (DTOs are the exception)',
      () {
        final dartFiles = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  !f.path.contains('.freezed.dart') &&
                  !f.path.contains('.g.dart'),
            );

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('Entity.fromJson(')) {
            fail('${file.path} contains Entity.fromJson()');
          }
        }
      },
    );

    test('Rule 5: features/ NO importan de otros features/', () {
      final featureNames = _featureDirs().map((d) => d.path.split('/').last);

      for (final feature in featureNames) {
        for (final file in _dartFilesIn(Directory('lib/features/$feature'))) {
          for (final import in _imports(file)) {
            for (final otherFeature in featureNames) {
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
        for (final feature in _featureDirs()) {
          final featureFiles = _dartFilesIn(feature);

          for (final file in featureFiles) {
            for (final import in _imports(file)) {
              for (final pkg in _externalPackages) {
                expect(
                  import.contains(pkg),
                  isFalse,
                  reason:
                      '${file.path} importa $pkg directamente. Debe usar wrapper.',
                );
              }
            }
          }
        }
      },
    );

    test('Rule 6b: feature tests (test/features, test/bdd, integration_test) '
        'NO importan paquetes externos directamente (solo via wrappers)', () {
      final testDirs = [
        Directory('test/features'),
        Directory('test/bdd'),
        Directory('integration_test'),
      ];

      for (final dir in testDirs) {
        for (final file in _dartFilesIn(dir)) {
          for (final import in _imports(file)) {
            for (final pkg in _externalPackages) {
              expect(
                import.contains(pkg),
                isFalse,
                reason:
                    '${file.path} importa $pkg directamente. Debe usar wrapper.',
              );
            }
          }
        }
      }
    });

    test('Rule 7: domain/ NO importa presentation/', () {
      for (final feature in _featureDirs()) {
        for (final file in _dartFilesIn(Directory('${feature.path}/domain'))) {
          for (final import in _imports(file)) {
            expect(
              import.contains('presentation/'),
              isFalse,
              reason: '${file.path} importa presentation/',
            );
          }
        }
      }
    });

    test('Rule 8: infrastructure/ NO importa presentation/', () {
      for (final feature in _featureDirs()) {
        for (final file in _dartFilesIn(
          Directory('${feature.path}/infrastructure'),
        )) {
          for (final import in _imports(file)) {
            expect(
              import.contains('presentation/'),
              isFalse,
              reason: '${file.path} importa presentation/',
            );
          }
        }
      }
    });

    test(
      'Rule 9: domain/entities/ NO importa paquetes externos (solo shared/ y freezed_annotation)',
      () {
        const allowedPrefixes = [
          'package:clean_architecture_sdd_harness/shared/',
          'package:freezed_annotation/',
        ];

        for (final feature in _featureDirs()) {
          final entityFiles = _dartFilesIn(
            Directory('${feature.path}/domain/entities'),
          );

          for (final file in entityFiles) {
            for (final import in _imports(file)) {
              final isAllowed = allowedPrefixes.any(
                (prefix) => import.contains(prefix),
              );
              final isDartSdk = import.contains('dart:');
              final isRelative = !import.contains('package:');
              if (!isAllowed && !isDartSdk && !isRelative) {
                fail('${file.path} importa "${import.trim()}" - no permitido');
              }
            }
          }
        }
      },
    );

    test('Rule 10: shared/ NO importa l10n/ ni package:flutter/', () {
      for (final file in _dartFilesIn(Directory('lib/shared'))) {
        for (final import in _imports(file)) {
          expect(
            import.contains('/l10n/'),
            isFalse,
            reason:
                '${file.path} importa l10n/ — la capa shared debe ser '
                '100% Dart puro (sin Flutter)',
          );
          expect(
            import.contains('package:flutter/'),
            isFalse,
            reason:
                '${file.path} importa flutter — la capa shared debe ser '
                '100% Dart puro (sin Flutter)',
          );
        }
      }
    });

    test('Rule 11: features/ NO importa app/', () {
      for (final feature in _featureDirs()) {
        for (final file in _dartFilesIn(feature)) {
          for (final import in _imports(file)) {
            expect(
              import.contains('/app/'),
              isFalse,
              reason:
                  '${file.path} importa app/ — DI unidireccional violado. '
                  'Importa providers desde core/ directamente.',
            );
          }
        }
      }
    });

    test(
      'Rule 12: domain/ NO importa paquetes externos (solo shared/, freezed_annotation y relativos)',
      () {
        for (final feature in _featureDirs()) {
          final featureName = feature.path.split('/').last;
          for (final file in _dartFilesIn(
            Directory('${feature.path}/domain'),
          )) {
            final content = file.readAsStringSync();
            expect(
              content.contains('.g.dart'),
              isFalse,
              reason:
                  '${file.path} — domain/ no admite .g.dart (sin '
                  'serialización en dominio; usar DTOs en infrastructure/)',
            );

            for (final import in _imports(file)) {
              final isShared = import.contains(
                'package:clean_architecture_sdd_harness/shared/',
              );
              final isFreezed = import.contains('package:freezed_annotation/');
              final isOwnDomain = import.contains(
                'features/$featureName/domain/',
              );
              final isDartSdk = import.contains('dart:');
              final isRelative = !import.contains('package:');
              if (!isShared &&
                  !isFreezed &&
                  !isOwnDomain &&
                  !isDartSdk &&
                  !isRelative) {
                fail(
                  '${file.path} importa "${import.trim()}" - no permitido '
                  'en domain/ (solo dart:, shared/, freezed_annotation y su '
                  'propio dominio)',
                );
              }
            }
          }
        }
      },
    );

    test(
      'Rule 13: no implementation_imports (package:.../src/) fuera de allowlist',
      () {
        const allowlist = <String>[];
        final root = Directory.current.path;

        final dartFiles = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  !f.path.contains('.g.dart') &&
                  !f.path.contains('.freezed.dart'),
            );

        for (final file in dartFiles) {
          for (final import in _imports(file)) {
            if (import.contains('package:') && import.contains('/src/')) {
              final relative = file.path.replaceFirst('$root/', '');
              expect(
                allowlist.contains(relative),
                isTrue,
                reason:
                    '${file.path} importa package:.../src/ — debe aislarse '
                    'en un archivo allowlist (p. ej. sembast_codec.dart)',
              );
            }
          }
        }
      },
    );

    test('Rule 14: core/ NO importa features/ ni app/', () {
      for (final file in _dartFilesIn(Directory('lib/core'))) {
        for (final import in _imports(file)) {
          expect(
            import.contains('/features/'),
            isFalse,
            reason:
                '${file.path} importa features/ — core/ debe ser '
                'feature-agnóstico',
          );
          expect(
            import.contains('/app/'),
            isFalse,
            reason:
                '${file.path} importa app/ — core/ no conoce la '
                'composition root',
          );
        }
      }
    });

    test(
      'Rule 15: presentation/ NO importa infrastructure/, core/, ni app/',
      () {
        for (final feature in _featureDirs()) {
          for (final file in _dartFilesIn(
            Directory('${feature.path}/presentation'),
          )) {
            for (final import in _imports(file)) {
              for (final forbidden in ['infrastructure/', '/core/', '/app/']) {
                expect(
                  import.contains(forbidden),
                  isFalse,
                  reason:
                      '${file.path} importa $forbidden — presentation '
                      'solo depende de di/ y shared/',
                );
              }
            }
          }
        }
      },
    );

    test(
      'Rule 16: Sin acceso estático a AppEnvironment fuera de core/config/',
      () {
        final dartFiles = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  !f.path.contains('.freezed.dart') &&
                  !f.path.contains('.g.dart'),
            );

        for (final file in dartFiles) {
          if (file.path.contains('lib/core/config/')) continue;
          expect(
            file.readAsStringSync().contains(RegExp(r'AppEnvironment\.\w')),
            isFalse,
            reason:
                '${file.path} usa un miembro estático de AppEnvironment — la '
                'configuración se lee via environmentProvider o se inyecta la '
                'instancia concreta (const DevEnvironment()...)',
          );
        }
      },
    );

    test(
      'Rule 17a: todo método público de domain/repositories/* devuelve Future<Result<...>>',
      () {
        for (final feature in _featureDirs()) {
          final repoDir = Directory('${feature.path}/domain/repositories');
          if (!repoDir.existsSync()) continue;
          for (final file in _dartFilesIn(repoDir)) {
            final content = file.readAsStringSync();
            final methodRegex = RegExp(r'Future<[^>]*>\s+(\w+)\s*\(');
            for (final match in methodRegex.allMatches(content)) {
              final returnType = match.group(0)!.split(RegExp(r'\s+')).first;
              expect(
                returnType.startsWith('Future<Result<'),
                isTrue,
                reason:
                    '${file.path} — ${match.group(1)} debe devolver '
                    'Future<Result<...>> (política canónica de Result). '
                    'Encontrado: $returnType',
              );
            }
          }
        }
      },
    );

    test(
      'Rule 17b: todo usecase implementa IUseCase<In, Out> (contrato uniforme)',
      () {
        for (final feature in _featureDirs()) {
          final usecaseDir = Directory('${feature.path}/domain/usecases');
          if (!usecaseDir.existsSync()) continue;
          for (final file in _dartFilesIn(usecaseDir)) {
            final content = file.readAsStringSync();
            final classRegex = RegExp(r'class\s+\w+UseCase\b');
            for (final match in classRegex.allMatches(content)) {
              final declEnd = content.indexOf('{', match.start);
              final declaration = content.substring(match.start, declEnd);
              expect(
                declaration.contains('implements IUseCase<'),
                isTrue,
                reason:
                    '${file.path} — ${match.group(0)} debe implementar '
                    'IUseCase<In, Out>',
              );
            }
          }
        }
      },
    );

    test('Rule 18: usecases dependen de otros usecases via IUseCase<In, Out>, '
        'nunca de clases concretas (DIP)', () {
      for (final feature in _featureDirs()) {
        final usecaseDir = Directory('${feature.path}/domain/usecases');
        if (!usecaseDir.existsSync()) continue;
        for (final file in _dartFilesIn(usecaseDir)) {
          for (final line in file.readAsStringSync().split('\n')) {
            final trimmed = line.trimLeft();
            if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
            final fieldRegex = RegExp(r'final\s+(\w*UseCase)\b');
            for (final match in fieldRegex.allMatches(line)) {
              final type = match.group(1)!;
              expect(
                type == 'IUseCase',
                isTrue,
                reason:
                    '${file.path} — campo tipado como "$type"; los '
                    'usecases deben depender de IUseCase<In, Out>, nunca de '
                    'una clase concreta (DIP, Rule 18). Línea: ${line.trim()}',
              );
            }
          }
        }
      }
    });

    test('Rule 19a: cada interfaz de domain/repositories y domain/datasources '
        'tiene exactamente 1 implementación concreta en infrastructure/ '
        '(1 contrato = 1 impl)', () {
      for (final feature in _featureDirs()) {
        final featureName = feature.path.split('/').last;
        final infraDir = Directory('${feature.path}/infrastructure');
        if (!infraDir.existsSync()) continue;
        final infraFiles = _dartFilesIn(infraDir);

        for (final contractsDir in ['repositories', 'datasources']) {
          final contractsPath = '${feature.path}/domain/$contractsDir';
          final contractsDirObj = Directory(contractsPath);
          if (!contractsDirObj.existsSync()) continue;

          for (final file in _dartFilesIn(contractsDirObj)) {
            final interfaceRegex = RegExp(
              r'(?:abstract\s+)?(?:interface\s+)?class\s+(I\w+)',
            );
            for (final match in interfaceRegex.allMatches(
              file.readAsStringSync(),
            )) {
              final iface = match.group(1)!;
              final implRegex = RegExp(
                'class\\s+(\\w+)(?:\\s+extends\\s+[A-Za-z0-9_<>, ]+)?'
                '\\s+implements\\s+[^{]*\\b$iface\\b',
              );
              final impls = <String>{};
              for (final infraFile in infraFiles) {
                for (final implMatch in implRegex.allMatches(
                  infraFile.readAsStringSync(),
                )) {
                  impls.add(implMatch.group(1)!);
                }
              }
              expect(
                impls.length,
                1,
                reason:
                    '$iface ($contractsDir del feature $featureName) debe '
                    'tener exactamente 1 implementación concreta en '
                    'infrastructure/ (Rule 19a). Encontradas: $impls',
              );
            }
          }
        }
      }
    });

    test('Rule 19b: ninguna clase concreta en infrastructure/ implementa >1 '
        'contrato de dominio (1 clase = 1 contrato)', () {
      for (final feature in _featureDirs()) {
        final infraDir = Directory('${feature.path}/infrastructure');
        if (!infraDir.existsSync()) continue;
        for (final file in _dartFilesIn(infraDir)) {
          final content = file.readAsStringSync();
          final classRegex = RegExp(
            r'class\s+(\w+)(?:\s+extends\s+\w+)?\s+implements\s+([^{]+)\{',
          );
          for (final match in classRegex.allMatches(content)) {
            final impls = match
                .group(2)!
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            expect(
              impls.length,
              1,
              reason:
                  '${file.path} — ${match.group(1)} implementa '
                  '${impls.join(", ")}: se exige 1 clase = 1 contrato '
                  '(Rule 19b)',
            );
          }
        }
      }
    });

    test('Rule 20: core/database/tables/ separa DI de implementación — solo '
        'los archivos *_providers.dart declaran providers de Riverpod', () {
      final tablesDir = Directory('lib/core/database/tables');
      if (!tablesDir.existsSync()) return;
      for (final file in _dartFilesIn(tablesDir)) {
        if (file.path.endsWith('_providers.dart')) continue;
        final content = file.readAsStringSync();
        expect(
          content.contains('Provider<'),
          isFalse,
          reason:
              '${file.path} declara un provider — los providers viven en '
              'archivos *_providers.dart dedicados (DI separado de la '
              'implementación, Rule 20)',
        );
        expect(
          content.contains('package:flutter_riverpod/'),
          isFalse,
          reason:
              '${file.path} importa riverpod — los providers viven en '
              'archivos *_providers.dart dedicados (Rule 20)',
        );
      }
    });

    test('Rule 21: go_router está confinado a lib/app/ (composition root) — '
        'features usan IAppNavigator, nunca el paquete', () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.contains('.g.dart') &&
                !f.path.contains('.freezed.dart'),
          );

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (content.contains('package:go_router/')) {
          expect(
            file.path.contains('lib/app/'),
            isTrue,
            reason:
                '${file.path} importa go_router — go_router está '
                'confinado a lib/app/ (composition root). Features navegan '
                'via IAppNavigator (appNavigatorProvider).',
          );
        }
      }
    });

    test(
      'Rule 22: shared/error solo se importa via el barrel _error.lib.dart',
      () {
        final dartFiles = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  !f.path.contains('.g.dart') &&
                  !f.path.contains('.freezed.dart'),
            );

        for (final file in dartFiles) {
          for (final import in _imports(file)) {
            final isRawErrorImport =
                import.contains('shared/error/') &&
                !import.contains('_error.lib.dart');
            expect(
              isRawErrorImport,
              isFalse,
              reason:
                  '${file.path} importa shared/error directamente — '
                  'siempre usar el barrel _error.lib.dart (LEARN.md barrel rule)',
            );
          }
        }
      },
    );

    test('Rule 23: shared/exceptions solo se importa via el barrel '
        '_exceptions.lib.dart', () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.contains('.g.dart') &&
                !f.path.contains('.freezed.dart'),
          );

      for (final file in dartFiles) {
        for (final import in _imports(file)) {
          final isRawExceptionsImport =
              import.contains('shared/exceptions/') &&
              !import.contains('_exceptions.lib.dart');
          expect(
            isRawExceptionsImport,
            isFalse,
            reason:
                '${file.path} importa shared/exceptions directamente — '
                'siempre usar el barrel _exceptions.lib.dart',
          );
        }
      }
    });

    test('Rule 24: shared/functions/ se importa directo — sin barrel '
        '_functions.lib.dart', () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.contains('.g.dart') &&
                !f.path.contains('.freezed.dart'),
          );

      for (final file in dartFiles) {
        for (final import in _imports(file)) {
          expect(
            import.contains('shared/functions/_functions.lib.dart'),
            isFalse,
            reason:
                '${file.path} importa un barrel de shared/functions — '
                'importar online_first.dart directamente (igual que '
                'shared/router/)',
          );
        }
      }
    });

    test('Rule 25: shared/functions/online_first.dart importa SOLO shared/ '
        '(Shared Kernel puro)', () {
      final file = File('lib/shared/functions/online_first.dart');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'online_first.dart debe existir como helper online-first',
      );

      for (final import in _imports(file)) {
        for (final forbidden in [
          'core/',
          'app/',
          'features/',
          'l10n/',
          'design_system/',
          'package:flutter/',
        ]) {
          expect(
            import.contains(forbidden),
            isFalse,
            reason:
                '${file.path} importa $forbidden — shared/ no puede '
                'depender de capas concretas ni Flutter',
          );
        }
        if (import.contains('package:clean_architecture_sdd_harness/')) {
          expect(
            import.contains('package:clean_architecture_sdd_harness/shared/'),
            isTrue,
            reason: '${file.path} solo puede importar de shared/',
          );
        }
      }
    });

    test('Rule 26: shared/interfaces solo se importa via el barrel '
        '_interfaces.lib.dart (sin re-exports fuera de la carpeta)', () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.contains('.g.dart') &&
                !f.path.contains('.freezed.dart'),
          );

      for (final file in dartFiles) {
        for (final import in _imports(file)) {
          final isRawInterfaceImport =
              import.contains('shared/interfaces/') &&
              !import.contains('_interfaces.lib.dart');
          expect(
            isRawInterfaceImport,
            isFalse,
            reason:
                '${file.path} importa shared/interfaces directamente — '
                'siempre usar el barrel _interfaces.lib.dart',
          );
        }

        if (!file.path.contains('lib/shared/interfaces/')) {
          for (final line in file.readAsStringSync().split('\n')) {
            final trimmed = line.trimLeft();
            if (trimmed.startsWith('export') &&
                trimmed.contains('shared/interfaces/')) {
              fail(
                '${file.path} re-exporta shared/interfaces — los barrels '
                'externos no deben re-exportar interfaces del Shared Kernel',
              );
            }
          }
        }
      }
    });

    test(
      'Barrel convention: _*.lib.dart son pure-export (sin library; ni part)',
      () {
        final barrels = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.lib.dart'))
            .toList();

        expect(
          barrels,
          isNotEmpty,
          reason: 'se espera al menos un barrel _*.lib.dart',
        );

        for (final barrel in barrels) {
          final content = barrel.readAsStringSync();
          expect(
            content.contains('library;'),
            isFalse,
            reason:
                '${barrel.path} no debe declarar library; — los barrels '
                'son pure-export (convención del repo, MD/APP_BARREL_PATTERN.md)',
          );
          expect(
            RegExp(r'^part ', multiLine: true).hasMatch(content),
            isFalse,
            reason:
                '${barrel.path} no debe usar part — los barrels '
                'centralizan con export (convención del repo)',
          );
          expect(
            content.trimLeft().startsWith('export'),
            isTrue,
            reason: '${barrel.path} debe comenzar con export',
          );
        }
      },
    );

    test('Rule 27: app/ NO re-exporta símbolos de features/ (la composition '
        'root importa features explícitamente, sin re-exports ocultos)', () {
      for (final file in _dartFilesIn(Directory('lib/app'))) {
        for (final line in file.readAsStringSync().split('\n')) {
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('export') && trimmed.contains('features/')) {
            fail(
              '${file.path} re-exporta features/ — la composition root '
              'debe importar los símbolos de features explícitamente; los '
              're-exports crean dependencias ocultas/transitivas. '
              'Línea: $trimmed',
            );
          }
        }
      }
    });

    test('Rule 28: dependencias inyectadas por constructor (I*, VoidCallback, '
        'Function()) deben ser campos privados (_campo)', () {
      for (final file in _dartFilesIn(Directory('lib'))) {
        for (final line in file.readAsStringSync().split('\n')) {
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
          final fieldRegex = RegExp(
            r'final\s+(I[A-Z][A-Za-z0-9]*(?:<[^;]*>)?|VoidCallback|Future<String\?> Function\(\))\s+[a-z]\w*\s*;',
          );
          final match = fieldRegex.firstMatch(line);
          expect(
            match,
            isNull,
            reason:
                '${file.path} — dependencia inyectada pública: '
                '${line.trim()}. Los campos inyectados por constructor deben '
                'ser privados (_campo); el parámetro nombrado público se '
                'deriva del initializing formal (this._x → x).',
          );
        }
      }
    });

    test('Rule 29: ningún *.freezed.dart / *.g.dart queda huérfano — su fuente '
        'part-of debe existir y declararlo como part', () {
      final orphans = <String>[];
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        final path = file.path;
        if (!path.endsWith('.freezed.dart') && !path.endsWith('.g.dart')) {
          continue;
        }
        final partOf = file
            .readAsStringSync()
            .split('\n')
            .map((l) => l.trim())
            .firstWhere((l) => l.startsWith('part of '), orElse: () => '');
        if (partOf.isEmpty) {
          orphans.add('$path — no declara "part of"');
          continue;
        }
        final target = partOf
            .replaceFirst('part of ', '')
            .replaceAll("'", '')
            .replaceAll(';', '')
            .trim();
        final source = File('${file.parent.path}/$target');
        if (!source.existsSync()) {
          orphans.add('$path → fuente part-of faltante: $target');
          continue;
        }
        final generatedName = path.split('/').last;
        if (!source.readAsStringSync().contains("part '$generatedName'")) {
          orphans.add('$path → ${source.path} no lo declara como part');
        }
      }
      expect(
        orphans,
        isEmpty,
        reason: 'Archivos generados huérfanos:\n${orphans.join('\n')}',
      );
    });
  });
}
