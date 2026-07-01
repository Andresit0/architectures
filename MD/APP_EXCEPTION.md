## Exceptions & Either/Failure convention

> For the full Either/Failure/fpdart pattern (guard, fold, call-chain, adding Failures) see **MD/APP_DARTZ.md**.

The folder `lib/shared/exceptions/` has a barrel (`_exceptions.lib.dart` + `_exceptions.dart`).

---

### Exception rules (infrastructure / datasource layer only)

- **Throw** using the facade factory methods defined in `CustomExceptions`:
  ```dart
  throw CustomExceptions.usingApi(statusCode);
  throw CustomExceptions.noConnection();
  throw CustomExceptions.serverUnreachable();
  throw CustomExceptions.noRequest(method);
  throw CustomExceptions.unexpectedResponse(details);
  throw CustomExceptions.goRouter(message);
  ```
- **Catch** in `cp_fpdart.dart` uses raw class names (existing exceptions were created before the typedef convention):
  ```dart
  on ApiException catch (e, st) { ... }
  ```
- When adding a **new** `Exception` class to `shared/exceptions/`, follow the checklist in MD/APP_DARTZ.md (Section 7) which includes adding a `typedef` alias in `_exceptions.dart`:
  ```dart
  typedef Custom<Name>Exception = <Name>Exception;
  ```
  Then catch via the typedef: `on Custom<Name>Exception catch (e, st) { ... }`
- Dart's `on` clause requires a type literal — `on CustomExceptions.something` is **invalid syntax**; use the raw class name or its `typedef` alias.

---

### `Either` / `Left` / `Right` availability

`_exceptions.lib.dart` re-exports `Either`, `Left`, and `Right` from fpdart. Any file that imports `_exceptions.lib.dart` gets them automatically. **Never** import `package:fpdart/fpdart.dart` directly.

> For the full import path example and the call-chain see **MD/APP_DARTZ.md** (Section 6).
