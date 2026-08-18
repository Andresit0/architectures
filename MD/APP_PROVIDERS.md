### Providers — usage rules

Global providers are defined in `lib/core/` (and feature providers in `features/<name>/di/`). There is no app-level barrel — feature DI imports providers directly from `core/` (one-way dependency, Rule 11).

---

#### Inventory of global providers

All global providers are **non-autoDispose** (alive for the lifetime of the `ProviderScope`); only `authProvider` explicitly uses `@Riverpod(keepAlive: true)`.

| Provider | Location | Type | Exposed state |
|---|---|---|---|
| `httpServiceProvider` | `core/network/dio/dio_providers.dart` | `Provider<IDioWrapper>` | HTTP singleton (Dio) WITH auth interceptor (401 retry + force logout); applies `authInterceptorProvider` (bound via `app/di/network/dio_overrides.dart`) |
| `authDioProvider` | `core/network/dio/dio_providers.dart` | `Provider<IDioWrapper>` | Dio WITHOUT auth interceptor. Used by AuthRemoteDatasource for login/refresh where no token exists yet |
| `tokenStoreProvider` | `core/services/auth/token_providers.dart` | `Provider<ITokenStore>` | Token storage singleton |
| `appDatabaseProvider` | `core/database/app_database_provider.dart` | `Provider<IAppDatabase>` | Sembast database instance (AES-256-CBC encrypted); `resetDatabase()` wipes file + key (account reset/GDPR), consumed via `ResetAccountUseCase` (auth) = `clearSession()` + `resetDatabase()` |
| `internetServiceProvider` | `core/network/connectivity/connectivity_providers.dart` | `Provider<IInternetService>` | Internet connectivity checker |
| `internetStatusProvider` | `core/network/connectivity/connectivity_providers.dart` | `StreamProvider<bool>` | Reactive internet status for the offline banner (emits current status immediately; `null` until first emission = treat as online) |
| *(removed)* `errorPropagation` | *(removed)* | Error propagation replaced by `localizeError()` in `l10n/error_localizer.dart` — UI layer calls `localizeError(error, AppLocalizations.of(context)!)` |
| `clinicalHistoryStoreProvider` | `core/database/tables/clinical_history_providers.dart` | `Provider<IClinicalHistoryStore>` | Clinical history store |
| `labResultsStoreProvider` | `core/database/tables/lab_results_providers.dart` | `Provider<ILabResultsStore>` | Lab results store |
| `patientInfoStoreProvider` | `core/database/tables/patient_info_providers.dart` | `Provider<IPatientInfoStore>` | Patient info store |
| `passwordHasherProvider` | `core/services/crypto/password_hasher_provider.dart` | `Provider<IPasswordHasher>` | Password hashing (bcrypt) |
| `connectivityCheckerProvider` | `core/network/connectivity/connectivity_providers.dart` | `Provider<IConnectivityChecker>` | Connectivity check abstraction |
| `tokenVerifierProvider` | `core/services/auth/token_providers.dart` | `Provider<ITokenVerifier>` | JWT expiry check (`isExpired` — decode delegado a `IJwtWrapper.decodePayload`) |
| `credentialStoreProvider` | `core/services/auth/token_providers.dart` | `Provider<ICredentialStore>` | Credential storage (remember-me) — credentials only; token persistence is owned by `tokenStoreProvider` (ISP) |
| `jwtWrapperProvider` | `core/services/auth/token_providers.dart` | `Provider<IJwtWrapper>` | JWT payload decode (`decodePayload`) |
| `loggerProvider` | `core/services/logging/logging_providers.dart` | `Provider<ILogger>` | Observability seam (`DevLogger` → `dart:developer log`); re-exported by each feature `di/`; overridable in tests (e.g. `FakeLogger`) |
| `trendChartProvider` | `core/services/charts/charts_providers.dart` | `Provider<ITrendChart>` | Trend chart seam (`FlChartTrendChart` wraps `package:fl_chart`); re-exported by `features/lab_results/di/`; feature code NEVER imports `package:fl_chart` |
| `environmentProvider` | `core/config/environment_provider.dart` | `Provider<AppEnvironment>` | App environment config |
| `appUriesProvider` | `core/network/api_endpoints.dart` | `Provider<IEndpointConfig>` | Remote endpoint URLs bound to `environmentProvider` (overridable in tests) |
| `appNavigatorProvider` | `core/router/app_navigator_provider.dart` | `Provider<IAppNavigator>` | Navigation seam — fail-fast until bound by `routerOverrides()`; a feature that navigates imperatively uses it via a one-line re-export in its own `di/` (on-demand) |

