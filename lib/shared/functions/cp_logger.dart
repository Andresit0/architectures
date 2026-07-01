part of '_function.lib.dart';

abstract class ICpLogger {
  void error(String message, [StackTrace? st]);
  void info(String message);
}

class CpLogger implements ICpLogger {
  const CpLogger();

  @override
  void error(String message, [StackTrace? st]) {
    if (CustomConfigs.vars.isReleaseMode) return;
    try {
      _LoggerHolder.instance.e(message, null, st);
    } catch (_) {
      debugPrint(message);
      if (st != null) {
        debugPrintStack(stackTrace: st);
      }
    }
  }

  @override
  void info(String message) {
    if (CustomConfigs.vars.isReleaseMode) return;
    try {
      _LoggerHolder.instance.i(message);
    } catch (_) {
      debugPrint(message);
    }
  }
}

class _LoggerHolder {
  static final _LoggerHolder instance = _LoggerHolder._internal();

  late final Logger? _logger;

  _LoggerHolder._internal() {
    try {
      _logger = Logger();
    } catch (_) {
      _logger = null;
    }
  }

  void e(String message, [Object? error, StackTrace? st]) {
    try {
      final l = _logger;
      if (l != null) {
        l.e(message, error: error, stackTrace: st);
        return;
      }
    } catch (_) {}
    debugPrint(message);
    if (st != null) {
      debugPrintStack(stackTrace: st);
    }
  }

  void i(String message) {
    try {
      final l = _logger;
      if (l != null) {
        l.i(message);
        return;
      }
    } catch (_) {}
    debugPrint(message);
  }
}
