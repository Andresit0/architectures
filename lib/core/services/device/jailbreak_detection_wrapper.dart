import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

abstract interface class IJailbreakDetectionWrapper {
  Future<bool> isJailbroken();
  Future<bool> isDeveloperModeEnabled();
}

class JailbreakDetectionWrapper implements IJailbreakDetectionWrapper {

  JailbreakDetectionWrapper({
    Future<bool> Function()? jailbrokenFn,
    Future<bool> Function()? developerModeFn,
  })  : _jailbrokenFn = jailbrokenFn ?? (() => FlutterJailbreakDetection.jailbroken),
        _developerModeFn =
            developerModeFn ?? (() => FlutterJailbreakDetection.developerMode);
  final Future<bool> Function() _jailbrokenFn;
  final Future<bool> Function() _developerModeFn;

  @override
  Future<bool> isJailbroken() => _jailbrokenFn();

  @override
  Future<bool> isDeveloperModeEnabled() => _developerModeFn();
}
