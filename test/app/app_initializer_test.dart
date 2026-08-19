import 'package:clean_architecture_sdd_harness/app/app_initializer.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJailbreakDetection extends Mock
    implements IJailbreakDetectionWrapper {}

void main() {
  late MockJailbreakDetection mockDetection;

  setUp(() {
    mockDetection = MockJailbreakDetection();
  });

  group('AppInitializer.configurePlatform', () {
    testWidgets('configures portrait orientation without error', (
      tester,
    ) async {
      await tester.pump();
      expect(() => AppInitializer.configurePlatform(), returnsNormally);
    });
  });

  group('AppInitializer.checkJailbreak', () {
    test('returns Success when device is secure', () async {
      when(() => mockDetection.isJailbroken()).thenAnswer((_) async => false);

      final result = await AppInitializer.checkJailbreak(
        detection: mockDetection,
      );

      expect(result.isSuccess, isTrue);
      verify(() => mockDetection.isJailbroken()).called(1);
    });

    test(
      'returns Failure<DeviceSecurityError> when device is jailbroken',
      () async {
        when(() => mockDetection.isJailbroken()).thenAnswer((_) async => true);

        final result = await AppInitializer.checkJailbreak(
          detection: mockDetection,
        );

        expect(result, isA<Failure<void>>());
        expect((result as Failure<void>).error, isA<DeviceSecurityError>());
        verify(() => mockDetection.isJailbroken()).called(1);
      },
    );
  });
}