**Boot validation:** ambos seams (`authInterceptorProvider`, `appNavigatorProvider`) se verifican en el boot de `main.dart` (`_assertDiSeamsBound`) — si `dioOverrides()`/`routerOverrides()` no se mergean, la app aborta al arrancar (fail-fast).

**Unaliased global providers** (accessed via direct `ref.watch(provider)` — see access categories in MD/APP_PACKAGE_WRAPPER.md):

| Raw provider | Location | Type | Exposed state |
|---|---|---|---|
| `pathProviderProvider` | `core/services/device/path_provider_provider.dart` | `Provider<IPathProviderWrapper>` | File system paths (pure utility) |
| `flutterJailbreakDetectionProvider` | `core/services/device/jailbreak_provider.dart` | `Provider<IJailbreakDetectionWrapper>` | Jailbreak detection (internal) |

---

#### Feature-local providers (`features/<name>/di/`)

The `clinical_history` feature defines its own provider chain in `lib/features/clinical_history/di/clinical_history_provider.dart` (not part of the composition root barrel):

| Provider | Type | Exposed state |
|---|---|---|
| `_clinicalHistoryRemoteDatasourceProvider` (private) | `Provider<IClinicalHistoryRemoteDatasource>` | Remote datasource (`httpServiceProvider` + `appUriesProvider`) |
| `_clinicalHistoryLocalDatasourceProvider` (private) | `Provider<IClinicalHistoryLocalDatasource>` | Local datasource (`clinicalHistoryStoreProvider`) |
| `clinicalHistoryRepositoryProvider` | `Provider<IClinicalHistoryRepository>` | Online-first repository (write-through on remote success, cache fallback only on connectivity failure) |
| `loadClinicalHistoriesUseCaseProvider` | `Provider<LoadClinicalHistoriesUseCase>` | Load use case (remote-first, cache fallback only on connectivity failure) |
| `refreshClinicalHistoriesUseCaseProvider` | `Provider<RefreshClinicalHistoriesUseCase>` | Refresh use case |
| `clinicalHistoryProvider` | `NotifierProvider<ClinicalHistoryNotifier, ClinicalHistoryState>` | Clinical history UI state (codegen provider in `features/clinical_history/presentation/notifiers/`) |
| `clinicalHistoryRefreshErrorProvider` | `NotifierProvider<ClinicalHistoryRefreshError, AppError?>` | Transient error emitted when a pull-to-refresh fails while the list is kept visible (UI-state, codegen in `presentation/notifiers/`) |

Remote endpoint: `appUriesProvider` → `IEndpointConfig.clinicalHistory` (`lib/core/network/api_endpoints.dart`) → `GET /user/clinical-history`.

The `lab_results` feature defines its own provider chain in `lib/features/lab_results/di/lab_results_provider.dart`:

| Provider | Type | Exposed state |
|---|---|---|
| `_labResultsRemoteDatasourceProvider` (private) | `Provider<ILabResultsRemoteDatasource>` | Remote datasource (`httpServiceProvider` + `appUriesProvider`) |
| `_labResultsLocalDatasourceProvider` (private) | `Provider<ILabResultsLocalDatasource>` | Local datasource (`labResultsStoreProvider`) |
| `labResultsRepositoryProvider` | `Provider<ILabResultsRepository>` | Online-first repository (write-through on remote success, cache fallback only on connectivity failure) |
| `loadLabResultsUseCaseProvider` | `Provider<LoadLabResultsUseCase>` | Load use case (remote-first, cache fallback only on connectivity failure) |
| `refreshLabResultsUseCaseProvider` | `Provider<RefreshLabResultsUseCase>` | Refresh use case |
| `labResultsProvider` | `NotifierProvider<LabResultsNotifier, LabResultsState>` | Lab results UI state (codegen provider in `features/lab_results/presentation/notifiers/`) |
| `labResultsPeriodProvider` | `NotifierProvider<LabResultsPeriod, Period>` | Selected period filter (UI-state, codegen in `presentation/notifiers/`) |
| `labResultsRefreshErrorProvider` | `NotifierProvider<LabResultsRefreshError, AppError?>` | Transient error emitted when a pull-to-refresh fails while results stay visible (UI-state, codegen in `presentation/notifiers/`) |

The feature `di/` also re-exports `trendChartProvider`/`ITrendChart`/`TrendChartData` (charts seam) and `loggerProvider` so presentation imports the wrapper seam — never `package:fl_chart`.

Remote endpoint: `appUriesProvider` → `IEndpointConfig.labResults` → `GET /user/clinical-history/lab-results`.

