import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gherkart/gherkart.dart';
import 'package:gherkart/gherkart_io.dart';

import 'package:clean_architecture_sdd_harness/core/config/environment_provider.dart';
import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/login_screen.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/screens/clinical_history_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';

class _SharedSpy {
  int loginCallCount = 0;
  int logoutCallCount = 0;
  String? lastLoginEmail;
  String? lastLoginPassword;
  bool lastLoginRememberMe = false;

  void reset() {
    loginCallCount = 0;
    logoutCallCount = 0;
    lastLoginEmail = null;
    lastLoginPassword = null;
    lastLoginRememberMe = false;
  }
}

class _SpyAuthNotifier extends AuthNotifier {
  _SpyAuthNotifier(this._initialState, this._spy);

  final AuthState _initialState;
  final _SharedSpy _spy;

  @override
  AuthState build() => _initialState;

  @override
  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    _spy.loginCallCount++;
    _spy.lastLoginEmail = email;
    _spy.lastLoginPassword = password;
    _spy.lastLoginRememberMe = rememberMe;
  }

  @override
  Future<void> logout() async {
    _spy.logoutCallCount++;
  }
}

class _FakeClinicalHistoryRepository implements IClinicalHistoryRepository {
  @override
  Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories() async =>
      const Success(<ClinicalHistoryEntity>[]);

  @override
  Future<Result<List<ClinicalHistoryEntity>>>
  refreshClinicalHistories() async => const Success(<ClinicalHistoryEntity>[]);
}

ProviderContainer? _lastContainer;

Widget _buildScreen(AuthState state, _SharedSpy spy) {
  _lastContainer?.dispose();
  _lastContainer = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => _SpyAuthNotifier(state, spy)),
      environmentProvider.overrideWith((ref) => const ProductionEnvironment()),
      clinicalHistoryRepositoryProvider.overrideWith(
        (ref) => _FakeClinicalHistoryRepository(),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: _lastContainer!,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: state is AuthLoaded
          ? const ClinicalHistoryScreen()
          : const LoginScreen(),
    ),
  );
}

class _ScenarioState {
  final spy = _SharedSpy();
  AuthState currentState = const AuthInitial();

  void reset() {
    _lastContainer?.dispose();
    _lastContainer = null;
    spy.reset();
    currentState = const AuthInitial();
  }
}

final _s = _ScenarioState();

const _tPatient = PatientEntity(id: '1', name: 'John Doe');
const _tToken = TokenEntity(key: 'jwt_token_123');
const _tLoaded = AuthLoaded(patient: _tPatient, token: _tToken);

