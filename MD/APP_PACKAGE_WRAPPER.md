### Package wrappers (`<package>_wrapper.dart`)

All pub packages used inside the app are wrapped in `lib/core/services/` or `lib/core/network/` 
and registered through Riverpod providers. External code always uses `ref.watch/read(ProviderName)`
via the `_providers.lib.dart` barrel — never imports the package directly.

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
| **auth** | `auth/jwt_wrapper.dart` | — | `JwtWrapper` | `ref.watch(jwtWrapperProvider)` |
| **auth** | `auth/jwt_token_expiry_checker.dart` | `ITokenVerifier` | `JwtTokenExpiryChecker` | `ref.watch(tokenVerifierProvider)` |
| **crypto** | `crypto/bcrypt_wrapper.dart` | `IPasswordHasher` | `BcryptWrapper` | `ref.watch(passwordHasherProvider)` |
| **device** | `device/path_provider_wrapper.dart` | `IPathProviderWrapper` | `PathProviderWrapper` | `ref.watch(pathProviderProvider)` — pure utility |
| **device** | `device/jailbreak_detection_wrapper.dart` | — | `JailbreakDetectionWrapper` | — (internal, called during app init) |
| **storage** | `storage/secure_storage_wrapper.dart` | `ISecureStorageWrapper` | `SecureStorageWrapper` | — (internal, injected into `SecureTokenStore` and `DatabaseKeyService`) |

#### Shared functions (`lib/shared/functions/`)

| Wrapper | Access | Notes |
|---|---|---|
| `offline_first_repository.dart` | Import directly | Offline-first CRUD mixin for repositories |

---

#### Access categories — critical rule

Each wrapper belongs to a category that determines **how and from where** it can be used.
Mixing categories is an architectural error.

| Category | Wrappers | Correct access from features | Riverpod Bridge |
|---|---|---|---|
| **Pure utility** | `path_provider_wrapper` | `ref.watch(provider)` directly | Provider-level (not via composition root barrel) |
 | **Injectable service** | `dio_wrapper`, `secure_token_store`, `secure_credential_store` | `ref.watch/read(ProviderName)` via `_providers.lib.dart` | YES — composition root barrel |
| **Internal dependency** | `internet_service`, `secure_storage_wrapper`, `jailbreak_detection_wrapper` | Only inside their consuming wrappers. Never from features | NO |
| **GoRouter (Riverpod)** | `goRouterProvider` | `ref.watch(goRouterProvider)` from `app/di/router/router_provider.dart` | NO — accessed via `ref.watch(goRouterProvider)` directly in `main.dart` and features |

**Why the injectable vs pure distinction matters:**
- Injectable services (`dio`, `token`, `sembast`) must go through `_providers.lib.dart` to
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

// WRONG: navigate without the goRouter provider
import 'package:go_router/go_router.dart';
context.go('/[feature_name]'); // should be: ref.read(goRouterProvider).go('/[feature_name]')
```

---

**Rule: when to create a Riverpod bridge?**

Create a provider co-located with the wrapper (e.g. `lib/core/services/<domain>/<name>_provider.dart`, `lib/core/database/<name>_provider.dart`, `lib/core/network/connectivity/<name>_provider.dart`) when the wrapper needs to be injected into
feature providers via `ref.watch/read`. Not needed for pure functional utilities
or for services that are only internal dependencies of other
wrappers (`internetService`).

---

**`goRouterProvider` pattern in `main.dart`**

`main.dart` uses `ref.watch(goRouterProvider)` to get the `GoRouter` instance directly from Riverpod.
go_router types (`GoRoute`, `RouteBase`) are encapsulated within `app_router.dart` and `app_route.dart`.
The `goRouterProvider` is defined in `app/di/router/router_provider.dart` and creates the `GoRouter` with `AuthGuard` and `authenticationObserverProvider`:

```dart
// app/di/router/router_provider.dart — CORRECT
final goRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(authenticationObserverProvider);
  const guard = AuthGuard();
  return GoRouter(
    initialLocation: '/',
    refreshListenable: observer,
    redirect: (context, state) => guard.redirect(...),
    routes: appRoutes(),
  );
});

// main.dart
routerConfig: ref.watch(goRouterProvider),
```

To add a new route: add the `GoRoute` in `lib/app/router/app_router.dart` within `appRoutes()` and add the route name to the `AppRoute` enum in `lib/app/router/app_route.dart`.

**From features:** use `ref.read(goRouterProvider).go('/path')` or `ref.read(goRouterProvider).push('/path')` to navigate.

---

**To add a new package** use the `app-cp-package` skill:
1. `dart pub add <package>` from project root
2. Create wrapper in `lib/core/services/<domain>/<package>_wrapper.dart`
3. Apply the `class_to_solid_min` skill to add an abstract interface and Riverpod provider
4. If the service needs to be injectable from features: add to `_providers.lib.dart` barrel

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
