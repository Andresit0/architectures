# APP_DARTZ.md — Result / guard / fold pattern

> Quick reference for working with `Result<T>`, `guard()`, exceptions
> and the full error-handling chain across the clean-architecture layers.

---

## 1. Core rule per layer

| Layer | Rule |
|---|---|---|
| `core/network/dio/dio_wrapper.dart` | Throws typed exceptions (`ApiException`, `NoConnectionException`, …) |
| **Datasource impl** | Raw call only — **no try/catch**, lets exceptions propagate up |
| **Repository impl** | Wraps datasource with `guard(...)` → `Result<T>`. |
| **Repository interface** | Declares `Future<Result<T>>` return types |
| **UseCase** | Passes `Result<T>` through unchanged — uses `is Success` / `is Failure` to branch |
| **Notifier** | Calls `.fold(onFailure, onSuccess)` — **no try/catch** |

---

## 2. `guard()` — creates the Result (repository layer)

`guard` is the **only** place exceptions are caught and converted to `Failure(AppError)`.

```dart
// repository impl
@override
Future<Result<UserEntity>> login({...}) =>
    guard(
      () => _datasource.login(...),
    );
```

Exception → AppError mapping inside `guard` (defined in `lib/shared/error/result_guard.dart`):

```
ApiException               → Failure(ApiError())
NoConnectionException      → Failure(NetworkError())
ServerUnreachableException → Failure(ServerUnreachableError())
UnexpectedResponseException→ Failure(UnexpectedError())
AppTimeoutException        → Failure(NetworkError())
TimeoutException (dart:async) → Failure(NetworkError())
Error                      → Failure(UnexpectedError())   ← catches Error + Exception
```

---

## 3. `fold()` — consumes the Result (notifier layer)

```dart
final result = await ref.read(useCaseProvider).call(...);
state = result.fold(
  onFailure: (error) => switch (error) {
    ApiError()               => MyFailureState(error.message),
    NetworkError()           => const MyFailureState('No connection'),
    ServerUnreachableError() => const MyFailureState('Under maintenance'),
    _                        => MyFailureState(error.message),
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
> `guard` → repository (infrastructure) — speaks in exceptions.  
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
import 'package:clean_architecture_sdd_harness/shared/error/error_localizer.dart';
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
   part of '_exceptions.lib.dart';
   class MyException implements Exception {
     const MyException(this.message);
     final String message;
   }
   ```
2. Add `part '<name>_exception.dart';` to `_exceptions.lib.dart`.
3. Add the matching `on MyException catch` branch to `guard()` in `result_guard.dart`.

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
  └── state = result.fold(
        onFailure(error) → FailureState(error.message),
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

if (await _tokenExpiryChecker.isExpired(data.token.key)) {
  if (await _connectivityChecker.isConnected()) {
    return _tryRefresh(data);
  }
}
return Success(data);
```
