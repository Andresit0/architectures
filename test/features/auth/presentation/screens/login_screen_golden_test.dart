@Tags(['golden'])
library;

import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/remember_me_provider.dart';
import 'package:clean_architecture_sdd_harness/core/config/environment_provider.dart';
import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/login_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial) : super();

  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {}
}

class _FakeRememberMeNotifier extends RememberMeNotifier {
  @override
  bool build() => false;

  @override
  void set(bool value) {}
}

Widget _buildScreen(AuthState state) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(state)),
      rememberMeProvider.overrideWith(_FakeRememberMeNotifier.new),
      environmentProvider.overrideWith((ref) => const ProductionEnvironment()),
    ],
    child: MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginScreen(),
    ),
  );
}

void main() {
  testGoldens('LoginScreen golden test — initial state', (tester) async {
    await tester.pumpWidget(_buildScreen(const AuthInitial()));
    await tester.pump();

    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_screen_initial.png'),
    );
  });

  testGoldens('LoginScreen golden test — loading state', (tester) async {
    await tester.pumpWidget(_buildScreen(const AuthLoading()));
    await tester.pump();

    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_screen_loading.png'),
    );
  });
}
