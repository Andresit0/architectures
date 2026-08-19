import 'package:clean_architecture_sdd_harness/features/auth/presentation/widgets/email_form_field.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/widgets/password_form_field.dart';
import 'package:clean_architecture_sdd_harness/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw StateError('Timed out waiting for $finder');
}

Future<void> _waitForAbsent(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isEmpty) return;
  }
  throw StateError('Timed out waiting for $finder to disappear');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture real app screenshots', (tester) async {
    app.main();

    final loginField = find.byType(EmailFormField);
    final historyTitle = find.text('Historial Clínico');
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    var onLogin = false;
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (loginField.evaluate().isNotEmpty) {
        onLogin = true;
        break;
      }
      if (historyTitle.evaluate().isNotEmpty) break;
    }

    if (onLogin) {
      await tester.pump(const Duration(seconds: 1));
      await binding.takeScreenshot('login_screen');

      await tester.enterText(loginField, 'test@example.com');
      await tester.enterText(find.byType(PasswordFormField), 'password123');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byType(ElevatedButton));
    }

    await _waitFor(tester, find.textContaining('Hospital Central'));
    await _waitForAbsent(tester, loginField);
    await tester.pump(const Duration(seconds: 1));
    await binding.takeScreenshot('clinical_history');

    await tester.tap(find.byIcon(Icons.biotech_outlined));
    await _waitFor(tester, find.text('Hemoglobina'));
    await _waitForAbsent(tester, historyTitle);
    await tester.pump(const Duration(seconds: 1));
    await binding.takeScreenshot('lab_results');
  });
}
