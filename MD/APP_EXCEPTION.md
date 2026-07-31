## Exceptions convention

> For the full pattern (guard, fold, call-chain, adding exceptions) see **MD/APP_DARTZ.md**.

The folder `lib/shared/exceptions/` has a barrel (`_exceptions.lib.dart`).

---

### Exception rules (infrastructure / datasource layer only)

- **Throw** via the exception class constructors directly:
  ```dart
  throw ApiException('The server returned an error', statusCode: code);
  throw NoConnectionException('No internet connection');
  throw ServerUnreachableException('Server under maintenance');
  throw UnexpectedResponseException('Unexpected format', details: '...');
  ```
- **Catch** in `result_guard.dart` uses raw class names:
  ```dart
  on ApiException catch (e, st) { ... }
  ```
- When adding a **new** `Exception` class to `shared/exceptions/`, create the file as `part of '_exceptions.lib.dart'` and add the matching `on <Name>Exception catch` branch to `guard()` in `result_guard.dart`.

---

### Imports

Import `shared/error/_error.lib.dart` for `Result<T>`, `Success`, `Failure`, `AppError`, and `localizeError`. Import `shared/exceptions/_exceptions.lib.dart` separately for exception classes:

```dart
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
```
