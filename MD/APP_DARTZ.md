# APP_DARTZ.md — Result / guard / fold pattern

> Quick reference for working with `Result<T>`, `guard()`, exceptions
> and the full error-handling chain across the clean-architecture layers.

---

## 1. Core rule per layer

| Layer | Rule |
|---|---|---|
| `core/network/dio/dio_wrapper.dart` | Orquesta 3 colaboradores inyectados (interface+impl): `RequestExecutor` (llamada dio + parse + error mapping + retry-timeout), `ErrorMapper` (`isBrowserNetworkFailure` + mapeo `DioException` → typed exceptions), `RetryExecutor` (política `retryOnTimeout/maxRetries/baseDelay` → `AppTimeoutException`). **Throws typed exceptions** (`ApiException`, `NoConnectionException`, …) — el wrapper público solo rellena `pathParams` y delega. |
| **Datasource impl** | Raw call only — **no try/catch**, lets exceptions propagate up |
| **Repository impl** | Wraps datasource with `guard(...)` → `Result<T>`. |
| **Repository interface** | Declares `Future<Result<T>>` return types |
| **UseCase** | Passes repository `Result<T>` through unchanged — uses `is Success` / `is Failure` to branch. **Wraps shared ports** (`shared/interfaces/` that return raw values like `String?`, `bool`, `void`, records) with `guard(...)` → `Result<T>`. |
| **Notifier** | Calls `.fold(onFailure, onSuccess)` — **no try/catch** |

---

## 2. `guard()` — creates the Result (boundary layer)

`guard` is the **only** place exceptions are caught and converted to `Failure(AppError)`. It wraps **every fallible boundary**:

- **Repository impl** wraps datasource calls (datasource throws typed exceptions).
- **UseCase** wraps shared ports that return raw values (e.g. `ITokenStore.read()`, `IConnectivityChecker.isConnected()`, `ICredentialStore.readCredentials()`, `IPasswordHasher.hash()`, `ITokenVerifier.isExpired()`). A thrown exception here would otherwise escape the `Result` chain and reach the notifier.
- **App composition root** wraps startup ports too: `AppInitializer.checkJailbreak()` returns `Future<Result<void>>` via `guard(() async { if (await detection.isJailbroken()) throw const DeviceSecurityException(); })`; `main.dart` folds and hard-stops only on `DeviceSecurityError`.

```dart
// repository impl
@override
Future<Result<UserEntity>> login({...}) =>
    guard(
      () => _datasource.login(...),
    );

// usecase — wrapping a shared port that returns a raw value
final hashResult = await guard(() => _passwordHasher.hash(validatedPassword.value));
if (hashResult case Failure(:final error)) {
  return Failure(error);
}
```

Exception → AppError mapping inside `guard` (defined in `lib/shared/error/result_guard.dart`):

```
ApiException               → Failure(ApiError(technicalMessage: 'HTTP <code>'))
NoConnectionException      → Failure(NetworkError())
ServerUnreachableException → Failure(ServerUnreachableError())
UnexpectedResponseException→ Failure(UnexpectedError(technicalMessage: details))
AppTimeoutException        → Failure(TimeoutError(technicalMessage: message))
TimeoutException (dart:async) → Failure(TimeoutError(technicalMessage: message))
Error                      → RETHROWN (fail-fast)   ← programming errors are NOT swallowed
```

> **Online-first / timeout**: a `TimeoutError` is NOT network-related (`isNetworkRelated == false`). A slow/unresponsive server must NOT trigger the offline fallback — `fetchOrFallback` only falls back to cache on `NetworkError` / `ServerUnreachableError`.
>
> **Transient / retry**: `AppError.isTransient` is `true` for `NetworkError`, `ServerUnreachableError` and `TimeoutError`. `Handle401UseCase` reads `error.isTransient` (not a manual `is` dispatch) to decide whether a failed refresh/re-login keeps the session (`RetryNoConnection`, no logout) or forces logout (`RetryFailed`). `AppError` carries **no user-facing message** — the UI localizes by type via `localizeError()`.

