import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/widgets/email_form_field.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/widgets/password_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:clean_architecture_sdd_harness/main.dart' as app;
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/token_providers.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';

const _patient = PatientEntity(id: '1', name: 'John Doe');
const _token = TokenEntity(key: 'jwt_token_123');
const _loginResponse = LoginResponseEntity(
  patient: _patient,
  token: _token,
  clinicalHistory: [],
);

class _FakeAuthRepository implements IAuthRepository, ILocalAuthRepository {
  _FakeAuthRepository({this.tokenStore});

  ITokenStore? tokenStore;
  LoginResponseEntity? savedSessionData;

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
  }) async {
    savedSessionData = data;
    await tokenStore?.save(data.token.key);
    return const Success(null);
  }

  @override
  Future<Result<void>> clearSession() async => const Success(null);

  @override
  Future<Result<void>> resetAccount() async => const Success(null);

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() async {
    if (savedSessionData == null) return const Success(null);
    return Success(savedSessionData!);
  }
}

class _FakeSaveSessionFailingRepository
    implements IAuthRepository, ILocalAuthRepository {
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
  }) async => const Failure(UnexpectedError());

  @override
  Future<Result<void>> clearSession() async => const Success(null);

  @override
  Future<Result<void>> resetAccount() async => const Success(null);

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() async =>
      const Success(null);
}

class _FakeClearSessionFailingRepository
    implements IAuthRepository, ILocalAuthRepository {
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
  Future<Result<void>> clearSession() async => const Failure(UnexpectedError());

  @override
  Future<Result<void>> resetAccount() async => const Success(null);

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() async =>
      const Success(_loginResponse);
}

class _FakeRestoreSessionFailingRepository
    implements IAuthRepository, ILocalAuthRepository {
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
      const Failure(UnexpectedError());
}

class _FakeInvalidCredentialsRepository
    implements IAuthRepository, ILocalAuthRepository {
  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) async => const Failure(ApiError());

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) async =>
      const Failure(ApiError());

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
      const Success(null);
}

class _FakeNetworkErrorRepository
    implements IAuthRepository, ILocalAuthRepository {
  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) async => const Failure(NetworkError());

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) async =>
      const Failure(NetworkError());

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
      const Success(null);
}

class _FakeOfflineWithCachedDataRepository
    implements IAuthRepository, ILocalAuthRepository {
  LoginResponseEntity? _cachedData;

  set cachedData(LoginResponseEntity? data) => _cachedData = data;

  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) async {
    if (_cachedData != null) {
      return Success(_cachedData!);
    }
    return const Failure(NetworkError());
  }

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) async =>
      const Failure(NetworkError());

  @override
  Future<Result<void>> saveSession({
    required LoginResponseEntity data,
    required Email email,
    required PasswordHash passwordHash,
  }) async {
    _cachedData = data;
    return const Success(null);
  }

  @override
  Future<Result<void>> clearSession() async {
    _cachedData = null;
    return const Success(null);
  }

  @override
  Future<Result<void>> resetAccount() async => const Success(null);

  @override
  Future<Result<LoginResponseEntity?>> restoreSession() async =>
      const Success(null);
}

