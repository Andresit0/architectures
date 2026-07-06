import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  group('CpLogger', () {
    test('should implement ICpLogger interface', () {
      const logger = CpLogger();
      expect(logger, isA<ICpLogger>());
    });

    test('info does not throw', () {
      const logger = CpLogger();
      expect(() => logger.info('test message'), returnsNormally);
    });

    test('error does not throw', () {
      const logger = CpLogger();
      expect(() => logger.error('test error'), returnsNormally);
    });

    test('error with stack trace does not throw', () {
      const logger = CpLogger();
      expect(
        () => logger.error('test error', StackTrace.current),
        returnsNormally,
      );
    });
  });
}