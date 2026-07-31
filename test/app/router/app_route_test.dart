import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/app/router/app_route.dart';

void main() {
  group('AppRoute.fromPath', () {
    test('fromPath returns correct route for login path', () {
      final result = AppRoute.fromPath('/');
      expect(result, AppRoute.login);
    });

    test('fromPath returns correct route for clinicalHistory path', () {
      final result = AppRoute.fromPath('/clinical-history');
      expect(result, AppRoute.clinicalHistory);
    });

    test('fromPath returns null for unknown path', () {
      final result = AppRoute.fromPath('/unknown');
      expect(result, isNull);
    });
  });
}
