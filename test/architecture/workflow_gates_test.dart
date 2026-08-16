import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Guards against CI workflow regressions that mask real failures.
///
/// Runs inside the `Test` job (no `golden` tag) so a violation blocks the
/// merge queue on every PR.
void main() {
  const workflowPath = '.github/workflows/ci.yml';

  late Map workflow;
  setUpAll(() {
    final raw = File(workflowPath).readAsStringSync();
    workflow = Map<dynamic, dynamic>.from(loadYaml(raw));
  });

  group('Workflow anti-masking gates', () {
    test('Analyze and Test run on Linux (ubuntu-latest)', () {
      expect(
        workflow['jobs']['analyze']['runs-on'],
        'ubuntu-latest',
        reason: 'Analyze must run on Linux to keep macOS usage minimal',
      );
      expect(
        workflow['jobs']['test']['runs-on'],
        'ubuntu-latest',
        reason: 'Test must run on Linux to keep macOS usage minimal',
      );
    });

    test('Test Goldens runs on Linux (ubuntu-latest)', () {
      expect(
        workflow['jobs']['test-goldens']['runs-on'],
        'ubuntu-latest',
        reason: 'Test Goldens must run on Linux (cross-platform goldens)',
      );
    });

    test('Golden tests are tagged with golden', () {
      final files = Directory('test')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('_golden_test.dart'))
          .toList();

      expect(files, isNotEmpty, reason: 'expected at least one golden test');

      for (final file in files) {
        final content = file.readAsStringSync();
        expect(
          content.contains("@Tags(['golden'])"),
          isTrue,
          reason:
              '${file.path} must declare @Tags([\'golden\']) so it runs '
              'only in the tagged Test Goldens job, never masked in Test',
        );
      }
    });

    test('Build jobs do NOT depend on Test (no masking)', () {
      for (final jobName in ['build-ios', 'build-android', 'test-goldens']) {
        final needs = workflow['jobs'][jobName]['needs'] as List?;
        expect(
          needs?.contains('test'),
          isFalse,
          reason:
              '$jobName must not need test — '
              'a build that depends on tests passing masks failures',
        );
        expect(
          needs?.contains('analyze'),
          isTrue,
          reason: '$jobName should depend on analyze',
        );
      }
    });

    test('macOS usage is minimal (<= 2 jobs)', () {
      final macJobs = workflow['jobs'].entries.where((entry) {
        final job = entry.value as Map;
        return job['runs-on'] == 'macos-latest';
      }).toList();

      expect(
        macJobs.length,
        lessThanOrEqualTo(2),
        reason:
            'Only essential jobs may run on macOS (Build iOS). '
            'Currently: ${macJobs.map((e) => e.key).toList()}',
      );
    });

    test('A secret-scanning job exists (gitleaks)', () {
      final job = workflow['jobs']['gitleaks'] as Map?;
      expect(
        job,
        isNotNull,
        reason:
            'a gitleaks job must exist — removing the secret scan '
            'gate would silently disable leak detection',
      );
      expect(
        job?['runs-on'],
        'ubuntu-latest',
        reason: 'gitleaks must run on Linux (free runner)',
      );
    });

    test('Analyze enforces dart format as a gate', () {
      final steps = workflow['jobs']['analyze']['steps'] as List;
      final runCommands = steps
          .whereType<Map>()
          .map((s) => s['run'] as String?)
          .whereType<String>()
          .toList();
      final formatStep = runCommands.where((c) => c.contains('dart format'));
      expect(
        formatStep,
        isNotEmpty,
        reason:
            'Analyze must run dart format --set-exit-if-changed so an '
            'unformatted diff fails CI instead of reaching review',
      );
      expect(
        formatStep.first.contains('--output=none') &&
            formatStep.first.contains('--set-exit-if-changed'),
        isTrue,
        reason:
            'the format gate must be non-mutating (--output=none) and '
            'exit non-zero on diff (--set-exit-if-changed)',
      );
    });

    test('An Integration job exists and fails on any test failure', () {
      final job = workflow['jobs']['integration'] as Map?;
      expect(
        job,
        isNotNull,
        reason:
            'PR 1 must add an Integration job executing integration_test '
            'on a controlled device runner (D6)',
      );
      expect(
        job?['runs-on'],
        'macos-latest',
        reason: 'Integration must run on a controlled macOS/device runner',
      );
      final steps = job?['steps'] as List? ?? const [];
      final runCommands = steps
          .whereType<Map>()
          .map((s) => s['run'] as String?)
          .whereType<String>()
          .join('\n');
      expect(
        runCommands.contains('set -euo pipefail'),
        isTrue,
        reason:
            'Integration must fail hard; a job that always passes without '
            'running the tests masks failures',
      );
      expect(
        runCommands.contains('flutter test'),
        isTrue,
        reason: 'Integration must execute the integration tests',
      );
    });

    test('Test and Test Goldens jobs keep the tag flags', () {
      final runs = <String>[];
      for (final jobName in ['test', 'test-goldens']) {
        final steps = workflow['jobs'][jobName]['steps'] as List;
        for (final step in steps) {
          final run = (step as Map)['run'] as String?;
          if (run != null && run.contains('flutter test')) {
            runs.add('$jobName: $run');
          }
        }
      }

      expect(
        runs.any(
          (r) => r.startsWith('test:') && r.contains('--exclude-tags golden'),
        ),
        isTrue,
        reason:
            'Test must keep --exclude-tags golden so the coverage run '
            'never silently executes golden tests',
      );
      expect(
        runs.any(
          (r) => r.startsWith('test-goldens:') && r.contains('--tags golden'),
        ),
        isTrue,
        reason: 'Test Goldens must keep --tags golden so goldens actually run',
      );
    });
  });
}
