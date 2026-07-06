import 'dart:convert';

import 'package:clean_architecture_sdd_harness/features/auth/presentation/providers/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/widgets/_widgets.lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:clean_architecture_sdd_harness/main.dart' as app;
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/go_router_notifier_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/sembast_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/database/_database.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/token_provider.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';

const _patient = PatientEntity(id: '1', name: 'John Doe');
const _token = TokenEntity(
  type: 'Bearer',
  key: 'jwt_token_123',
  expiresInHours: 24,
  expirationDate: null,
);
const _loginResponse = LoginResponseEntity(
  patient: _patient,
  token: _token,
  clinicalHistory: null,
);

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository();

  LoginResponseEntity? savedSessionData;

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Right(_loginResponse);

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Right(_token);

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async {
    savedSessionData = data;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearSession() async => const Right(null);

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async {
    if (savedSessionData == null) return const Right(null);
    return Right(savedSessionData!);
  }
}

class _FakeSaveSessionFailingRepository implements IAuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Right(_loginResponse);

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Right(_token);

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async =>
      const Left(UnexpectedFailure());

  @override
  Future<Either<Failure, void>> clearSession() async => const Right(null);

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Right(null);
}

class _FakeClearSessionFailingRepository implements IAuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Right(_loginResponse);

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Right(_token);

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> clearSession() async =>
      const Left(UnexpectedFailure());

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Right(_loginResponse);
}

class _FakeRestoreSessionFailingRepository implements IAuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Right(_loginResponse);

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Right(_token);

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> clearSession() async => const Right(null);

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Left(UnexpectedFailure());
}

class _FakeInvalidCredentialsRepository implements IAuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Left(ApiFailure());

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Left(ApiFailure());

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> clearSession() async => const Right(null);

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Right(null);
}

class _FakeNetworkErrorRepository implements IAuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Left(NoConnectionFailure());

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Left(NoConnectionFailure());

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> clearSession() async => const Right(null);

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Right(null);
}

class _FakeOfflineWithCachedDataRepository implements IAuthRepository {
  LoginResponseEntity? _cachedData;

  set cachedData(LoginResponseEntity? data) => _cachedData = data;

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async {
    // Remote fails with NoConnection, but local cache has data → fallback
    if (_cachedData != null) {
      return Right(_cachedData!);
    }
    return const Left(NoConnectionFailure());
  }

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Left(NoConnectionFailure());

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async {
    _cachedData = data;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearSession() async {
    _cachedData = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Right(null);
}

class _FakeServerUnreachableRepository implements IAuthRepository {
  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String passwordHash,
  }) async =>
      const Left(ServerUnreachableFailure());

  @override
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String token,
  }) async =>
      const Left(ServerUnreachableFailure());

  @override
  Future<Either<Failure, void>> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> clearSession() async => const Right(null);

  @override
  Future<Either<Failure, LoginResponseEntity?>> restoreSession() async =>
      const Right(null);
}

class _FakeCpSembast implements ICpSembast {
  @override
  Future<void> clearSession() async {}
}

class _FakeTokenService implements ITokenService {
  String? _cachedToken;

  @override
  Future<void> save(String token) async => _cachedToken = token;

  @override
  Future<String?> read() async => _cachedToken;

  @override
  Future<void> delete() async => _cachedToken = null;

  @override
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  }) async {}

  @override
  Future<({String email, String passwordHash})?> readCredentials() async => null;

  @override
  Future<void> deleteCredentials() async {}

  @override
  Future<void> deleteAll() async => _cachedToken = null;

  @override
  Future<bool> isTokenExpired(String token) async => false;

  @override
  Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

class _FakeClinicalHistory implements IClinicalHistoryStore {
  List<ClinicalHistoryEntity> _records = [];

  @override
  Future<void> store(ClinicalHistoryEntity entity) async => _records.add(entity);

  @override
  Future<void> storeAll(List<ClinicalHistoryEntity> entities) async {
    _records = List.from(entities);
  }

  @override
  Future<ClinicalHistoryEntity?> load(String id) async =>
      _records.cast<ClinicalHistoryEntity?>().firstOrNull;

  @override
  Future<List<ClinicalHistoryEntity>> loadAll() async => _records;

  @override
  Future<void> delete(String id) async =>
      _records.removeWhere((e) => e.id == id);

  @override
  Future<void> deleteAll() async => _records.clear();

  @override
  Future<void> update(ClinicalHistoryEntity entity) async =>
      _records = _records.map((e) => e.id == entity.id ? entity : e).toList();

  @override
  Future<void> updateAll(List<ClinicalHistoryEntity> entities) async {
    for (final entity in entities) {
      _records = _records.map((e) => e.id == entity.id ? entity : e).toList();
    }
  }
}

class _FakePatientInfoStore implements IPatientInfoStore {
  PatientEntity? _patient;

  PatientEntity? get savedPatient => _patient;

  @override
  Future<void> save(PatientEntity patient) async {
    _patient = patient;
  }

  @override
  Future<PatientEntity?> load() async => _patient;