> **Fail-fast rule**: `guard()` only maps `Exception` → `AppError`. Programming errors (`TypeError`, `StateError`, `ArgumentError`, …) propagate — they indicate bugs and must surface, not be hidden as `UnexpectedError`.
>
> **`fetchOrFallback` owns the boundary**: `shared/functions/online_first.dart` takes raw closures (`remote`, `local`, `onRemoteSuccess`) and wraps all three with `guard()` internally — callers must NOT pre-wrap. A failed local read (the cache is the offline source of truth) is surfaced as `Failure` with its stack trace, never masked by the remote error. It returns `OnlineFirstResult<T>` (`Result<T>` + `DataOrigin` remote/cache).
>
> **Write-through contract vs repo policy**: if `onRemoteSuccess` throws an `Exception` the helper surfaces `Failure` (fail-fast mode, tested in `online_first_test.dart`). The clinical_history repo (load y refresh) is **best-effort**: `ClinicalHistoryRepositoryImpl._storeCache` catches the `Exception`, logs it with its `stackTrace` via the injected `ILogger` (`'[clinical_history] cache write failed (load|refresh)'`), and returns the remote data (`Success`) — `Error` rethrows. Deliberate deviation from the boundary rule (availability over integrity, decided with product).

> **Message conventions**: exception `details` are developer-facing, **English only**, and never interpolate a raw error object (`'$error'`). User-facing strings come exclusively from `localizeError()` in `lib/l10n/` (see `MD/APP_EXCEPTION.md`).

> **No-lossy mapping**: `guard()` preserves the diagnostic payload in `technicalMessage` — `ApiError` carries the HTTP code (`'HTTP <code>'`) and `TimeoutError` carries the timeout `message`. `ApiError` exposes **no** `statusCode` field (it was write-only dead metadata); the code flows to the `ILogger` observability seam via `technicalMessage`.

---

## 3. `fold()` — consumes the Result (notifier layer)

```dart
final result = await ref.read(useCaseProvider).call(...);
state = result.fold(
  onFailure: (error) => switch (error) {
    ApiError()               => MyFailureState(error),
    NetworkError()           => const MyFailureState('No connection'),
    ServerUnreachableError() => const MyFailureState('Under maintenance'),
    _                        => MyFailureState(error),
  },
  onSuccess: (data) => MySuccessState(data),
);
```

When the success branch is async:

```dart
state = await result.fold<Future<void>>(
  onFailure: (error) async { state = _mapFailure(error); },
  onSuccess: (data) async {
    await someAsyncOperation();
    state = MySuccessState(data);
  },
);
```

---

## 4. Golden rule

> **`guard` creates, `fold` decides.**  
> `guard` → every fallible boundary (repository wraps datasources; usecase wraps shared ports that return raw values) — speaks in exceptions.  
> `fold` → notifier (presentation) — speaks in UI states.  
> Neither invades the other's territory.

---

## 5. `localizeError()` — UI-level localization

`AppError` is passed to state directly. The UI layer maps it to localized strings via `localizeError()`:

```dart
// Notifier — passes AppError to state
state = result.fold(
  onFailure: (error) => MyFailureState(error),
  onSuccess: (data) => MySuccessState(data),
);

// UI Screen — localizes the AppError for display
ref.listen<MyState>(myProvider, (_, state) {
  state.maybeWhen(
    failure: (error) {
      final msg = localizeError(error, AppLocalizations.of(context)!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    },
    orElse: () {},
  );
});
```

Import:
```dart
import 'package:clean_architecture_sdd_harness/l10n/error_localizer.dart';
```

---

## 6. `Result` / `Success` / `Failure` imports

Import `_error.lib.dart` from the feature layer:

```dart
import '../../../../shared/error/_error.lib.dart';
// Result, Success, Failure, AppError and all subclasses available
```

Import `shared/exceptions/_exceptions.lib.dart` separately for exception classes (ApiException, NoConnectionException, etc.).

---

## 7. Adding a new Exception type (checklist)

1. Create `<name>_exception.dart` in `shared/exceptions/`:
   ```dart
   class MyException implements Exception {
     const MyException(this.message);
     final String message;
   }
   ```
2. Add `export '<name>_exception.dart';` to `_exceptions.lib.dart` (the exceptions barrel uses `export` for its standalone files, see `MD/APP_BARREL_PATTERN.md`).
3. Add the matching `on MyException catch` branch to `guard()` in `result_guard.dart`.

> **Exceptions to the checklist — programming errors (`Error`):** types that extend
> `Error` (e.g. `SeamNotBoundException`, thrown by unbound DI seams) are
> **deliberately NOT added** to `guard()` — `guard()` only catches `Exception`, so an
> `Error` propagates and fails fast (a missing DI binding must never surface as a
> `Failure`). The consistency guard (`test/architecture/error_mapping_consistency_test.dart`)
> enforces this via its `_programmingErrors` set (asserts `extends Error` and no
> `_canonicalMapping` entry). See `MD/APP_EXCEPTION.md`.

