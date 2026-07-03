### Package wrappers (`cp_<package>.dart`)

All pub packages used inside the app are wrapped in `lib/shared/functions/cp_<package>.dart`
and registered in `CustomFunction`. External code always uses `CustomFunction.xxx` — never
imports the package directly.

### Wrappers that expose a service with interface

| Wrapper | Interface | Impl class | Alias in `CustomFunction` | Riverpod Bridge (`CustomProviders`) |
|---|---|---|---|---|
| `cp_crypto.dart` | `ICpCrypto` | `CpCrypto` | `CustomFunction.crypto` | — (pure utility, SHA-256 hashing) |
| `cp_dio.dart` | `ICpDio` | `CpDio` | `CustomFunction.dio` | `CustomProviders.dio` (`httpServiceProvider`) |
| `cp_fpdart.dart` | `ICpFpdart` | `CpFpdart` | `CustomFunction.fpdart` | — (pure utility) |
| `cp_sembast.dart` | `ICpSembast` | `CpSembast` | `CustomFunction.sembast` | `CustomProviders.sembast` (`sembastProvider`) |
| `cp_encrypt.dart` | `ICpEncrypt` | `CpEncrypt` | `CustomFunction.encrypt` | — (internal dependency of `cp_sembast`, wraps `package:encrypt`, AES-256-CBC) |
| `cp_flutter_secure_storage.dart` | `ICpFlutterSecureStorage` | `CpFlutterSecureStorage` | `CustomFunction.flutterSecureStorage` | — (internal dependency; wraps `flutter_secure_storage`; injected into `TokenService` and `DatabaseKeyService`) |
| `cp_logger.dart` | `ICpLogger` | `CpLogger` | `CustomFunction.logger` | — (internal use between wrappers) |
| `cp_path_provider.dart` | `ICpPathProvider` | `CpPathProvider` | `CustomFunction.pathProvider` | — (pure utility) |
| `cp_share_plus.dart` | `ICpSharePlus` | `CpSharePlus` | `CustomFunction.sharePlus` | — (pure utility, share PDF) |
| `internet_service.dart` | `IInternetService` | `InternetService` | `CustomFunction.internetService` | — (injected into `CpDio`) |
| `token_service.dart` | `ITokenService` | `TokenService` | `CustomFunction.tokenService` | `CustomProviders.token` (`tokenServiceProvider`) |
| `failure_propagation.dart` | `IFailurePropagation` | `FailurePropagation` | `CustomFunction.failure` | — (pure utility) |

`DatabaseKeyService` (`IDatabaseKeyService`) lives in `lib/shared/database/secure_storage_key_service.dart` and is NOT a `cp_*` wrapper — it is part of the `shared/database/` domain.

---

#### Access categories — critical rule

Each wrapper belongs to a category that determines **how and from where** it can be used.
Mixing categories is an architectural error.

| Category | Wrappers | Correct access from features | Riverpod Bridge |
|---|---|---|---|
| **Pure utility** | `cp_crypto`, `cp_fpdart`, `failure_propagation`, `cp_logger`, `cp_path_provider`, `cp_share_plus` | `CustomFunction.xxx` directly | NO |
| **Injectable service** | `cp_dio`, `token_service`, `cp_sembast` | `ref.watch/read(CustomProviders.xxx)` — NEVER `CustomFunction.xxx` directly | YES |
| **Internal dependency** | `internet_service`, `cp_encrypt`, `cp_flutter_secure_storage` | Only inside their consuming wrappers. Never from features | NO |
| **Deferred init** | `cp_go_router` | `CpGoRouter.create(...)` in `main.dart`; `CustomFunction.goRouter.go(...)` from features | NO |

**Why the injectable vs pure distinction matters:**
- Injectable services (`dio`, `token`, `sembast`) must go through `CustomProviders` to
  be overridable with mocks in widget/integration tests via `ProviderScope` overrides.
- Pure utilities (`fpdart`, `failure`, `logger`, `sharePlus`) don't need runtime substitution;
  accessing them via `CustomFunction.xxx` directly is correct and expected.

#### Anti-patterns — what is WRONG

```dart
// WRONG: import a pub package directly in feature code
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

// WRONG: use an injectable service from a notifier without going through Riverpod
await CustomFunction.tokenService.save(token);   // not mockable in tests
await CustomFunction.sembast.database;           // not mockable in tests
await CustomFunction.dio.get(url);               // not mockable in tests

// WRONG: access internetService from a feature (internal dependency of CpDio)
await CustomFunction.internetService.isConnected(); // CpDio already does this internally

// WRONG: access encrypt directly from a feature (internal dependency of CpSembast)
CustomFunction.encrypt.encrypt(text, key); // CpSembast already does this internally

// WRONG: access flutterSecureStorage directly from a feature (internal dependency)
await CustomFunction.flutterSecureStorage.read(key: 'some_key'); // use CustomProviders.token or CustomFunction.sembast

// WRONG: navigate without the wrapper
import 'package:go_router/go_router.dart';
context.go('/[feature_name]'); // should be: CustomFunction.goRouter.go('/[feature_name]')
```

