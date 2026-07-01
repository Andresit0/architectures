# APP_DARTZ.md — Either / Failure / fpdart pattern

> Quick reference for working with `Either<Failure, T>`, `CpFpdart`, exceptions
> and the full error-handling chain across the clean-architecture layers.
>
> Package: [`fpdart`](https://pub.dev/packages/fpdart) — replaces `dartz`.

---

## 1. Core rule per layer

| Layer | Rule |
|---|---|
| `cp_dio.dart` | Throws typed exceptions (`ApiException`, `NoConnectionException`, …) |
| **Datasource impl** | Raw call only — **no try/catch**, lets exceptions propagate up |
| **Repository impl** | Wraps datasource with `CustomFunction.fpdart.guard(...)` → `Either<Failure, T>` |
| **Repository interface** | Declares `Future<Either<Failure, T>>` return types |
| **UseCase** | Passes `Either<Failure, T>` through unchanged — no logic |
| **Notifier** | Calls `.fold(onFailure, onSuccess)` — **no try/catch** |

---

## 2. `guard()` — creates the Either (repository layer)

`guard` is the **only** place exceptions are caught and converted to `Left(Failure)`.

```dart
// repository impl
@override
Future<Either<Failure, UserEntity>> login({...}) =>
    CustomFunction.fpdart.guard(
      () => _datasource.login(...),
    );
```

Exception → Failure mapping inside `guard`:

```
ApiException               → Left(ApiFailure())
NoConnectionException      → Left(NoConnectionFailure())
ServerUnreachableException → Left(ServerUnreachableFailure())
NoRequestException         → Left(NoRequestFailure())
UnexpectedResponseException→ Left(UnexpectedResponseFailure())
GoRouterException          → Left(GoRouterFailure())
catch (e)                  → Left(UnexpectedFailure())   ← safety net
```

---

## 3. `fold()` — consumes the Either (notifier layer)

```dart
final result = await ref.read(useCaseProvider).call(...);
state = result.fold(
  (failure) => switch (failure) {
    ApiFailure()               => MyFailureState(failure.message),
    NoConnectionFailure()      => const MyFailureState('No connection'),
    ServerUnreachableFailure() => const MyFailureState('Under maintenance'),
    _                          => MyFailureState(failure.message),
  },
  (data) => MySuccessState(data),
);
```

When the success branch is async:

```dart
await result.fold<Future<void>>(
  (failure) async { state = _mapFailure(failure); },
  (data) async {
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

## 5. `FailurePropagation.launch()` — optional helper

Avoids writing a `switch` on `Failure` in every notifier:

```dart
state = result.fold(
  (failure) => CustomFunction.failure.launch<MyState>(
    failure,
    onFailure: (msg) => MyFailureState(msg),
  ),
  (data) => MySuccessState(data),
);
```

---

## 6. `Either` / `Left` / `Right` imports

**Never** import `package:fpdart/fpdart.dart` directly.  
`_exceptions.lib.dart` re-exports these types — import it once:

```dart
import '../../../../shared/exceptions/_exceptions.lib.dart';
// Either, Left, Right, Failure and all CustomXxxFailure typedefs available
```

---

## 7. Adding a new Failure type (checklist)

> The existing failure classes (`ApiFailure`, `NoConnectionFailure`, etc.) use their raw class names in switch patterns and `on` clauses — they predate the typedef convention. Follow the steps below **only when creating a new Failure type**.

1. Create `<name>_failure.dart` in `shared/exceptions/`:
   ```dart
   part of '_exceptions.lib.dart';
   class MyFailure extends Failure {
     const MyFailure(String message) : super(message);
   }
   ```
2. Add `part '<name>_failure.dart';` to `_exceptions.lib.dart`.
3. Add `typedef CustomMyFailure = MyFailure;` to `_exceptions.dart`.
4. Add `static MyFailure myFailure(...) => MyFailure(...);` factory to `CustomExceptions`.
5. Add the matching `on CustomMyException` branch to `CpFpdart.guard()` in `cp_fpdart.dart` (new exceptions use the `typedef` alias — see `APP_EXCEPTION.md`).

---

## 8. Call-chain summary (read top to bottom)

```
Notifier.someMethod()
  ├── state = Loading
  ├── result = await useCase.call(...)      // Either<Failure, T>
  │     └── repository.someMethod(...)
  │           └── CpFpdart.guard(
  │                 () => datasource.someMethod()   ← can throw
  │               )
  │                 ├── OK  → Right(data)
  │                 └── err → Left(Failure)
  │
  └── state = result.fold(
        Left(failure)  → FailureState(failure.message),
        Right(data)    → SuccessState(data),
      )
```
