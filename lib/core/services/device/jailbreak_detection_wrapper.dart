import 'package:flutter_jailbreak_detection_plus/flutter_jailbreak_detection_plus.dart';

abstract interface class IJailbreakDetectionWrapper {
  Future<bool> isJailbroken();
  Future<bool> isDeveloperModeEnabled();
}

class JailbreakDetectionWrapper implements IJailbreakDetectionWrapper {
  JailbreakDetectionWrapper({
    Future<bool> Function()? jailbrokenFn,
    Future<bool> Function()? developerModeFn,
  }) : _jailbrokenFn =
           jailbrokenFn ?? (() => FlutterJailbreakDetectionPlus.jailbroken),
       _developerModeFn =
           developerModeFn ??
           (() => FlutterJailbreakDetectionPlus.developerMode);
  final Future<bool> Function() _jailbrokenFn;
  final Future<bool> Function() _developerModeFn;

  @override
  Future<bool> isJailbroken() => _jailbrokenFn();

  @override
  Future<bool> isDeveloperModeEnabled() => _developerModeFn();
}
