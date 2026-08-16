## Exceptions convention

> For the full pattern (guard, fold, call-chain, adding exceptions) see **MD/APP_DARTZ.md**.

The folder `lib/shared/exceptions/` has a barrel (`_exceptions.lib.dart`).

---

### Exception rules (infrastructure / datasource layer only)

- **Throw** via the exception class constructors directly (these are the real signatures):
  ```dart
  throw ApiException(e.response!.statusCode ?? 0);
  throw const NoConnectionException();
  throw const ServerUnreachableException();
  throw const UnexpectedResponseException('login response must be a JSON object');
  throw const AppTimeoutException(message: 'The request timed out for /login');
  throw const DeviceSecurityException();
  ```
- **Catch** in `result_guard.dart` uses raw class names:
  ```dart
  on ApiException catch (e, st) { ... }
  ```
- When adding a **new** `Exception` class to `shared/exceptions/`, create the file and export it from `_exceptions.lib.dart`, then add the matching `on <Name>Exception catch` branch to `guard()` in `result_guard.dart`.

#### Exception message conventions

- **English only.** Exception `details` / `toString()` are developer-facing technical messages; the whole codebase must use a single canonical language (English).
- **Never interpolate a raw error object** into a message (e.g. `'$error'`). Use a stable, descriptive detail; the original `StackTrace` is already captured by `guard()` (`result_guard.dart`) into `AppError.stackTrace`.
- **Do not double-wrap** an exception into another exception of the same type (e.g. `DioWrapper` rethrows `UnexpectedResponseException`, `NoConnectionException`, `ServerUnreachableException` as-is; anything else becomes a sanitized `UnexpectedResponseException('Unexpected internal error')`).
- **User-facing strings are never taken from exception messages.** `core/` and `shared/` cannot import `l10n/`. The UI maps `AppError` → localized text via `localizeError()` in `lib/l10n/error_localizer.dart` (add a case there if a new error type reaches the UI). Technical messages only ever surface in debug builds (`app_error_screen.dart` gates `error.toString()` behind `kDebugMode`).
- **`AppError` carries no `userMessage`.** The error type is the single source of truth for localization (`localizeError()` switches by type / `field` tag). `technicalMessage` and `stackTrace` are diagnostic-only and are consumed by the observability seam `ILogger` (`shared/interfaces/`, accessed via `loggerProvider`, re-exported by each feature `di/`) — notifiers log the failure before setting state. Guard-mapping coverage is enforced by `test/architecture/error_mapping_consistency_test.dart`.

### Startup security check (guard/fold)

The jailbreak/root detection at boot follows the same **"guard crea, fold decide"** rule as every boundary:

- `AppInitializer.checkJailbreak()` returns `Future<Result<void>>` — `guard()` wraps the raw `isJailbroken()` shared port and maps `DeviceSecurityException` → `DeviceSecurityError` (it **never throws**).
- `main.dart` `_init()` folds the result: a confirmed `DeviceSecurityError` logs and flips `_securityBlocked` → renders `DeviceSecurityBlockedScreen` (hard-stop, no navigation, no internal details); a detection *failure* (`UnexpectedError`) is logged but does NOT block — only a confirmed jailbreak does.
- Regression-guarded by `test/app/main_security_gate_test.dart`, which asserts zero unhandled exceptions on both paths.

---

### Imports

Import `shared/error/_error.lib.dart` for `Result<T>`, `Success`, `Failure`, `AppError`, and `guard()`. Import `shared/exceptions/_exceptions.lib.dart` separately for exception classes. Import `l10n/error_localizer.dart` for `localizeError()` (UI layer only):

```dart
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/l10n/error_localizer.dart'; // UI layer only
```
