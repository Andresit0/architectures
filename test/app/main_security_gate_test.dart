import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/app/di/auth/auth_observer_provider.dart';
import 'package:clean_architecture_sdd_harness/app/widgets/device_security_blocked_screen.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/i_authentication_observer.dart';
import 'package:clean_architecture_sdd_harness/core/services/device/jailbreak_detection_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/services/device/jailbreak_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/main.dart' as app;

class _FakeJailbreakDetection implements IJailbreakDetectionWrapper {
  _FakeJailbreakDetection(this.jailbroken);

  final bool jailbroken;

  @override
  Future<bool> isJailbroken() async => jailbroken;

  @override
  Future<bool> isDeveloperModeEnabled() async => false;
}

class _InertAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  @override
  Future<void> restoreSession() async {}
}

class _FakeAuthObserver extends ChangeNotifier
    implements IAuthenticationObserver {
  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  void update(bool value) {
    if (value != _isAuthenticated) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}

Future<void> _bootApp(WidgetTester tester, {required bool jailbroken}) async {
  app.main(
    overrides: [
      flutterJailbreakDetectionProvider.overrideWith(
        (ref) => _FakeJailbreakDetection(jailbroken),
      ),
      internetStatusProvider.overrideWith((ref) => Stream.value(true)),
      authProvider.overrideWith(() => _InertAuthNotifier()),
      authenticationObserverProvider.overrideWith((ref) => _FakeAuthObserver()),
    ],
  );

  for (var i = 0; i < 10; i++) {
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'jailbroken device shows the blocking screen with no unhandled exception',
    (tester) async {
      await _bootApp(tester, jailbroken: true);

      expect(find.byType(DeviceSecurityBlockedScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'secure device does not show the blocking screen and boots normally',
    (tester) async {
      await _bootApp(tester, jailbroken: false);

      expect(find.byType(DeviceSecurityBlockedScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