  @override
  Future<void> delete() async {
    _patient = null;
  }
}

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

  setUp(() {
    CustomDb.clinicalHistory = _FakeClinicalHistory();
    CustomDb.patientInfo = _FakePatientInfoStore();
  });

  testWidgets(
    'Scenario: Login form renders with email and password fields',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Login with valid credentials enters values',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      await _enterCredentials(tester);

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    },
  );

  testWidgets(
    'Scenario: Login with invalid credentials shows error',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeInvalidCredentialsRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(
        find.text(
          'The server returned an error. Please try again later.',
        ),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Login with network error shows error message',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeNetworkErrorRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Login with network error but cached data available shows Clinical History',
    (tester) async {
      final fakeRepo = _FakeOfflineWithCachedDataRepository();
      fakeRepo.cachedData = _loginResponse;

      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => fakeRepo,
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('Welcome, John Doe'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Login with server unreachable shows error message',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeServerUnreachableRepository(),
        ),
        sembastProvider.overrideWith(
          (ref) => _FakeCpSembast(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('Server under maintenance'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Remember me checkbox toggles',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      await _toggleRememberMe(tester);
      expect(checkbox, findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: App start with no stored credentials shows login screen',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Password field starts obscured',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        goRouterListenableProvider.overrideWith(
          (ref) => GoRouterListenable(false),
        ),
      ]);
      await tester.pumpAndSettle();

      final passwordField = find.byType(TextField).last;
      final textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, isTrue);
    },
  );

  testWidgets(
    'Scenario: Successful login with rememberMe navigates to Clinical History and shows patient data',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        sembastProvider.overrideWith(
          (ref) => _FakeCpSembast(),
        ),
      ]);
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _toggleRememberMe(tester);
      await _tapLogin(tester);

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('Welcome, John Doe'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Successful login without rememberMe navigates to Clinical History',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        sembastProvider.overrideWith(
          (ref) => _FakeCpSembast(),
        ),
      ]);
      await tester.pumpAndSettle();

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('Logout'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: App start with valid stored session navigates to Clinical History',
    (tester) async {
      final fakeRepo = _FakeAuthRepository();
      fakeRepo.savedSessionData = const LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'Stored User'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'stored_token',
          expiresInHours: 24,
          expirationDate: null,
        ),
        clinicalHistory: null,
      );
      final tokenService = _FakeTokenService();
      await tokenService.save('stored_token');

      app.main(overrides: [
        authRepositoryProvider.overrideWith((ref) => fakeRepo),
        tokenServiceProvider.overrideWith((ref) => tokenService),
      ]);

      await tester.pumpAndSettle();

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('Welcome, Stored User'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Remember me persists credentials for next session',
    (tester) async {
      final fakeRepo = _FakeAuthRepository();
      final tokenService = _FakeTokenService();

      app.main(overrides: [
        authRepositoryProvider.overrideWith((ref) => fakeRepo),
        sembastProvider.overrideWith((ref) => _FakeCpSembast()),
        tokenServiceProvider.overrideWith((ref) => tokenService),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await _enterCredentials(tester);
      await _toggleRememberMe(tester);
      await _tapLogin(tester);

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('Welcome, John Doe'), findsOneWidget);

      expect(fakeRepo.savedSessionData, isNotNull);
      expect(fakeRepo.savedSessionData!.patient.name, 'John Doe');

      final token = await tokenService.read();
      expect(token, 'jwt_token_123');

      app.main(overrides: [
        authRepositoryProvider.overrideWith((ref) => fakeRepo),
        sembastProvider.overrideWith((ref) => _FakeCpSembast()),
        tokenServiceProvider.overrideWith((ref) => tokenService),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('Welcome, John Doe'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: No rememberMe does not persist session',
    (tester) async {
      final patientInfo = _FakePatientInfoStore();
      CustomDb.patientInfo = patientInfo;

      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(),
        ),
        sembastProvider.overrideWith((ref) => _FakeCpSembast()),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await _enterCredentials(tester);
      await _tapLogin(tester);

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));

      expect(patientInfo.savedPatient, isNull);
    },
  );

  testWidgets(
    'Scenario: Explicit logout clears session and returns to login screen',
    (tester) async {
      final fakeRepo = _FakeAuthRepository();
      fakeRepo.savedSessionData = const LoginResponseEntity(
        patient: PatientEntity(id: '1', name: 'Stored User'),
        token: TokenEntity(
          type: 'Bearer',
          key: 'stored_token',
          expiresInHours: 24,
          expirationDate: null,
        ),
        clinicalHistory: null,
      );
      final tokenService = _FakeTokenService();
      await tokenService.save('stored_token');

      app.main(overrides: [
        authRepositoryProvider.overrideWith((ref) => fakeRepo),
        tokenServiceProvider.overrideWith((ref) => tokenService),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('LOGIN'), findsOneWidget);
    },
  );

  testWidgets(
    'Scenario: Login with rememberMe and saveSession failure shows error and stays on login',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeSaveSessionFailingRepository(),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await _enterCredentials(tester);
      await _toggleRememberMe(tester);
      await _tapLogin(tester);

      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Logout'), findsNothing);
      expect(
        find.text('An unexpected error occurred. Please try again later.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Scenario: App start with restoreSession failure stays on login screen',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeRestoreSessionFailingRepository(),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Logout'), findsNothing);
    },
  );

  testWidgets(
    'Scenario: Logout with clearSession failure shows error and stays on Clinical History',
    (tester) async {
      app.main(overrides: [
        authRepositoryProvider.overrideWith(
          (ref) => _FakeClearSessionFailingRepository(),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Clinical History'), findsAtLeastNWidgets(1));
      expect(find.text('LOGIN'), findsNothing);
      expect(
        find.text('An unexpected error occurred. Please try again later.'),
        findsOneWidget,
      );
    },
  );
}
