import 'package:clean_architecture_sdd_harness/shared/exceptions/device_security_exception.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter/services.dart';

class AppInitializer {
  static Future<void> checkJailbreak({
    required IJailbreakDetectionWrapper detection,
  }) async {
    if (await detection.isJailbroken()) {
      throw DeviceSecurityException();
    }
  }

  static void configurePlatform() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
