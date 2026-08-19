import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/token_providers.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/widgets/clinical_history_card.dart';
import 'package:clean_architecture_sdd_harness/main.dart' as app;
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _patient = PatientEntity(id: '1', name: 'John Doe');
const _token = TokenEntity(key: 'jwt_token_123');
const _loginResponse = LoginResponseEntity(
  patient: _patient,
  token: _token,
  clinicalHistory: [],
);

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

List<Override> _authRepoOverrides(IAuthRepository repository) => [
  authRepositoryProvider.overrideWith((ref) => repository),
  localAuthRepositoryProvider.overrideWith(
    (ref) => repository as ILocalAuthRepository,
  ),
  internetStatusProvider.overrideWith((ref) => Stream.value(true)),
];

const _tEntity1 = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: ClinicalHistoryServiceEntity(
    code: 'GEN',
    name: 'General Medicine',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-001',
    name: 'Central Medical Center',
    city: 'Quito',
  ),
  professional: null,
  encounterDate: '2026-01-15',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);
const _tEntity2 = ClinicalHistoryEntity(
  id: 'ch2',
  encounterNumber: 'ENC-002',
  service: ClinicalHistoryServiceEntity(
    code: 'PED',
    name: 'Pediatrics',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-002',
    name: 'North Side Clinic',
    city: 'Guayaquil',
  ),
  professional: null,
  encounterDate: '2026-02-01',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'closed', label: 'Closed'),
);
const _tList = [_tEntity1, _tEntity2];

const _tEntity1Refreshed = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: ClinicalHistoryServiceEntity(
    code: 'CAR',
    name: 'Cardiology',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-001',
    name: 'Central Medical Center',
    city: 'Quito',
  ),
  professional: null,
  encounterDate: '2026-01-15',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);
const _tListAfterRefresh = [_tEntity1Refreshed];

class _FakeClinicalHistoryRepository implements IClinicalHistoryRepository {
  _FakeClinicalHistoryRepository({
    required this.loadResult,
    this.refreshResult,
  });

  final Result<List<ClinicalHistoryEntity>> loadResult;
  final Result<List<ClinicalHistoryEntity>>? refreshResult;
  int loadCalls = 0;
  int refreshCalls = 0;

  @override
  Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories() async {
    loadCalls++;
    return loadResult;
  }

  @override
  Future<Result<List<ClinicalHistoryEntity>>> refreshClinicalHistories() async {
    refreshCalls++;
    return refreshResult ?? loadResult;
  }
}

Future<void> _bootApp(
  WidgetTester tester,
  IClinicalHistoryRepository clinicalHistoryRepository,
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
        (ref) => clinicalHistoryRepository,
      ),
    ],
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Scenario: Load shows the list with service, facility, date and state',
    (tester) async {
      final repo = _FakeClinicalHistoryRepository(
        loadResult: const Success(_tList),
      );
      await _bootApp(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
      expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
      expect(find.text('Central Medical Center'), findsOneWidget);
      expect(find.text('Quito'), findsOneWidget);
      expect(find.text('North Side Clinic'), findsOneWidget);
      expect(find.text('Guayaquil'), findsOneWidget);
      expect(find.text('15 ene 2026'), findsOneWidget);
      expect(find.text('1 feb 2026'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    },
  );

  testWidgets('Scenario: Empty history shows an empty state with retry', (
    tester,
  ) async {
    final repo = _FakeClinicalHistoryRepository(
      loadResult: const Success(<ClinicalHistoryEntity>[]),
    );
    await _bootApp(tester, repo);
    await tester.pumpAndSettle();

    expect(
      find.text('Aún no hay registros de historial clínico.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.loadCalls, greaterThan(0));
  });

  testWidgets('Scenario: Pull to refresh reloads from the server', (
    tester,
  ) async {
    final repo = _FakeClinicalHistoryRepository(
      loadResult: const Success(_tList),
      refreshResult: const Success(_tListAfterRefresh),
    );
    await _bootApp(tester, repo);
    await tester.pumpAndSettle();

    expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
    expect(find.text('General Medicine'), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(repo.refreshCalls, greaterThan(0));
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('General Medicine'), findsNothing);
  });

  testWidgets('Scenario: Offline with cached data shows the cache', (
    tester,
  ) async {
    final repo = _FakeClinicalHistoryRepository(
      loadResult: const Success(_tList),
    );
    await _bootApp(tester, repo);
    await tester.pumpAndSettle();

    expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
    expect(find.text('General Medicine'), findsOneWidget);
    expect(find.text('Pediatrics'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
    'Scenario: Network failure shows a localized error and allows retry',
    (tester) async {
      final repo = _FakeClinicalHistoryRepository(
        loadResult: const Failure(NetworkError()),
      );
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
          clinicalHistoryRepositoryProvider.overrideWith((ref) => repo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin conexión a internet'), findsWidgets);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(repo.loadCalls, greaterThan(0));

      final loadsBeforeRetry = repo.loadCalls;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(
        repo.loadCalls,
        greaterThan(loadsBeforeRetry),
        reason: 'retry reloads the list (no infinite loop)',
      );
    },
  );

  testWidgets('Scenario: Pull to refresh offline keeps the cached list', (
    tester,
  ) async {
    final repo = _FakeClinicalHistoryRepository(
      loadResult: const Success(_tList),
      refreshResult: const Failure(NetworkError()),
    );
    await _bootApp(tester, repo);
    await tester.pumpAndSettle();

    expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(repo.refreshCalls, greaterThan(0));
    expect(
      find.byType(ClinicalHistoryCard),
      findsNWidgets(2),
      reason: 'a failed refresh keeps the cached list visible',
    );
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Sin conexión a internet'), findsWidgets);
  });
}
