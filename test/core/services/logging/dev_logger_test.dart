import 'package:clean_architecture_sdd_harness/core/services/logging/dev_logger.dart';
import 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DevLogger is callable and does not throw', () {
    const logger = DevLogger();
    logger.info('hello');
    logger.error(
      'boom',
      technicalMessage: 'details',
      stackTrace: StackTrace.current,
    );
  });

  test('loggerProvider exposes an ILogger', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final logger = container.read(loggerProvider);

    expect(logger, isA<ILogger>());
  });
}
