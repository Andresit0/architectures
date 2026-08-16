import 'dart:developer';

import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class DevLogger implements ILogger {
  const DevLogger();

  @override
  void info(String message, {String? technicalMessage}) {
    log(message, name: 'INFO', error: technicalMessage);
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      name: 'ERROR',
      error: technicalMessage,
      stackTrace: stackTrace,
    );
  }
}