---

**Rule: when to create a Riverpod bridge?**

Create a `shared/providers/<name>_provider.dart` when the wrapper needs to be injected into
feature providers via `ref.watch/read`. Not needed for pure functional utilities
(`fpdart`, `logger`, `failure`, `sharePlus`) or for services that are only internal dependencies of other
wrappers (`internetService`).

---

**`CpGoRouter` initialization pattern in `main.dart`**

`main.dart` uses `CpGoRouter.create(routes:, refreshListenable:)` to build the `GoRouter` — does NOT import `package:go_router` directly.
go_router types (`GoRoute`, `RouteBase`) are encapsulated within `cp_go_router.dart` and `app_routes.dart` (configs).
`main.dart` gets routes via `CustomConfigs.routes.goRouter` and the listenable via `ref.read(CustomProviders.goRouter)`:

```dart
// main.dart — CORRECT
routerConfig: CpGoRouter.create(
  routes: CustomConfigs.routes.goRouter,
  refreshListenable: ref.read(CustomProviders.goRouter),
),
```

> **`CustomFunction.goRouter`** is assigned inside `CpGoRouter.create()` → the `CpGoRouter` constructor receives the already-configured `GoRouter`. Do not try to create a `CpGoRouter` instance directly.

To add a new route to the template: add the `GoRoute` in `shared/configs/app_routes.dart` within `Routes.goRouter`.

---

**To add a new package** use the `cp_package` skill:
1. `dart pub add <package>` from project root
2. Create `lib/shared/functions/cp_<package>.dart` with `part of '_function.lib.dart';`
3. Add the `import 'package:<package>/<package>.dart';` to `_function.lib.dart`
4. Add `part 'cp_<package>.dart';` to `_function.lib.dart`
5. Expose via `static final <Package> <name> = <Package>();` in `CustomFunction`
6. Apply the `class_to_solid_min` skill to add an abstract interface (`I<Package>`) and update the `CustomFunction` field type to the interface type.
7. If the service needs Riverpod injection: create `shared/providers/<name>_provider.dart` + run `build_runner` + add `import '<name>_provider.dart';` to `_providers.lib.dart` (provider files use `@riverpod` so they must be `import`, not `part`) + expose in `CustomProviders` (all covered by `class_to_solid_min` Steps 3–5).

**When a feature introduces a new package — TDD-first rule (D.0.6):**

If a feature's spec (tasks.md / spec.md) requires a pub package that has no `cp_*` wrapper yet,
the wrapper MUST be created and tested GREEN **before** any feature test is written.
This is enforced by Phase D.0.6 of the Spec-Local orchestrator.

Strict order:
```
1. dart pub add <package>                           ← from project root
2. Write cp_<package>_test.dart → run → RED        ← wrapper doesn't exist yet
3. Write cp_<package>.dart wrapper → run → GREEN
4. flutter analyze lib/shared/functions/ = 0
5. Apply class_to_solid_min (add I<Package> interface)
6. Append ## Wrapper API section to generated_api_contract.md
7. ONLY THEN write feature tests (D.0.1–D.0.5b)
```

**Why:** Presentation and integration test writers need to mock the wrapper interface,
not the raw package. If the wrapper doesn't exist when tests are written, the tests
mock the wrong type and become invalid the moment the wrapper is introduced.

**Packages that cannot be wrapped** (framework infrastructure):
- `flutter_riverpod` / `riverpod_annotation` — UI framework & compile-time annotations; must be imported directly.
- `freezed_annotation` — compile-time annotation library; must be imported directly in every Freezed source file (see below).

**Why `cp_freezed.dart` doesn't exist**

`freezed_annotation` cannot be wrapped for three technical reasons:
1. **Annotations must be real types**: `@freezed`, `@Default(...)` must reference the exact classes from the package; a wrapper cannot re-export annotations in a way the compiler recognizes.
2. **The `part` directive requires co-location**: `part 'xxx.freezed.dart'` must be in the same file that imports `freezed_annotation`; it cannot be in `_function.lib.dart`.
3. **Zero runtime behavior**: it's purely metadata for `build_runner`. There is no object, service or function to expose via `CustomFunction`.

Same reasoning applies to `riverpod_annotation` (no `cp_riverpod_annotation.dart` exists).

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
