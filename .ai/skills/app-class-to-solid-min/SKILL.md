---
name: app-class-to-solid-min
description: Applies the pattern 5c (DI + Riverpod + Interface) to a plain Dart service class inside lib/shared/functions. Produces abstract interface → concrete implementation → CustomFunction entry → Riverpod Provider. Enforces SOLID fully. Use whenever the user passes a shared service class and asks to apply SOLID, DI, Riverpod, interface, refactor, "option 5c", "apply interface", "transform this service", or any similar request targeting a class in shared/functions.
---

# class_to_solid_min

## Goal

Transform one **service class** from `lib/shared/functions/` into the **5c pattern**:

```
abstract class I<Name>Service          ← contract (domain)
class <Name>Service implements I<Name>  ← concrete implementation
CustomFunction.<name>Service: I<Name>   ← singleton managed by the barrel
<name>ServiceProvider = Provider<I<Name>>  ← exposed via Riverpod
```

---

## Step 0 — Gather context

Identify from the user input or from reading the file:

- **Service name** — e.g. `TokenService` → name token = `token`, interface = `ITokenService`.
- **Methods** — all public methods become the interface contract.

Read these files before touching anything:

```
lib/shared/functions/_function.lib.dart
lib/shared/functions/_function.dart
lib/shared/functions/<name>_service.dart
lib/shared/providers/           ← check if a provider already exists
```

---

## Step 1 — Modify `<name>_service.dart`

**Pattern** (mirror of `internet_service.dart`):

```dart
part of '_function.lib.dart';

abstract class I<Name>Service {
  // one line per public method — return type + signature only, no body
}

class <Name>Service implements I<Name>Service {
  // no private constructor, no static instance field
  // keep all original method bodies intact
  // @override every method declared in the interface
}
```

Rules:
- Remove any `._internal()` constructor, `static final instance`, and `factory` patterns.
- Keep all `static const` fields that are internal implementation details (e.g. `_storage`, `_key`).
- `@override` annotation on **every** method declared in the interface — without exception.
- No comments of any kind (`//`, `/* */`, `///`).

**Real example — `token_service.dart` before:**

```dart
part of '_function.lib.dart';

class TokenService {
  TokenService._internal();
  static final TokenService instance = TokenService._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _key = 'tudesarrollador_auth_token';

  Future<void> save(String token) => _storage.write(key: _key, value: token);
  Future<String?> read() => _storage.read(key: _key);
  Future<void> delete() => _storage.delete(key: _key);
}
```

**After:**

```dart
part of '_function.lib.dart';

abstract class ITokenService {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> delete();
}

class TokenService implements ITokenService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _key = 'tudesarrollador_auth_token';

  @override
  Future<void> save(String token) => _storage.write(key: _key, value: token);
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}
```

---

## Step 2 — Update `_function.dart`

Change the static field type from the concrete class to the abstract interface and the initializer from `<Name>.instance` (or any singleton pattern) to a plain constructor call:

```dart
// before
static final TokenService tokenService = TokenService.instance;

// after
static final I<Name>Service <name>Service = <Name>Service();
```

**Real example after change:**

```dart
part of '_function.lib.dart';

class CustomFunction {
  static final ICpPathProvider pathProvider = CpPathProvider();
  static final ICpSharePlus sharePlus = CpSharePlus();
  static final IInternetService internetService = InternetService();
  static final ITokenService tokenService = TokenService();
  static final ICpDio dio = CpDio(internetService, tokenService);
  static final ICpLogger logger = CpLogger();
  static final ICpDartz dartz = CpDartz();
  static final IFailurePropagation failure = FailurePropagation();
  static final ICpDrift drift = CpDrift(AppDatabase());
}
```

Rules:
- Declared type must be the **abstract interface** (`I<Name>Service`), not the concrete class.
- Initializer is a plain `<Name>Service()` — no `.instance`, no factory trick.
- No comments.

