import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/app/widgets/app_error_screen.dart';
import 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations_en.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

class _FakeNavigator implements IAppNavigator {
  final List<AppRoute> gone = [];

  @override
  void go(AppRoute route, {Object? extra}) => gone.add(route);

  @override
  Future<void> push(AppRoute route, {Object? extra}) async {}
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeNavigator navigator,
  Object? error,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appNavigatorProvider.overrideWith((ref) => navigator)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppErrorScreen(error: error),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the 404 icon and the localized title', (tester) async {
    final navigator = _FakeNavigator();
    await _pumpScreen(tester, navigator: navigator);

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text(AppLocalizationsEn().routeNotFound), findsOneWidget);
  });

  testWidgets('renders the localized go home button', (tester) async {
    final navigator = _FakeNavigator();
    await _pumpScreen(tester, navigator: navigator);

    expect(find.text(AppLocalizationsEn().routeNotFoundGoHome), findsOneWidget);
  });

  testWidgets('shows the error detail when one is provided', (tester) async {
    final navigator = _FakeNavigator();
    await _pumpScreen(
      tester,
      navigator: navigator,
      error: Exception('no location found for /unknown'),
    );

    expect(
      find.text('Exception: no location found for /unknown'),
      findsOneWidget,
    );
  });

  testWidgets('does not show an error detail when none is provided', (
    tester,
  ) async {
    final navigator = _FakeNavigator();
    await _pumpScreen(tester, navigator: navigator);

    expect(find.byType(SelectableText), findsNothing);
  });

  testWidgets('navigates to login through the app navigator seam on tap', (
    tester,
  ) async {
    final navigator = _FakeNavigator();
    await _pumpScreen(tester, navigator: navigator);

    await tester.tap(find.text(AppLocalizationsEn().routeNotFoundGoHome));
    await tester.pump();

    expect(navigator.gone, [AppRoute.login]);
  });
}
