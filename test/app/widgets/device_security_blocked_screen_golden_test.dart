@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:clean_architecture_sdd_harness/app/widgets/device_security_blocked_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

Widget _buildScreen() {
  return MaterialApp(
    theme: ThemeData(fontFamily: 'Roboto'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const DeviceSecurityBlockedScreen(),
  );
}

void main() {
  testGoldens('DeviceSecurityBlockedScreen golden test', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    await expectLater(
      find.byType(DeviceSecurityBlockedScreen),
      matchesGoldenFile('goldens/device_security_blocked_screen.png'),
    );
  });
}
