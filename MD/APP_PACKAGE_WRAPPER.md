### Package wrappers (`<package>_wrapper.dart`)

All pub packages used inside the app are wrapped in `lib/core/services/` or `lib/core/network/` 
and registered through Riverpod providers. External code always uses `ref.watch/read(ProviderName)`
imported from the provider's `core/` source file — never imports the package directly.

### Wrappers organized by domain

#### Network layer (`core/network/`)

| Wrapper | Interface | Impl class | Access | Riverpod Bridge |
|---|---|---|---|---|
| `dio/dio_wrapper.dart` | `IDioWrapper` | `DioWrapper` | `ref.watch(httpServiceProvider)` | `httpServiceProvider` |
| `interceptors/auth_interceptor.dart` | `IAuthInterceptorProvider` | `AuthInterceptor` | Used internally by `DioWrapper`; do not use from features | — |

#### Services (`core/services/`)

| Domain | Wrapper | Interface | Impl class | Access |
|---|---|---|---|---|
| **auth** | `auth/secure_token_store.dart` | `ITokenStore` | `SecureTokenStore` | `ref.watch(tokenStoreProvider)` |
| **auth** | `auth/secure_credential_store.dart` | `ICredentialStore` | `SecureCredentialStore` | `ref.watch(credentialStoreProvider)` |
| **auth** | `auth/jwt_wrapper.dart` | `IJwtWrapper` | `JwtWrapper` | `ref.watch(jwtWrapperProvider)` — `decodePayload()` (decode sin verificación de firma) |
| **auth** | `auth/jwt_token_expiry_checker.dart` | `ITokenVerifier` | `JwtTokenExpiryChecker` | `ref.watch(tokenVerifierProvider)` — `isExpired()` |
| **crypto** | `crypto/bcrypt_wrapper.dart` | `IPasswordHasher` | `BcryptWrapper` | `ref.watch(passwordHasherProvider)` |
| **device** | `device/path_provider_wrapper.dart` | `IPathProviderWrapper` | `PathProviderWrapper` | `ref.watch(pathProviderProvider)` — pure utility |
| **device** | `device/jailbreak_detection_wrapper.dart` | — | `JailbreakDetectionWrapper` | — (internal, called during app init) |
| **logging** | `shared/interfaces/i_logger.dart` + `core/services/logging/dev_logger.dart` | `ILogger` | `DevLogger` | `ref.watch(loggerProvider)` (from `logging/logging_providers.dart`; re-exported by feature `di/`) — observability seam over `dart:developer log`, swappable for telemetry (e.g. Sentry) |
| **storage** | `storage/secure_storage_wrapper.dart` | `ISecureStorageWrapper` | `SecureStorageWrapper` | — (internal, injected into `SecureTokenStore` and `DatabaseKeyService`) |

#### Shared functions (`lib/shared/functions/`)

| Wrapper | Access | Notes |
|---|---|---|
| `online_first.dart` | Import directly | Online-first repository helper (remote first, cache fallback ONLY on connectivity failure) — `fetchOrFallback({remote, local, onRemoteSuccess})` takes raw closures, owns all `guard()` wrapping internally, returns `OnlineFirstResult<T>` (`Result<T>` + `DataOrigin` remote/cache), and surfaces a failed local read as `Failure` with its stack trace. Write-through is best-effort by policy: the clinical_history repo catches a failed cache write (load y refresh), logs it with stack trace via `ILogger` and still returns the remote data |

---

#### Access categories — critical rule

Each wrapper belongs to a category that determines **how and from where** it can be used.
Mixing categories is an architectural error.

| Category | Wrappers | Correct access from features | Riverpod Bridge |
|---|---|---|---|
| **Pure utility** | `path_provider_wrapper` | `ref.watch(provider)` directly | Provider-level (not via composition root barrel) |
 | **Injectable service** | `dio_wrapper`, `secure_token_store`, `secure_credential_store` | `ref.watch/read(ProviderName)` from its `core/` source file | YES — Riverpod provider in `core/` source file |
