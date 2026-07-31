import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/remember_me_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/login_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial) : super();

  final AuthState _initial;
  bool loginCalled = false;

  @override
  AuthState build() => _initial;

  @override
  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    loginCalled = true;
  }
}

ProviderContainer? _lastContainer;

Widget _buildScreen(AuthState state) {
  _lastContainer?.dispose();
  _lastContainer = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(state)),
    ],
  );
  return UncontrolledProviderScope(
    container: _lastContainer!,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginScreen(),
    ),
  );
}

void main() {
  tearDown(() {
    _lastContainer?.dispose();
    _lastContainer = null;
  });
  testWidgets('login_screen_shows_email_and_password_fields', (tester) async {
    await tester.pumpWidget(_buildScreen(const AuthInitial()));
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('login_screen_shows_remember_me_checkbox', (tester) async {
    await tester.pumpWidget(_buildScreen(const AuthInitial()));
    await tester.pump();

    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
  });

  testWidgets('login_screen_checkbox_toggles_remember_me_via_riverpod', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier(const AuthInitial())),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(container.read(rememberMeProvider), isFalse);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(container.read(rememberMeProvider), isTrue);
  });

  testWidgets('login_screen_shows_login_button', (tester) async {
    await tester.pumpWidget(_buildScreen(const AuthInitial()));
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('login_screen_shows_loading_indicator_during_loading', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(const AuthLoading()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('login_screen_shows_loading_indicator_instead_of_form', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(const AuthLoading()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('login_screen_shows_form_when_not_loading', (tester) async {
    await tester.pumpWidget(
      _buildScreen(const AuthFailure(NetworkError(''))),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('login_screen_shows_form_without_loading_when_initial', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(const AuthInitial()));
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('login_screen_toggles_password_visibility', (tester) async {
    await tester.pumpWidget(_buildScreen(const AuthInitial()));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('login_button_triggers_login_on_tap', (tester) async {
    final notifier = _FakeAuthNotifier(const AuthInitial());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: ProviderContainer(
          overrides: [
            authProvider.overrideWith(() => notifier),
          ],
        ),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'test@test.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(notifier.loginCalled, isTrue);
  });

  testWidgets('login_screen_shows_error_snackbar_on_auth_failure_transition', (
    tester,
  ) async {
    final notifier = _FakeAuthNotifier(const AuthInitial());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: ProviderContainer(
          overrides: [
            authProvider.overrideWith(() => notifier),
          ],
        ),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    notifier.state = const AuthFailure(NetworkError(''));
    await tester.pump();

    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
