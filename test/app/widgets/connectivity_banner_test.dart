import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/app/widgets/connectivity_banner.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations_en.dart';

Future<void> _pumpBanner(
  WidgetTester tester, {
  required Stream<bool> statusStream,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [internetStatusProvider.overrideWith((ref) => statusStream)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Column(
            children: [
              ConnectivityBanner(),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the banner when offline', (tester) async {
    await _pumpBanner(tester, statusStream: Stream.value(false));
    await tester.pump();

    expect(find.byType(ConnectivityBanner), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.text(AppLocalizationsEn().offlineBanner), findsOneWidget);
  });

  testWidgets('hides the banner when online', (tester) async {
    await _pumpBanner(tester, statusStream: Stream.value(true));
    await tester.pump();

    expect(find.byType(ConnectivityBanner), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsNothing);
  });

  testWidgets('defaults to online (no banner) until the stream emits', (
    tester,
  ) async {
    final controller = StreamController<bool>();
    addTearDown(controller.close);

    await _pumpBanner(tester, statusStream: controller.stream);

    expect(find.byIcon(Icons.wifi_off), findsNothing);

    controller.add(false);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });
}