| **Internal dependency** | `internet_service`, `secure_storage_wrapper`, `jailbreak_detection_wrapper` | Only inside their consuming wrappers. Never from features | NO |
| **GoRouter (Riverpod)** | `goRouterProvider` | `ref.watch(goRouterProvider)` from `app/di/router/router_provider.dart` (composition root only) | NO — features navigate via the `IAppNavigator` seam (`appNavigatorProvider` re-exported by their `di/` on-demand), never `go_router` |

**Why the injectable vs pure distinction matters:**
- Injectable services (`dio`, `token`, `sembast`) must expose a Riverpod provider from their `core/` source file to
  be overridable with mocks in widget/integration tests via `ProviderScope` overrides.
- Pure utilities (`pathProvider`) don't need runtime substitution;
  accessing them via `ref.watch(provider)` directly is correct and expected.

#### Anti-patterns — what is WRONG

```dart
// WRONG: import a pub package directly in feature code
import 'package:dio/dio.dart';

// WRONG: instantiate a service directly instead of using Riverpod provider
final dio = Dio(BaseOptions(baseUrl: '...')); // should use ref.watch(httpServiceProvider)

// WRONG: import a wrapper's internal dependency from a feature
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
// should never access internet connectivity from features — DioWrapper already handles it

// WRONG: navigate without the IAppNavigator seam
import 'package:go_router/go_router.dart';
context.go('/[feature_name]'); // should be: ref.read(appNavigatorProvider).go(AppRoute.[featureName])
```

---

**Rule: when to create a Riverpod bridge?**

Create a provider co-located with the wrapper (e.g. `lib/core/services/<domain>/<name>_provider.dart`, `lib/core/database/<name>_provider.dart`, `lib/core/network/connectivity/<name>_provider.dart`) when the wrapper needs to be injected into
feature providers via `ref.watch/read`. Not needed for pure functional utilities
or for services that are only internal dependencies of other
wrappers (`internetService`).

---

**`goRouterProvider` pattern in `main.dart` + `IAppNavigator` seam**

`main.dart` uses `ref.watch(goRouterProvider)` to get the `GoRouter` instance directly from Riverpod.
go_router types (`GoRoute`, `RouteBase`) are encapsulated within `app_router.dart` (route table) and `GoRouterNavigator` (the single `IAppNavigator` implementation).
The `goRouterProvider` is defined in `app/di/router/router_provider.dart` and creates the `GoRouter` with `AuthGuard` (deep-link `?from=` restore), `errorBuilder` and `authenticationObserverProvider`:

```dart
// app/di/router/router_provider.dart — CORRECT
final goRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(authenticationObserverProvider);
  const guard = AuthGuard();
  return GoRouter(
    initialLocation: AppRoute.login.path,
    refreshListenable: observer,
    redirect: (context, state) => guard.redirect(
      location: state.matchedLocation,
      from: state.uri.queryParameters['from'],
      isAuthenticated: observer.isAuthenticated,
    ),
    errorBuilder: (context, state) => AppErrorScreen(error: state.error),
    routes: appRoutes(
      onLogout: () => ref.read(authProvider.notifier).logout(),
    ),
  );
});

// main.dart — merge the composition-root seams
ProviderScope(
  overrides: [...dioOverrides(), ...routerOverrides(), ...overrides],
  child: const TudesarrolladorApp(),
),
```

To add a new route: add the `GoRoute` in `lib/app/router/app_router.dart` within `appRoutes()` and add the route name to the `AppRoute` enum in `lib/shared/router/app_route.dart`.

**From features:** a feature that navigates imperatively uses the `IAppNavigator` seam — `ref.read(appNavigatorProvider).go/push(AppRoute.x)` — re-exporting `appNavigatorProvider` from its own `di/` file **on-demand** (see MD/APP_PROVIDERS.md). Never import `go_router` types or `app/` in features.