---

## Step 3 — Create the Riverpod provider

> **Only apply this step if the service belongs to the "Injectable service" category** (see `MD/APP_PACKAGE_WRAPPER.md` → "Access categories"). Injectable services: `cp_dio`, `cp_share_plus`, `token_service`. Pure utilities (`cp_dartz`, `failure_propagation`, `cp_logger`) do NOT need a Riverpod provider — skip Steps 3–4 for them.

File: `lib/shared/providers/<name>_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../functions/_function.lib.dart';

part '<name>_provider.g.dart';

@Riverpod(keepAlive: true)
I<Name>Service <name>Service(Ref ref) => CustomFunction.<name>Service;
```

- `@Riverpod(keepAlive: true)` generates `<name>ServiceProvider`.
- Type returned is the **abstract interface**.
- The body returns `CustomFunction.<name>Service` (the static singleton in the barrel).
- No comments.

**Real example — `token_provider.dart`:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../functions/_function.lib.dart';

part 'token_provider.g.dart';

@Riverpod(keepAlive: true)
ITokenService tokenService(Ref ref) => CustomFunction.tokenService;
```

After creating the file, run from the project root:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Then register the new provider in `_providers.lib.dart` (add `import '<name>_provider.dart';` alongside the other `import` declarations — provider files use `@riverpod` and cannot be `part`) and expose it in `CustomProviders` (`_providers.dart`) as a `static final` alias.

---

## Step 4 — Update consumers

Run both searches to find every consumer:

```bash
grep -r "<Name>Service" lib/ --include="*.dart" -l
grep -r "CustomFunction\.<name>Service" lib/ --include="*.dart" -l
```

For each file found (excluding `<name>_service.dart`, `_function.dart`, `_function.lib.dart`, and `<name>_provider.dart`):

### 4a — Riverpod Notifiers (extend `_$<Notifier>` or `AsyncNotifier` — have `ref`)

Replace every `CustomFunction.<name>Service` call with `ref.read(CustomProviders.<alias>)`, where `<alias>` is the static member defined in `CustomProviders` during Step 3:

```dart
// before
await CustomFunction.tokenService.save(user.token);

// after
await ref.read(CustomProviders.token).save(user.token);
```

Add the providers barrel import if not present (never import the individual provider file directly from feature code):

```dart
import '../../../../shared/providers/_providers.lib.dart';
```

Remove the import of `_function.lib.dart` if `CustomFunction` is no longer referenced in that file after the change. An unused import is a warning that fails `flutter analyze`.

### 4b — Infrastructure classes (datasources, repositories — no `ref`)

These classes must **never** call `CustomFunction` directly for injectable services — that is a service-locator anti-pattern that violates **D** (Dependency Inversion). They must receive `I<Name>Service` via constructor injection, exactly as `ICpDio` is injected into datasources via Riverpod.

> Note: `IInternetService` is an **internal dependency of `CpDio` only** — it must never appear as a constructor parameter in feature datasources or repositories. Feature datasources use `ICpDio` for HTTP calls.

```dart
// before — anti-pattern
class EncounterDatasourceImpl implements IEncounterDatasource {
  final ICpDio _dio;
  const EncounterDatasourceImpl(this._dio);

  Future<List<int>> downloadPdf(String id) async {
    final token = await CustomFunction.tokenService.read();
  }
}

// after — constructor injection
class EncounterDatasourceImpl implements IEncounterDatasource {
  final ICpDio _dio;
  final ITokenService _tokenService;
  const EncounterDatasourceImpl(this._dio, this._tokenService);

