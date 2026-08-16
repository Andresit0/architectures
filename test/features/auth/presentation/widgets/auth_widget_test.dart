import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/login_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

class _FakeNotifier extends AuthNotifier {
  _FakeNotifier() : super();

  @override
  AuthState build() => const AuthInitial();
}

ProviderContainer _createContainer() => ProviderContainer(
  overrides: [authProvider.overrideWith(() => _FakeNotifier())],
);

Widget _buildTestApp(Widget child) {
  return UncontrolledProviderScope(
    container: _createContainer(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('LoginScreen form widgets', () {
    testWidgets('email_field_accepts_text_input', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('password_field_obscures_text_by_default', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final passwordField = textFields.firstWhere((tf) => tf.obscureText);
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('remember_me_checkbox_starts_unchecked', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('remember_me_checkbox_toggles_on_tap', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('email_field_has_email_keyboard_type', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('login_button_is_always_enabled_when_not_loading', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('email_field_shows_localized_error_when_empty', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('email_field_shows_localized_error_when_invalid', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'invalid');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('password_field_shows_localized_error_when_empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('password_field_shows_localized_error_when_too_short', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'abc');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });
}
