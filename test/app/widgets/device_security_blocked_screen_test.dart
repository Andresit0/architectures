import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/app/widgets/device_security_blocked_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations_en.dart';

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DeviceSecurityBlockedScreen(),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the security icon and the localized title', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.byIcon(Icons.gpp_bad_outlined), findsOneWidget);
    expect(find.text(AppLocalizationsEn().deviceSecurityTitle), findsOneWidget);
  });

  testWidgets('renders the localized security message', (tester) async {
    await _pumpScreen(tester);

    expect(
      find.text(AppLocalizationsEn().deviceSecurityMessage),
      findsOneWidget,
    );
  });

  testWidgets('exposes no navigation and no internal error details', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.byType(ButtonStyleButton), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
  });
}