The `auth` feature defines its own provider chain in `lib/features/auth/di/auth_provider.dart` (datasources, ISP-split repositories, and use cases incl. `restoreSessionUseCaseProvider` and `handle401UseCaseProvider`; the composed `_refreshTokenUseCaseProvider` / `_credentialLoginUseCaseProvider` are private to the file).

---

#### Access rule: import providers from `core/` directly

| From | Use | Reason |
|---|---|---|
| Code in `features/` | `ref.watch/read(httpServiceProvider)` etc. | Import the provider from its `core/` source file (e.g. `core/network/dio/dio_providers.dart`); NEVER import `app/` (one-way DI, Rule 11) |

---

#### Method rule: `ref.watch` / `ref.read` / `ref.listen`

| Method | Correct context | Typical error |
|---|---|---|
| `ref.watch` | Functional provider body (`@riverpod` function). `build()` of widget/Notifier when UI must rebuild when value changes | Using it inside callbacks or async Notifier methods → runtime error |
| `ref.read` | Callbacks, `initState`, Notifier methods (one-shot actions without reactivity) | Using it in `build()` of a widget for reactive data → the widget won't rebuild |
| `ref.listen` | `build()` of a Notifier to react to changes without rebuilding. `build()` of a widget for side-effects | Confusing it with `ref.watch`: `listen` only fires the callback, doesn't rebuild |

---

#### Canonical examples by context

**Functional provider — builds a datasource or usecase**
```dart
// CORRECT: ref.watch to declare dependencies
@riverpod
IAuthRemoteDatasource userDatasource(Ref ref) =>
    AuthRemoteDatasourceImpl(
      dio: ref.watch(authDioProvider),
      appUries: ref.watch(appUriesProvider),
    );

@riverpod
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(
      repository: ref.watch(authRepositoryProvider),
      sessionRepository: ref.watch(localAuthRepositoryProvider),
      passwordHasher: ref.watch(passwordHasherProvider),
      tokenStore: ref.watch(tokenStoreProvider),
    );
```

**Notifier — async method (callback)** — token persistence is handled by `LoginUseCase`, not by the notifier. After login the **redirect** navigates declaratively (see deep-linking section); the notifier does NOT navigate.
```dart
// CORRECT: ref.read for one-shot actions
Future<void> doLogin(LoginResponseEntity entity) async {
  final result = await ref.read(loginUseCaseProvider)(
    LoginInput(email: email, password: password, rememberMe: rememberMe),
  );
  await result.fold(
    onSuccess: (data) async {
      state = AuthState.loaded(patient: data.patient, ...);
      // No navigation here: AuthGuard redirect + ?from= sends the user to
      // their deep-link target or the clinical history after login.
    },
    onFailure: (error) async {
      state = AuthState.failure(error);
    },
  );
}

// CORRECT: ref.read in logout
Future<void> logout() async {
  await ref.read(tokenStoreProvider).delete(); // inside core/services/auth/token_providers.dart
}
```

**Root widget build**
```dart
// CORRECT: ref.watch to get the GoRouter instance
final router = ref.watch(goRouterProvider);
routerConfig: router,
```

---

#### GoRouter navigation — Riverpod pattern + IAppNavigator seam

`goRouterProvider` in `app/di/router/router_provider.dart` creates the `GoRouter` instance with `AuthGuard` (deep-link `?from=` restore) and `authenticationObserverProvider` as `refreshListenable`. **Features never import `go_router` types nor `app/`** (Rules 6/11): a feature that navigates imperatively re-exports the `IAppNavigator` seam — `ref.read(appNavigatorProvider).go/push(AppRoute.x)` — where `appNavigatorProvider` (`core/router/app_navigator_provider.dart`) is bound by `routerOverrides()` in the composition root and added as a one-line re-export in the feature's own `di/` file **on-demand**. `features/clinical_history` is the first feature that navigates imperatively (AppBar "Lab Results" action → `AppRoute.labResults`):

```dart
// features/<name>/di/<name>_provider.dart
export 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';
```

```dart
// inside a feature (screen / notifier) — typed, go_router-free
ref.read(appNavigatorProvider).go(AppRoute.clinicalHistory);
```

Auth-flow navigation stays **declarative**: `AuthGuard.redirect` bounces unauthenticated users to `/login?from=<encoded target>` and restores the target after login (deep links included). `goRouterProvider` wires `appRoutes({onLogout})` from the composition root (`router_provider.dart` → `ref.read(authProvider.notifier).logout()`), so cross-feature screens such as `ClinicalHistoryScreen` receive an `onLogout` callback without importing the auth feature.