  Future<List<int>> downloadPdf(String id) async {
    final token = await _tokenService.read();
  }
}
```

Then update the provider or factory that constructs the datasource to pass `ref.watch(<name>ServiceProvider)` as the additional argument.

**Rule — boundary for `CustomFunction`**: `CustomFunction` is the singleton registry. Pure utilities (`dartz`, `failure`, `logger`) may be accessed directly via `CustomFunction.xxx` from any layer — they do not need a Riverpod bridge. Injectable services (`dio`, `token`, `sharePlus`) must always be consumed via `ref.watch/read(CustomProviders.xxx)` — never via `CustomFunction.xxx` directly — so they can be mocked in widget and integration tests through `ProviderScope` overrides. No feature or infrastructure file may import `CustomFunction` for an injectable service.

**Why this matters**: after the provider type changes to `Provider<I<Name>Service>`, any consumer whose constructor still declares `final <Name>Service` (concrete) will fail with `argument_type_not_assignable` because `I<Name>Service` is not assignable to `<Name>Service`. The fix is always to widen the field type to the interface.

---

## Step 5 — Run dart analyze and fix

Run from the project root:
```bash
flutter analyze
```

Read every line. For each error or warning:

1. Open the file reported.
2. Apply the minimal fix.
3. Re-run until output is `No issues found!`.

Common issues and fixes:

| Error | Fix |
|---|---|
| `The type 'I<Name>Service' isn't a class` | Confirm `_function.lib.dart` imports the file containing the interface via `part`. |
| `Undefined name 'I<Name>Service'` | Add the `part` directive in `_function.lib.dart` if the interface is in the same file as the impl. |
| `'<Name>Service.instance' can't be used` | The static member was removed — use `CustomFunction.<name>Service` or the provider instead. |
| `Missing concrete implementation of 'I<Name>Service.<method>'` | Add `@override` + body for the missing method in `<Name>Service`. |
| `argument_type_not_assignable`: `Provider<I<Name>Service>` can't be assigned to `ProviderListenable<<Name>Service>` | A datasource or repository impl still declares its field as `final <Name>Service`. Change the field type to `final I<Name>Service`. This is the Dependency Inversion fix — consumers must depend on the abstraction, not the concrete class. |

---

## Step 6 — SOLID report

After `flutter analyze` returns clean, output this table:

| Principle | ✓/✗ | Justification |
|---|---|---|
| **S** Single Responsibility | ✅ | `I<Name>Service` defines the contract; `<Name>Service` implements it; `CustomFunction` manages lifecycle; the provider exposes it. |
| **O** Open/Closed | ✅ | You can create `Mock<Name>Service implements I<Name>Service` without touching existing code. |
| **L** Liskov Substitution | ✅ | Any implementation of `I<Name>Service` is interchangeable where the provider is used. |
| **I** Interface Segregation | ✅ | The interface declares only the methods its consumers actually need. |
| **D** Dependency Inversion | ✅ | Consumers depend on `I<Name>Service` (abstraction) through the provider, never on `<Name>Service` directly. |

Fill each row with actual evidence from the generated code, not generic text.

---

## Non-negotiable rules

- **No comments** in any generated or modified file (`//`, `/* */`, `///` all forbidden).
- **No `.bak` files** — never create backup copies.
- **No new packages** — the pattern uses only `flutter_riverpod`, which is already a dependency.
- `_function.lib.dart` is updated by `cp_package` when the service file is first created; do not add a duplicate `part` directive. If applying this skill to a manually created service file (not via `cp_package`), first add `part '<name>_service.dart';` to `_function.lib.dart` before running this skill.
- The provider file goes in `lib/shared/providers/`, matching the naming of `token_provider.dart`.

---

## Memory Protocol (Engram)

### After completion — mandatory

```
mem_save(
  title: "SOLID-min applied: <ClassName>",
  type: "decision",
  content: "**What**: Applied pattern 5c (DI + Riverpod + Interface) to <ClassName> in shared/functions. **Why**: <motivation>. **Where**: lib/shared/functions/<name>_service.dart, lib/shared/functions/_function.dart, lib/shared/providers/<name>_provider.dart. **Learned**: <any consumer update gotchas or analyze errors fixed>"
)
```
