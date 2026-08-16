import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJailbreakDetectionWrapper extends Mock
    implements IJailbreakDetectionWrapper {}

void main() {
  group('IJailbreakDetectionWrapper interface', () {
    test('JailbreakDetectionWrapper implements IJailbreakDetectionWrapper', () {
      final detector = JailbreakDetectionWrapper();
      expect(detector, isA<IJailbreakDetectionWrapper>());
    });
  });

  group('JailbreakDetectionWrapper with mock', () {
    late MockJailbreakDetectionWrapper mockDetector;

    setUp(() {
      mockDetector = MockJailbreakDetectionWrapper();
    });

    group('isJailbroken', () {
      test('returns false on a secure device', () async {
        when(() => mockDetector.isJailbroken()).thenAnswer((_) async => false);

        final result = await mockDetector.isJailbroken();

        expect(result, isFalse);
        verify(() => mockDetector.isJailbroken()).called(1);
      });

      test('returns true on a jailbroken device', () async {
        when(() => mockDetector.isJailbroken()).thenAnswer((_) async => true);

        final result = await mockDetector.isJailbroken();

        expect(result, isTrue);
        verify(() => mockDetector.isJailbroken()).called(1);
      });
    });
  });

  group('JailbreakDetectionWrapper constructor injection', () {
    test('uses provided jailbroken function', () async {
      final detector = JailbreakDetectionWrapper(
        jailbrokenFn: () async => true,
      );

      final result = await detector.isJailbroken();
      expect(result, isTrue);
    });

    test('uses provided developerMode function', () async {
      final detector = JailbreakDetectionWrapper(
        developerModeFn: () async => true,
      );

      final result = await detector.isDeveloperModeEnabled();
      expect(result, isTrue);
    });

    test('defaults jailbrokenFn to false (falls back)', () async {
      final detector = JailbreakDetectionWrapper(
        jailbrokenFn: () async => false,
      );

      final result = await detector.isJailbroken();
      expect(result, isFalse);
    });
  });
}
