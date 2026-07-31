import 'package:clean_architecture_sdd_harness/app/app_initializer.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJailbreakDetection extends Mock implements IJailbreakDetectionWrapper {}

void main() {
  late MockJailbreakDetection mockDetection;

  setUp(() {
    mockDetection = MockJailbreakDetection();
  });

  group('AppInitializer.configurePlatform', () {
    testWidgets('configures portrait orientation without error', (tester) async {
      await tester.pump();
      expect(
        () => AppInitializer.configurePlatform(),
        returnsNormally,
      );
    });
  });

  group('AppInitializer.checkJailbreak', () {
    test('returns normally when device is secure', () async {
      when(() => mockDetection.isJailbroken()).thenAnswer((_) async => false);

      await AppInitializer.checkJailbreak(detection: mockDetection);

      verify(() => mockDetection.isJailbroken()).called(1);
    });

    test('throws DeviceSecurityException when device is jailbroken', () async {
      when(() => mockDetection.isJailbroken()).thenAnswer((_) async => true);

      await expectLater(
        AppInitializer.checkJailbreak(detection: mockDetection),
        throwsA(isA<DeviceSecurityException>()),
      );

      verify(() => mockDetection.isJailbroken()).called(1);
    });
  });
}
