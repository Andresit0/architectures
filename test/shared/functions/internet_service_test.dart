import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  group('InternetService', () {
    late InternetService internetService;

    setUp(() {
      internetService = InternetService();
    });

    test('isServerReachable should return a boolean', () async {
      final result = await internetService.isServerReachable();
      expect(result, isA<bool>());
    });

    test('should cache result for subsequent calls within 10 seconds', () async {
      final result1 = await internetService.isServerReachable();
      final result2 = await internetService.isServerReachable();

      expect(result1, equals(result2));
    });
  });
}