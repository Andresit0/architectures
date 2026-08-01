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
      expect(workflow['jobs']['analyze']['runs-on'], 'ubuntu-latest',
          reason: 'Analyze must run on Linux to keep macOS usage minimal');
      expect(workflow['jobs']['test']['runs-on'], 'ubuntu-latest',
          reason: 'Test must run on Linux to keep macOS usage minimal');
    });

    test('Test Goldens runs on Linux (ubuntu-latest)', () {
      expect(workflow['jobs']['test-goldens']['runs-on'], 'ubuntu-latest',
          reason: 'Test Goldens must run on Linux (cross-platform goldens)');
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
        expect(content.contains("@Tags(['golden'])"), isTrue,
            reason: '${file.path} must declare @Tags([\'golden\']) so it runs '
                'only in the tagged Test Goldens job, never masked in Test');
      }
    });

    test('Build jobs do NOT depend on Test (no masking)', () {
      for (final jobName in ['build-ios', 'build-android', 'test-goldens']) {
        final needs = workflow['jobs'][jobName]['needs'] as List?;
        expect(needs?.contains('test'), isFalse,
            reason: '$jobName must not need test — '
                'a build that depends on tests passing masks failures');
        expect(needs?.contains('analyze'), isTrue,
            reason: '$jobName should depend on analyze');
      }
    });

    test('macOS usage is minimal (<= 2 jobs)', () {
      final macJobs = workflow['jobs'].entries.where((entry) {
        final job = entry.value as Map;
        return job['runs-on'] == 'macos-latest';
      }).toList();

      expect(macJobs.length, lessThanOrEqualTo(2),
          reason: 'Only essential jobs may run on macOS (Build iOS). '
              'Currently: ${macJobs.map((e) => e.key).toList()}');
    });
  });
}