class _FakeServerUnreachableRepository
    implements IAuthRepository, ILocalAuthRepository {
  @override
  Future<Result<LoginResponseEntity>> login({
    required Email email,
    required PasswordHash passwordHash,
  }) async => const Failure(ServerUnreachableError());

  @override
  Future<Result<TokenEntity>> refreshToken({required String token}) async =>
      const Failure(ServerUnreachableError());

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
      const Success(null);
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

final _fakeChRepo = _FakeClinicalHistoryRepository();

List<Override> _authRepoOverrides(IAuthRepository repository) => [
  authRepositoryProvider.overrideWith((ref) => repository),
  localAuthRepositoryProvider.overrideWith(
    (ref) => repository as ILocalAuthRepository,
  ),
  internetStatusProvider.overrideWith((ref) => Stream.value(true)),
];

Future<void> _enterCredentials(
  WidgetTester tester, {
  String email = 'test@example.com',
  String password = 'password123',
}) async {
  await tester.enterText(find.byType(EmailFormField), email);
  await tester.enterText(find.byType(PasswordFormField), password);
  await tester.pump();
}

Future<void> _toggleRememberMe(WidgetTester tester) async {
  await tester.tap(find.byType(Checkbox));
  await tester.pump();
}

Future<void> _tapLogin(WidgetTester tester) async {
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scenario: Login form renders with email and password fields', (
    tester,
  ) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeAuthRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsAtLeastNWidgets(1));
    expect(find.text('Contraseña'), findsAtLeastNWidgets(1));
    expect(find.text('Recordarme'), findsOneWidget);
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Scenario: Login with valid credentials enters values', (
    tester,
  ) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeAuthRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    await _enterCredentials(tester);

    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Scenario: Login with invalid credentials shows error', (
    tester,
  ) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeInvalidCredentialsRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    await _enterCredentials(tester);
    await _tapLogin(tester);

    expect(find.text('El servidor está en mantenimiento'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Scenario: Login with network error shows error message', (
    tester,
  ) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeNetworkErrorRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    await _enterCredentials(tester);
    await _tapLogin(tester);

    expect(find.text('Sin conexión a internet'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets(
    'Scenario: Login with network error but cached data available shows Clinical History',
    (tester) async {
      final fakeRepo = _FakeOfflineWithCachedDataRepository();
      fakeRepo.cachedData = _loginResponse;

      app.main(
        overrides: [
          ..._authRepoOverrides(fakeRepo),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );

  testWidgets('Scenario: Login with server unreachable shows error message', (
    tester,
  ) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeServerUnreachableRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    await _enterCredentials(tester);
    await _tapLogin(tester);

    expect(find.text('El servidor está en mantenimiento'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Scenario: Remember me checkbox toggles', (tester) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeAuthRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);

    await _toggleRememberMe(tester);
    expect(checkbox, findsOneWidget);
  });

  testWidgets(
    'Scenario: App start with no stored credentials shows login screen',
    (tester) async {
      app.main(
        overrides: [
          ..._authRepoOverrides(_FakeAuthRepository()),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    },
  );

  testWidgets('Scenario: Password field starts obscured', (tester) async {
    app.main(
      overrides: [
        ..._authRepoOverrides(_FakeAuthRepository()),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    final passwordField = find.byType(TextField).last;
    final textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isTrue);
  });

  testWidgets(
    'Scenario: Successful login with rememberMe navigates to Clinical History and shows patient data',
    (tester) async {
      app.main(
        overrides: [
          ..._authRepoOverrides(_FakeAuthRepository()),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _toggleRememberMe(tester);
      await _tapLogin(tester);

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Successful login without rememberMe navigates to Clinical History',
    (tester) async {
      app.main(
        overrides: [
          ..._authRepoOverrides(_FakeAuthRepository()),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: App start with valid stored session navigates to Clinical History',
    (tester) async {
      final fakeRepo = _FakeAuthRepository();
      fakeRepo.savedSessionData = const LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'Stored User'),
        token: TokenEntity(key: 'stored_token'),
        clinicalHistory: [],
      );
      final tokenStore = _FakeTokenStore();
      await tokenStore.save('stored_token');
      final credentialStore = _FakeCredentialStore();
      final tokenVerifier = _FakeTokenVerifier();

      app.main(
        overrides: [
          ..._authRepoOverrides(fakeRepo),
          tokenStoreProvider.overrideWith((ref) => tokenStore),
          credentialStoreProvider.overrideWith((ref) => credentialStore),
          tokenVerifierProvider.overrideWith((ref) => tokenVerifier),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );

      await tester.pumpAndSettle();

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets('Scenario: Remember me persists credentials for next session', (
    tester,
  ) async {
    final tokenStore = _FakeTokenStore();
    final credentialStore = _FakeCredentialStore();
    final tokenVerifier = _FakeTokenVerifier();
    final fakeRepo = _FakeAuthRepository(tokenStore: tokenStore);

    app.main(
      overrides: [
        ..._authRepoOverrides(fakeRepo),
        tokenStoreProvider.overrideWith((ref) => tokenStore),
        credentialStoreProvider.overrideWith((ref) => credentialStore),
        tokenVerifierProvider.overrideWith((ref) => tokenVerifier),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('INICIAR SESIÓN'), findsOneWidget);

    await _enterCredentials(tester);
    await _toggleRememberMe(tester);
    await _tapLogin(tester);

    expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));

    expect(fakeRepo.savedSessionData, isNotNull);
    expect(fakeRepo.savedSessionData!.patient.name, 'John Doe');

    final token = await tokenStore.read();
    expect(token, 'jwt_token_123');

    app.main(
      overrides: [
        ..._authRepoOverrides(fakeRepo),
        tokenStoreProvider.overrideWith((ref) => tokenStore),
        credentialStoreProvider.overrideWith((ref) => credentialStore),
        tokenVerifierProvider.overrideWith((ref) => tokenVerifier),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
  });

  testWidgets('Scenario: No rememberMe does not persist session', (
    tester,
  ) async {
    final fakeRepo = _FakeAuthRepository();

    app.main(
      overrides: [
        ..._authRepoOverrides(fakeRepo),
        clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('INICIAR SESIÓN'), findsOneWidget);

    await _enterCredentials(tester);
    await _tapLogin(tester);

    expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));

    expect(fakeRepo.savedSessionData, isNull);
  });

  testWidgets(
    'Scenario: Explicit logout clears session and returns to login screen',
    (tester) async {
      final fakeRepo = _FakeAuthRepository();
      fakeRepo.savedSessionData = const LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'Stored User'),
        token: TokenEntity(key: 'stored_token'),
        clinicalHistory: [],
      );
      final tokenStore = _FakeTokenStore();
      await tokenStore.save('stored_token');
      final credentialStore = _FakeCredentialStore();
      final tokenVerifier = _FakeTokenVerifier();

      app.main(
        overrides: [
          ..._authRepoOverrides(fakeRepo),
          tokenStoreProvider.overrideWith((ref) => tokenStore),
          credentialStoreProvider.overrideWith((ref) => credentialStore),
          tokenVerifierProvider.overrideWith((ref) => tokenVerifier),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Login with rememberMe and saveSession failure shows error and stays on login',
    (tester) async {
      app.main(
        overrides: [
          ..._authRepoOverrides(_FakeSaveSessionFailingRepository()),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);

      await _enterCredentials(tester);
      await _toggleRememberMe(tester);
      await _tapLogin(tester);

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNothing);
      expect(find.text('Ocurrió un error inesperado'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: App start with restoreSession failure stays on login screen',
    (tester) async {
      app.main(
        overrides: [
          ..._authRepoOverrides(_FakeRestoreSessionFailingRepository()),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNothing);
    },
  );

  testWidgets(
    'Scenario: Logout with clearSession failure shows error and stays on Clinical History',
    (tester) async {
      app.main(
        overrides: [
          ..._authRepoOverrides(_FakeClearSessionFailingRepository()),
          clinicalHistoryRepositoryProvider.overrideWith((ref) => _fakeChRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Historial Clínico'), findsAtLeastNWidgets(1));
      expect(find.text('INICIAR SESIÓN'), findsNothing);
      expect(find.text('Ocurrió un error inesperado'), findsOneWidget);
    },
  );
}
