@Tags(['golden'])
library;

import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/clinical_history_placeholder_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

class _ControllableAuthNotifier extends AuthNotifier {
  _ControllableAuthNotifier(this._initialState);

  final AuthState _initialState;

  @override
  AuthState build() => _initialState;

  @override
  Future<void> logout() async {}
}

Widget _buildScreen(AuthState state) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _ControllableAuthNotifier(state)),
    ],
    child: MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ClinicalHistoryPlaceholderScreen(),
    ),
  );
}

void main() {
  testGoldens('ClinicalHistoryPlaceholderScreen golden test — initial state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(const AuthState.initial()),
    );
    await tester.pump();

    await expectLater(
      find.byType(ClinicalHistoryPlaceholderScreen),
      matchesGoldenFile('goldens/clinical_history_placeholder_screen_initial.png'),
    );
  });

  testGoldens('ClinicalHistoryPlaceholderScreen golden test — loaded state', (
    tester,
  ) async {
    const patient = PatientEntity(id: '1', name: 'John Doe');
    const token = TokenEntity(
      type: 'Bearer',
      key: 'test-token',
    );
    await tester.pumpWidget(
      _buildScreen(AuthLoaded(patient: patient, token: token)),
    );
    await tester.pump();

    await expectLater(
      find.byType(ClinicalHistoryPlaceholderScreen),
      matchesGoldenFile('goldens/clinical_history_placeholder_screen_loaded.png'),
    );
  });
}