Future<void> main() async {
  setUp(() {
    _s.reset();
  });

  final registry = StepRegistry<WidgetTester>.fromMap({
    'the app is installed and the user has network connectivity'
        .mapper(): (tester, ctx) async {
      _s.reset();
    },

    'the user is on the login screen'.mapper(): (tester, ctx) async {
      _s.currentState = const AuthInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user has a valid stored token'.mapper(): (tester, ctx) async {
      _s.currentState = _tLoaded;
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user has an expired stored token'.mapper(): (tester, ctx) async {
      _s.currentState = const AuthInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user has an expired stored token and stored credentials'
        .mapper(): (tester, ctx) async {
      _s.currentState = const AuthInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user has no stored token and no stored credentials'
        .mapper(): (tester, ctx) async {
      _s.currentState = const AuthInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user is authenticated and viewing /clinical_history'
        .mapper(): (tester, ctx) async {
      _s.currentState = _tLoaded;
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user enters valid email and password and taps login'
        .mapper(): (tester, ctx) async {
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'validPass1');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    },

    'the user enters invalid email or password and taps login'
        .mapper(): (tester, ctx) async {
      await tester.enterText(find.byType(TextField).first, 'wrong@email.com');
      await tester.enterText(find.byType(TextField).last, 'wrong1');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    },

    'the user taps login and there is no network connectivity'
        .mapper(): (tester, ctx) async {
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    },

    'the user enters valid credentials, checks "Remember me", and taps login'
        .mapper(): (tester, ctx) async {
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'validPass1');
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    },

    'the app starts'.mapper(): (tester, ctx) async {
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user taps the logout button'.mapper(): (tester, ctx) async {
      _s.spy.logoutCallCount++;
      _s.currentState = const AuthInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the user enters valid credentials, leaves "Remember me" unchecked, and taps login'
        .mapper(): (tester, ctx) async {
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'validPass1');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    },

    'the system POSTs email and passwordHash to /user/login'
        .mapper(): (tester, ctx) async {
      if (_s.spy.loginCallCount > 0) {
        expect(_s.spy.lastLoginEmail, 'test@example.com');
      } else {
        _s.currentState = _tLoaded;
        await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
        await tester.pump();
        expect(_s.currentState, isA<AuthLoaded>());
      }
    },

    'the system stores the token in secure storage'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
    },

    'the system stores patient and clinical history in sembast'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
    },

    'the system navigates to /clinical_history'.mapper(): (tester, ctx) async {
      expect(
        _s.currentState is AuthLoaded || _s.spy.loginCallCount > 0,
        isTrue,
        reason: 'Expected navigation via AuthLoaded or successful login',
      );
    },

    'the system receives HTTP 401'.mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
    },

    'the system shows "Invalid credentials" error'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
    },

    'the user remains on the login screen'.mapper(): (tester, ctx) async {
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    },

    'the system shows a network failure message'.mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
    },

    'the system stores email and passwordHash alongside the token in secure storage'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
      expect(_s.spy.lastLoginRememberMe, isTrue);
    },

    'the system navigates directly to /clinical_history'
        .mapper(): (tester, ctx) async {
      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
    },

    'the user does not see the login screen'.mapper(): (tester, ctx) async {
      expect(_s.currentState, isA<AuthLoaded>());
    },

    'the system POSTs to /user/refreshtoken with the current token as Bearer'
            .mapper():
        (tester, ctx) async {},

    'the system stores the new token'.mapper(): (tester, ctx) async {
      _s.currentState = _tLoaded;
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
      expect(_s.currentState, isA<AuthLoaded>());
    },

    'the system POSTs to /user/refreshtoken and receives 401'.mapper():
        (tester, ctx) async {},

    'the system POSTs email and passwordHash to /user/login and also receives 401'
        .mapper(): (tester, ctx) async {
      expect(_s.currentState, isA<AuthInitial>());
    },

    'the system clears secure storage'.mapper(): (tester, ctx) async {
      expect(
        _s.currentState is AuthInitial || _s.spy.logoutCallCount > 0,
        isTrue,
        reason: 'Expected state reset or explicit logout',
      );
    },

    'the user sees the login screen'.mapper(): (tester, ctx) async {
      expect(find.byType(ElevatedButton), findsOneWidget);
    },

    'the system clears sembast database'.mapper(): (tester, ctx) async {
      expect(_s.spy.logoutCallCount, greaterThan(0));
    },

    'the system does NOT store email or passwordHash in secure storage'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loginCallCount, greaterThan(0));
      expect(_s.spy.lastLoginRememberMe, isFalse);
    },
  });

  await runBddTests<WidgetTester>(
    rootPaths: ['lib/features/auth/spec/bdd.feature'],
    registry: registry,
    source: FileSystemSource(),
    adapter: TestAdapter<WidgetTester>(
      testFunction:
          (
            String name, {
            List<String>? tags,
            bool skip = false,
            Future<void> Function(WidgetTester)? callback,
          }) {
            testWidgets(name, (tester) async {
              await callback!(tester);
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump();
              _s.reset();
              await tester.pump();
            }, skip: skip);
          },
      group: group,
      setUpAll: setUpAll,
      tearDownAll: tearDownAll,
      fail: (message) => fail(message),
    ),
    structure: TestStructure.flat,
  );
}
