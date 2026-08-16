@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:clean_architecture_sdd_harness/app/widgets/app_error_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

Widget _buildScreen() {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppErrorScreen(),
    ),
  );
}

void main() {
  testGoldens('AppErrorScreen golden test — 404 without error detail', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    await expectLater(
      find.byType(AppErrorScreen),
      matchesGoldenFile('goldens/app_error_screen.png'),
    );
  });
}
