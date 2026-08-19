import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter/services.dart';

class AppInitializer {
  static Future<Result<void>> checkJailbreak({
    required IJailbreakDetectionWrapper detection,
  }) {
    return guard(() async {
      if (await detection.isJailbroken()) {
        throw const DeviceSecurityException();
      }
    });
  }

  static void configurePlatform() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
