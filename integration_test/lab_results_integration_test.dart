import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/token_providers.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/repositories/i_lab_results_repository.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/screens/lab_results_screen.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_card.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_chart_pane.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_non_numeric_list.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_period_filter.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_test_selector.dart';
import 'package:clean_architecture_sdd_harness/main.dart' as app;
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

const _patient = PatientEntity(id: '1', name: 'John Doe');
const _token = TokenEntity(key: 'jwt_token_123');
const _loginResponse = LoginResponseEntity(
  patient: _patient,
  token: _token,
  clinicalHistory: [],
);

final _hemoglobina = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 16.8),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 15.4),
  ],
);

final _hemoglobinaRefreshed = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 12), value: 18.0),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 15.4),
  ],
);

final _glucosa = LabResultEntity(
  id: 'lr_0002',
  testCode: 'GLU',
  testName: 'Glucosa en ayunas',
  category: 'Química sanguínea',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 70.0, high: 110.0),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 128.0),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 118.5),
  ],
);

final _pcr = LabResultEntity(
  id: 'lr_0004',
  testCode: 'PCR',
  testName: 'Proteína C reactiva',
  category: 'Inmunología',
  unit: 'mg/L',
  kind: LabResultKind.numeric,
  referenceRange: null,
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 2.4),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 1.9),
  ],
);

final _grupo = LabResultEntity(
  id: 'lr_0005',
  testCode: 'GRUPO',
  testName: 'Grupo sanguíneo',
  category: 'Inmunohematología',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      textValue: 'A Positivo (A+)',
    ),
  ],
);

final _sedimento = LabResultEntity(
  id: 'lr_0006',
  testCode: 'SED',
  testName: 'Sedimento de orina',
  category: 'Análisis de orina',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      textValue: 'No se observan cristales',
    ),
  ],
);

final _mixedResults = [_hemoglobina, _glucosa, _pcr, _grupo];
final _mixedResultsRefreshed = [_hemoglobinaRefreshed];
final _textOnlyResults = [_grupo, _sedimento];

class _FakeAuthRepository implements IAuthRepository, ILocalAuthRepository {
  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) async => const Success(_loginResponse);

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) async =>
      const Success(_token);

  @override
  Future<Result<void>> saveSession({
    required LoginResponseEntity data,
    required Email email,
    required PasswordHash passwordHash,
  }) async => const Success(null);

  @override
  Future<Result<void>> clearSession() async => const Success(null);

  @override
  Future<Result<void>> resetAccount() async => const Success(null);

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() async =>
      const Success(_loginResponse);
}

class _FakeTokenStore implements ITokenStore {
  String? _cachedToken;

  @override
  Future<void> save(String token) async => _cachedToken = token;

  @override
  Future<String?> read() async => _cachedToken;

  @override
  Future<void> delete() async => _cachedToken = null;
}

class _FakeCredentialStore implements ICredentialStore {
  @override
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  }) async {}

  @override
  Future<({String email, String passwordHash})?> readCredentials() async =>
      null;

  @override
  Future<void> deleteCredentials() async {}
}

class _FakeTokenVerifier implements ITokenVerifier {
  @override
  Future<bool> isExpired(String token) async => false;
}

class _FakeClinicalHistoryRepository implements IClinicalHistoryRepository {
  @override
  Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories() async =>
      const Success(<ClinicalHistoryEntity>[]);

  @override
  Future<Result<List<ClinicalHistoryEntity>>>
  refreshClinicalHistories() async => const Success(<ClinicalHistoryEntity>[]);
}

class _FakeLabResultsRepository implements ILabResultsRepository {
  _FakeLabResultsRepository({required this.loadResult, this.refreshResult});

  final Result<List<LabResultEntity>> loadResult;
  final Result<List<LabResultEntity>>? refreshResult;
  int loadCalls = 0;
  int refreshCalls = 0;

  @override
  Future<Result<List<LabResultEntity>>> loadLabResults() async {
    loadCalls++;
    return loadResult;
  }

  @override
  Future<Result<List<LabResultEntity>>> refreshLabResults() async {
    refreshCalls++;
    return refreshResult ?? loadResult;
  }
}

List<Override> _authRepoOverrides(IAuthRepository repository) => [
  authRepositoryProvider.overrideWith((ref) => repository),
  localAuthRepositoryProvider.overrideWith(
    (ref) => repository as ILocalAuthRepository,
  ),
  internetStatusProvider.overrideWith((ref) => Stream.value(true)),
];

Future<void> _bootApp(
  WidgetTester tester,
  ILabResultsRepository labResultsRepository,
) async {
  final tokenStore = _FakeTokenStore();
  await tokenStore.save('jwt_token_123');
  final credentialStore = _FakeCredentialStore();
  final tokenVerifier = _FakeTokenVerifier();

  app.main(
    overrides: [
      ..._authRepoOverrides(_FakeAuthRepository()),
      tokenStoreProvider.overrideWith((ref) => tokenStore),
      credentialStoreProvider.overrideWith((ref) => credentialStore),
      tokenVerifierProvider.overrideWith((ref) => tokenVerifier),
      clinicalHistoryRepositoryProvider.overrideWith(
        (ref) => _FakeClinicalHistoryRepository(),
      ),
      labResultsRepositoryProvider.overrideWith((ref) => labResultsRepository),
    ],
  );
  await tester.pumpAndSettle();
}