**Deep linking (go_router):**
- **Native scheme `clinicalhistory`**: configured in `ios/Runner/Info.plist` (`CFBundleURLTypes`) and `android/app/src/main/AndroidManifest.xml` (VIEW intent-filter). Web uses the browser URL directly.
- **Cold start**: go_router's `_effectiveInitialLocation` yields to the platform deep link, so `initialLocation` only applies when there is none.
- **Auth + deep-link restore**: `AuthGuard` bounces unauthenticated users to `/login?from=<encoded path>` and, after login, `refreshListenable` re-runs the redirect which returns the original target (validated against `AppRoute.fromPath`, never `/login` itself — avoids a `redirectLimit` loop).
- **Unknown paths**: `errorBuilder` renders `AppErrorScreen` (`app/widgets/`), 404 localized. The original `state.error` is passed and shown as a copyable detail in debug builds only (`kDebugMode`); the "go home" action navigates through the `appNavigatorProvider` seam (never `go_router` directly).

---

**To add a new package** use the `app-cp-package` skill:
1. `dart pub add <package>` from project root
2. Create wrapper in `lib/core/services/<domain>/<package>_wrapper.dart`
3. Apply the `class_to_solid_min` skill to add an abstract interface and Riverpod provider
4. If the service needs to be injectable from features: define its Riverpod provider in the `core/` source file (feature DI imports it directly)

**When a feature introduces a new package — TDD-first rule (D.0.6):**

If a feature's spec (tasks.md / spec.md) requires a pub package that has no wrapper yet,
the wrapper MUST be created and tested GREEN **before** any feature test is written.
This is enforced by Phase D.0.6 of the Spec-Local orchestrator.

Strict order:
```
1. dart pub add <package>                           ← from project root
2. Write <package>_wrapper_test.dart → run → RED    ← wrapper doesn't exist yet
3. Write <package>_wrapper.dart wrapper → run → GREEN
4. flutter analyze = 0
5. Apply class_to_solid_min (add interface + Riverpod provider)
6. Append ## Wrapper API section to generated_api_contract.md
7. ONLY THEN write feature tests (D.0.1–D.0.5b)
```

**Why:** Presentation and integration test writers need to mock the wrapper interface,
not the raw package. If the wrapper doesn't exist when tests are written, the tests
mock the wrong type and become invalid the moment the wrapper is introduced.

**Packages that cannot be wrapped** (framework infrastructure):
- `flutter_riverpod` / `riverpod_annotation` — UI framework & compile-time annotations; must be imported directly.
- `freezed_annotation` — compile-time annotation library; must be imported directly in every Freezed source file (see below).

**Correct pattern in Freezed source files:**
```dart
// entity or state — imports directly, doesn't use CustomFunction
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const UserEntity._();
  const factory UserEntity({...}) = _UserEntity;
}
```

---

### Plugin maintenance policy

Before adopting any new pub package / plugin, verify it is **maintained**:

1. **Check recency**: last release within ~12 months, and compatible with the project's
   AGP / Kotlin / Flutter versions (the 2026-08-01 incident: `flutter_jailbreak_detection`
   was unmaintained for AGP 8+ and required a fragile reflection hack).
2. **Prefer a maintained fork** if the original package does not evolve:
   `flutter_jailbreak_detection_plus` (maintained fork) is the project's choice —
   it declares `namespace`, `compileSdk 34` and JVM 17 natively, removing the hack.
3. **Keep the wrapper layer intact**: even with a fork, all calls go through the
   `<package>_wrapper.dart` (see `lib/core/services/device/jailbreak_detection_wrapper.dart`).
   The fork swap is then a one-file change, invisible to features.
4. **Audit majors**: dependabot ignores semver-major of
   `flutter_jailbreak_detection_plus`; major bumps require explicit review.