---

## 8. Call-chain summary (read top to bottom)

```
Notifier.someMethod()
  ├── state = Loading
  ├── result = await useCase.call(...)      // Result<T>
  │     └── repository.someMethod(...)
  │           └── guard(
  │                 () => datasource.someMethod()   ← can throw
  │               )
  │                 ├── OK  → Success(data)
  │                 └── err → Failure(AppError)
  │
  │     └── shared port call inside the usecase (e.g. tokenStore.read())
  │           └── guard(
  │                 () => _tokenStore.read()         ← can throw
  │               )
  │                 ├── OK  → Success(data)
  │                 └── err → Failure(AppError)
  │
  └── state = result.fold(
        onFailure(error) → FailureState(error),   ← UI localizes via localizeError()
        onSuccess(data)  → SuccessState(data),
      )
```

## 9. Composing Results in a UseCase

Use `is Success` / `is Failure` (NOT `fold`) when a UseCase needs to inspect intermediate results:

```dart
final result = await _repository.restoreSession();
if (result is Failure) return result;  ← propagate unchanged

final data = (result as Success).data;
if (data == null) return const Success(null);

// Shared ports that return raw values are wrapped with guard()
final expiredResult = await guard(() => _tokenVerifier.isExpired(data.token.key));
final expired = switch (expiredResult) {
  Success(data: final value) => value,
  Failure() => false, // cannot verify → do not refresh, keep cache
};
if (expired) {
  final onlineResult = await guard(() => _connectivityChecker.isConnected());
  final online = switch (onlineResult) {
    Success(data: final value) => value,
    Failure() => false, // unknown connectivity → treat as offline
  };
  if (online) {
    return _tryRefresh(data);
  }
}
return Success(data);
```

> **Dos idiomas de consumo (decisión):** usa **switch-expression** cuando exista un default sensato para `Failure` (p. ej. `connectivity` → `false`; un `Failure` de connectivity se trata como offline). Usa **early-return + `(x as Success<T>).data`** cuando debas propagar el error (validaciones: `Email.result()`, `Password.result()`). `Result<T>` no expone `.data` en la base sealed, así que el cast tras el guard de `Failure` es el patrón idiomático; no reemplazarlo por `switch` con `throw StateError('unreachable')` (ruido defensivo).

---

## 10. Value Objects — single validated API (`result()`)

Every VO (`Email`, `Password`, `PasswordHash`, …) exposes **exactly two** construction paths:

| Path | Purpose |
|---|---|
| `static Result<X> result(String value)` | **THE validated factory.** Builds from untrusted input; returns `Failure(ValidationError(…))` (with a `field:` tag when the UI localizes it) or `Success(X)`. No exceptions, no `null`. |
| `const factory X.raw(String value)` | **Trusted construction** (freezed-generated). Only for inputs already validated elsewhere: mappers, test fixtures / mock fallbacks. Bypasses `_validate`. |

```dart
// usecase — validate untrusted input via result()
final emailResult = Email.result(email);
if (emailResult case Failure(:final error)) return Failure(error);

// widget form validator — boolean check
if (!Email.result(value).isSuccess) return l10n.errorInvalidEmail;

// test / mock fallback — trusted value, no validation
registerFallbackValue(Email.raw('fallback@test.com'));
```

**Why only `result()`?** The previous `create()` (threw `FormatException`) and `tryCreate()` (returned `null`) were redundant with `result()` and lost the error payload: `result()` keeps the `field` tag (`'email'` / `'password'`) that `localizeError()` maps to a localized string (`ValidationError` itself carries no user-facing message). It also keeps every failure inside the `Result` chain — no exceptions, no null-checks. VOs build `Result` directly (never via `guard()` — they are pure and do not catch exceptions).

---

## 11. UseCase — uniform contract (`IUseCase<Input, Output>`)

Every use case implements the shared marker `IUseCase<Input, Output>` from `lib/shared/interfaces/i_usecase.dart`:

```dart
abstract interface class IUseCase<Input, Output> {
  Future<Result<Output>> call(Input input);
}

class NoParams { const NoParams(); }
```

- **Input** is a feature-local input object (e.g. `LoginInput`, `RefreshTokenInput`) or `NoParams` for no-argument use cases.
- **Output** is always wrapped in `Result` — a use case NEVER throws.
- The single `call(Input)` signature makes every use case uniformly injectable, testable and decorable.