Future<void> _openLabResults(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.biotech_outlined));
  await tester.pumpAndSettle();
  expect(find.byType(LabResultsScreen), findsOneWidget);
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  final screenScrollable = find
      .descendant(
        of: find.byType(LabResultsScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  final gesture = await tester.startGesture(
    tester.getTopLeft(screenScrollable) + const Offset(20, 20),
  );
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 60));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Scenario: Load shows numeric cards with status chips and a non-numeric flat list',
    (tester) async {
      final repo = _FakeLabResultsRepository(
        loadResult: Success(_mixedResults),
      );
      await _bootApp(tester, repo);
      await _openLabResults(tester);

      expect(find.byType(LabResultsTestSelector), findsOneWidget);
      expect(find.byType(LabResultsPeriodFilter), findsOneWidget);
      expect(find.text('Todo'), findsOneWidget);

      expect(find.byType(LabResultsCard), findsNWidgets(3));
      expect(find.text('Hemoglobina'), findsAtLeastNWidgets(1));
      expect(find.text('Glucosa en ayunas'), findsAtLeastNWidgets(1));
      expect(find.text('Proteína C reactiva'), findsAtLeastNWidgets(1));
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Alto'), findsOneWidget);
      expect(find.text('Desconocido'), findsOneWidget);

      expect(find.byType(LabResultsNonNumericList), findsOneWidget);
      expect(find.text('Otros resultados'), findsOneWidget);
      expect(find.text('A Positivo (A+)'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Selecting a numeric test renders its trend chart with a reference-range band',
    (tester) async {
      final repo = _FakeLabResultsRepository(
        loadResult: Success(_mixedResults),
      );
      await _bootApp(tester, repo);
      await _openLabResults(tester);

      expect(find.byType(LabResultsChartPane), findsOneWidget);
      expect(find.text('Tendencia'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(LabResultsTestSelector),
          matching: find.text('Glucosa en ayunas'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LabResultsChartPane), findsOneWidget);
      expect(find.text('Tendencia'), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(
              find.ancestor(
                of: find.text('Glucosa en ayunas'),
                matching: find.byType(ChoiceChip),
              ),
            )
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<ChoiceChip>(
              find.ancestor(
                of: find.text('Hemoglobina'),
                matching: find.byType(ChoiceChip),
              ),
            )
            .selected,
        isFalse,
      );
    },
  );

  testWidgets(
    'Scenario: All results non-numeric hides the selector and period filter',
    (tester) async {
      final repo = _FakeLabResultsRepository(
        loadResult: Success(_textOnlyResults),
      );
      await _bootApp(tester, repo);
      await _openLabResults(tester);

      expect(find.byType(LabResultsTestSelector), findsNothing);
      expect(find.byType(LabResultsPeriodFilter), findsNothing);
      expect(find.byType(LabResultsChartPane), findsNothing);

      expect(find.byType(LabResultsNonNumericList), findsOneWidget);
      expect(find.text('Otros resultados'), findsOneWidget);
      expect(find.text('A Positivo (A+)'), findsOneWidget);
      expect(find.text('No se observan cristales'), findsOneWidget);
    },
  );

  testWidgets('Scenario: Empty results show an empty state with retry', (
    tester,
  ) async {
    final repo = _FakeLabResultsRepository(
      loadResult: const Success(<LabResultEntity>[]),
    );
    await _bootApp(tester, repo);
    await _openLabResults(tester);

    expect(find.text('No hay resultados de laboratorio'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    final loadsBeforeRetry = repo.loadCalls;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.loadCalls, greaterThan(loadsBeforeRetry));
  });

  testWidgets('Scenario: Pull to refresh reloads from the server', (
    tester,
  ) async {
    final repo = _FakeLabResultsRepository(
      loadResult: Success(_mixedResults),
      refreshResult: Success(_mixedResultsRefreshed),
    );
    await _bootApp(tester, repo);
    await _openLabResults(tester);

    expect(find.text('Normal'), findsOneWidget);
    expect(find.byType(LabResultsCard), findsNWidgets(3));

    await _pullToRefresh(tester);

    expect(repo.refreshCalls, greaterThan(0));
    expect(find.text('Alto'), findsOneWidget);
    expect(find.text('Normal'), findsNothing);
    expect(find.byType(LabResultsCard), findsOneWidget);
  });

  testWidgets(
    'Scenario: Pull to refresh failure keeps the loaded results and shows a localized error',
    (tester) async {
      final repo = _FakeLabResultsRepository(
        loadResult: Success(_mixedResults),
        refreshResult: const Failure(NetworkError()),
      );
      await _bootApp(tester, repo);
      await _openLabResults(tester);

      expect(find.text('Normal'), findsOneWidget);
      expect(find.byType(LabResultsCard), findsNWidgets(3));

      await _pullToRefresh(tester);

      expect(repo.refreshCalls, greaterThan(0));
      expect(find.byType(LabResultsCard), findsNWidgets(3));
      expect(
        find.text('Normal'),
        findsOneWidget,
        reason: 'a failed refresh keeps the loaded results visible',
      );
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sin conexión a internet'), findsWidgets);
    },
  );
}
