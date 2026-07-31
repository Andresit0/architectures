import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/core/network/utils/uri_utils.dart';

void main() {
  group('UriUtils.replacePathParams', () {
    test('replaces :id with value in path', () {
      final uri = Uri.parse('/patient/:id/history');
      final result = UriUtils.replacePathParams(uri, {'id': '42'});
      expect(result.path, '/patient/42/history');
    });

    test('returns same uri when pathParams is null', () {
      final uri = Uri.parse('/patient/42');
      expect(UriUtils.replacePathParams(uri, null), uri);
    });

    test('replaces multiple params', () {
      final uri = Uri.parse('/:org/:repo/issues');
      final result = UriUtils.replacePathParams(uri, {'org': 'flutter', 'repo': 'flutter'});
      expect(result.path, '/flutter/flutter/issues');
    });

    test('ignores extra pathParams keys not present in path', () {
      final uri = Uri.parse('/patient/42');
      final result = UriUtils.replacePathParams(uri, {'id': '1', 'extra': 'ignored'});
      expect(result.path, '/patient/42');
    });

    test('path without placeholders is unchanged', () {
      final uri = Uri.parse('/patients');
      final result = UriUtils.replacePathParams(uri, {'id': '1'});
      expect(result.path, '/patients');
    });
  });
}