> **DIP entre usecases (enforced by Rule 18):** a use case that orchestrates another use case (e.g. `RestoreSessionUseCase` → `CredentialLoginUseCase` / `RefreshTokenUseCase`) injects the **abstraction** `IUseCase<Input, Output>`, never the concrete class:

```dart
class RestoreSessionUseCase implements IUseCase<NoParams, LoginResponseEntity?> {
  const RestoreSessionUseCase({
    required IUseCase<NoParams, LoginResponseEntity?> credentialLoginUseCase,
    required IUseCase<RefreshTokenInput, TokenEntity> refreshTokenUseCase,
  }) : _credentialLoginUseCase = credentialLoginUseCase,
       _refreshTokenUseCase = refreshTokenUseCase;

  final IUseCase<NoParams, LoginResponseEntity?> _credentialLoginUseCase;
  final IUseCase<RefreshTokenInput, TokenEntity> _refreshTokenUseCase;
}
```

The concrete `*UseCaseProvider` is wired only at the composition root (`features/<name>/di/`); the concrete value is assignable to the `IUseCase` parameter.

```dart
class LoginUseCase implements IUseCase<LoginInput, LoginResponseEntity> {
  @override
  Future<Result<LoginResponseEntity>> call(LoginInput input) async { ... }
}

// call site (notifier)
final result = await ref.read(loginUseCaseProvider)(LoginInput(email: e, password: p, rememberMe: r));
```

> **Canonical Result policy (enforced by Rule 17a/17b in `test/architecture/dependency_rules_test.dart`):** every public method of `domain/repositories/*` returns `Future<Result<...>>`, and every use case implements `IUseCase`. Datasource interfaces are intentionally NOT Result-returning: they are the exception layer — datasource impls throw typed exceptions that the repository translates with `guard()` (golden rule, §1).

---

## 12. Decision — Shared Kernel entities: NO validated factories

**Decisión registrada (2026-08):** las entidades del Shared Kernel (`PatientEntity`, `ClinicalHistoryEntity` + sub-entidades, `LabResultEntity` + sub-entidades) son **modelos de wire/persistencia** y NO tienen factories validadas (`result()`/`create()`). Se mantienen anémicas a propósito.

**Razón:** la única frontera de input no confiable de la app es el formulario de login, ya cubierta por los VOs (`Email.result()`, `Password.result()`, `PasswordHash.result()`, §10). `PatientEntity`/`ClinicalHistoryEntity`/`LabResultEntity` llegan desde la propia API (DTO → mapper) y la propia DB (serializer) — contratos controlados por la app. La forma del wire ya se valida en el mapper (`AuthMapper`/`ClinicalHistoryMapper`/`LabResultsMapper` — ver §13 — lanzan excepciones tipadas que `guard()` mapea). Añadir "no vacío" a las entidades sería validación decorativa: los serializers/mappers usan el `const factory` (no existe `raw` en entidades), por lo que la invariante sería bypasseable en las dos rutas reales de entrada de datos.

**Cuándo re-evaluar (condiciones para agregarlas):**
1. La API deja de ser propia / el contrato viene de un tercero sin SLA de schema.
2. Aparecen ≥2 puntos de construcción desde input no confiable (hoy son 3: `AuthMapper`, `ClinicalHistoryMapper` y `LabResultsMapper`).
3. Surge una regla de negocio real (p. ej. "una historia clínica debe tener ≥1 diagnóstico"), no un mero "no vacío". En ese caso la validación debe vivir **en la frontera** (mapper DTO→Entity), no en una factory decorativa.

---

## 13. Third construction point — `LabResultsMapper` (DTO → Entity)

**Decisión registrada (2026-08):** se añadió un tercer punto de construcción de entidades del Shared Kernel: `LabResultsMapper` (`features/lab_results/infrastructure/mappers/`). Igual que `AuthMapper`/`ClinicalHistoryMapper`, convierte wire DTO → Entity usando **named constructors** (`raw`-equivalentes, sin validación decorativa) — las entidades `LabResultEntity`/`LabResultValueEntity`/`LabResultReferenceRangeEntity` siguen anémicas (ver §12) y el mapper es la frontera que valida la forma del wire (excepciones tipadas que `guard()` mapea). El guard de consistencia es `test/core/database/lab_results_serializer_test.dart` (round-trip con discriminador `LabResultKind`).
