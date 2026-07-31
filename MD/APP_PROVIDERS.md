### Providers — usage rules

Global providers are defined in `lib/core/` and `lib/app/di/`.
The `_providers.lib.dart` barrel in `lib/app/di/` is the complete composition root — it exports all 10 shared providers directly.

---

#### Inventory of global providers

All `keepAlive: true` — never discarded from memory.

| Provider | Location | Type | Exposed state |
|---|---|---|---|
| `httpServiceProvider` | `app/di/network/dio_provider.dart` | `Provider<IDioWrapper>` | HTTP singleton (Dio) WITH auth interceptor (401 retry + force logout) |
| `authDioProvider` | `app/di/network/dio_provider.dart` | `Provider<IDioWrapper>` | Dio WITHOUT auth interceptor. Used by AuthRemoteDatasource for login/refresh where no token exists yet |
| `tokenStoreProvider` | `core/services/auth/token_providers.dart` | `Provider<ITokenStore>` | Token storage singleton |
| `appDatabaseProvider` | `core/database/app_database_provider.dart` | `Provider<IAppDatabase>` | Sembast database instance (AES-256-CBC encrypted) |
| `internetServiceProvider` | `core/network/connectivity/connectivity_providers.dart` | `Provider<IInternetService>` | Internet connectivity checker |
| *(removed)* `errorPropagation` | *(removed)* | Error propagation replaced by `localizeError()` in `shared/error/error_localizer.dart` — UI layer calls `localizeError(error, AppLocalizations.of(context)!)` |
| `clinicalHistoryStoreProvider` | `core/database/tables/clinical_history.dart` | `Provider<IClinicalHistoryStore>` | Clinical history store |
| `patientInfoStoreProvider` | `core/database/tables/patient_info.dart` | `Provider<IPatientInfoStore>` | Patient info store |
| `passwordHasherProvider` | `core/services/crypto/password_hasher_provider.dart` | `Provider<IPasswordHasher>` | Password hashing (bcrypt) |
| `connectivityCheckerProvider` | `core/network/connectivity/connectivity_providers.dart` | `Provider<IConnectivityChecker>` | Connectivity check abstraction |
| `tokenVerifierProvider` | `core/services/auth/token_providers.dart` | `Provider<ITokenVerifier>` | JWT token verification |
| `credentialStoreProvider` | `core/services/auth/token_providers.dart` | `Provider<ICredentialStore>` | Credential storage (remember-me) |
| `jwtWrapperProvider` | `core/services/auth/token_providers.dart` | `Provider<IJwtWrapper>` | JWT utility wrapper |
| `environmentProvider` | `core/config/environment_provider.dart` | `Provider<AppEnvironment>` | App environment config |

**Unaliased global providers** (accessed via direct `ref.watch(provider)` — see access categories in MD/APP_PACKAGE_WRAPPER.md):

| Raw provider | Location | Type | Exposed state |
|---|---|---|---|
| `pathProviderProvider` | `core/services/device/path_provider_provider.dart` | `Provider<IPathProviderWrapper>` | File system paths (pure utility) |
| `flutterJailbreakDetectionProvider` | `core/services/device/jailbreak_provider.dart` | `Provider<IJailbreakDetectionWrapper>` | Jailbreak detection (internal) |

---

#### Access rule: import from `_providers.lib.dart`

| From | Use | Reason |
|---|---|---|
| Code in `features/` | `ref.watch/read(httpServiceProvider)` etc. | Import from `_providers.lib.dart` barrel; never import the provider file directly |

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
IAuthDatasource userDatasource(Ref ref) =>
    AuthDatasourceImpl(ref.watch(httpServiceProvider));

@riverpod
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(
      repository: ref.watch(authRepositoryProvider),
      passwordHasher: ref.watch(passwordHasherProvider),
      tokenStore: ref.watch(tokenStoreProvider),
    );
```

**Notifier — async method (callback)** — token persistence is handled by `LoginUseCase`, not by the notifier
```dart
// CORRECT: ref.read for one-shot actions
Future<void> doLogin(LoginResponseEntity entity) async {
  final result = await ref.read(loginUseCaseProvider).call(
    email: email,
    password: password,
    rememberMe: rememberMe,
  );
  await result.fold(
    onSuccess: (data) async {
      state = AuthState.loaded(patient: data.patient, ...);
      ref.read(goRouterProvider).go('/clinical_history');
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

#### GoRouter navigation — Riverpod pattern

`goRouterProvider` in `app/di/router/router_provider.dart` creates the `GoRouter` instance with `AuthGuard` and `authenticationObserverProvider` as `refreshListenable`. From features, use `ref.read(goRouterProvider).go('/path')` or `ref.read(goRouterProvider).push('/path')` to navigate — never import `go_router` package types in feature code.

The router observes `authProvider` directly — `GoRouterListenable` was removed. From the notifier, navigate via `ref.read(goRouterProvider).go('/path')`.
