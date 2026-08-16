---
name: app-class-to-solid-min
description: Applies DI + Riverpod + Interface pattern to a Dart service class inside lib/core/services/. Produces abstract interface → concrete implementation → barrel entry → Riverpod Provider (en `*_providers.dart` en `core/`). Enforces SOLID fully. Use whenever the user passes a service class and asks to apply SOLID, DI, Riverpod, interface, refactor, "apply interface", "transform this service", or any similar request targeting a class in core/services/.
---

# class_to_solid_min

## Goal

Transform one **service class** from `lib/core/services/` into the DI + Riverpod pattern:

```
abstract interface class I<Name>Service          ← contract
class <Name>Service implements I<Name>  ← concrete implementation
<name>ServiceProvider = Provider<I<Name>Service>  ← Riverpod provider (en `core/services/<domain>/<name>_provider.dart`, Rule 20)
```

---

## Step 0 — Gather context

Identify from the user input or from reading the file:

- **Service name** — e.g. `SecureCredentialStore` → name credentialStore = `credentialStore`, interface = `ICredentialStore`.
- **Domain** — subdirectory under `core/services/` (e.g. `auth`, `crypto`, `device`, `logging`, `storage`).
- **Methods** — all public methods become the interface contract.
- **Access category** — `MD/APP_PACKAGE_WRAPPER.md` → "Access categories": injectable service, pure utility, or internal dependency.

Read these files before touching anything:

```
lib/core/services/<domain>/<name>_service.dart
lib/core/services/_services.lib.dart
lib/core/services/<domain>/<name>_provider.dart   ← check if a provider already exists
```

---

## Step 1 — Modify `<name>_service.dart`

Rename the existing file to `i_<name>_service.dart` for the interface and create or keep `<name>_service.dart` for the implementation. The interface and impl may also live in the same file (convention: `<domain>/<name>_wrapper.dart`).

> **Separación DI/implementación (Rule 20):** los Riverpod providers van en un archivo `*_providers.dart` dedicado (p. ej. `core/services/auth/token_providers.dart`), nunca embebidos en la clase de servicio/impl.

**Pattern**:

```dart
// i_<name>_service.dart — standalone library (not part of any barrel)
abstract interface class I<Name>Service {
  // one line per public method — return type + signature only, no body
}

```

```dart
// <name>_service.dart (or <name>_wrapper.dart)
import 'i_<name>_service.dart';

class <Name>Service implements I<Name>Service {
  // keep all original method bodies intact
  // @override every method declared in the interface
}
```

Rules:
- Remove any `._internal()` constructor, `static final instance`, and `factory` patterns.
- Keep all `static const` fields that are internal implementation details (e.g. `_storage`, `_key`).
- `@override` annotation on **every** method declared in the interface — without exception.
- No comments of any kind (`//`, `/* */`, `///`).
- Files are standalone libraries in `lib/core/services/<domain>/` — they are NOT `part of` any barrel.

**Real example — `ICredentialStore` / `SecureCredentialStore`:**

Cross-cutting contracts live in `lib/shared/interfaces/` (pure Dart) and are exported by `_interfaces.lib.dart` (Rule 26). The impl stays in `core/services/`:

```dart
// lib/shared/interfaces/i_credential_store.dart  (exported by _interfaces.lib.dart)
abstract interface class ICredentialStore {
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  });
  Future<({String email, String passwordHash})?> readCredentials();
  Future<void> deleteCredentials();
}
```

```dart
// lib/core/services/auth/secure_credential_store.dart
import 'package:clean_architecture_sdd_harness/core/services/storage/secure_storage_wrapper.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class SecureCredentialStore implements ICredentialStore {
  const SecureCredentialStore({required ISecureStorageWrapper storage}) : _storage = storage;

  final ISecureStorageWrapper _storage;
  static const String _emailKey = 'tudesarrollador_login_email';
  static const String _passwordHashKey = 'tudesarrollador_login_pwhash';

  @override
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordHashKey, value: passwordHash);
  }

  @override
  Future<({String email, String passwordHash})?> readCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final pwhash = await _storage.read(key: _passwordHashKey);
    if (email == null || pwhash == null) return null;
    return (email: email, passwordHash: pwhash);
  }

  @override
  Future<void> deleteCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordHashKey);
  }
}
```

---

## Step 2 — Create Riverpod provider

Create a provider file in `lib/core/services/<domain>/` (or the appropriate subdirectory):

**For injectable services** (must be mockable in tests):

```dart
// lib/core/services/<domain>/<name>_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clean_architecture_sdd_harness/core/services/<domain>/i_<name>_service.dart';
import 'package:clean_architecture_sdd_harness/core/services/<domain>/<name>_service.dart';

part '<name>_provider.g.dart';

@Riverpod(keepAlive: true)
I<Name>Service <name>Service(Ref ref) => <Name>Service();
```

After creating the file, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Register the provider in its `core/` source file (e.g. `lib/core/services/<domain>/<name>_provider.dart`). `app/` y los tests importan el provider directamente desde `core/` (no hay barrel en `app/di/`). Feature DI imports core provider files DIRECTLY — never `app/` (one-way dependency, Rule 11).

For pure utilities, create a simple provider without a dedicated facade:

```dart
// lib/core/services/<domain>/<name>_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clean_architecture_sdd_harness/core/services/<domain>/i_<name>_service.dart';
import 'package:clean_architecture_sdd_harness/core/services/<domain>/<name>_service.dart';

final <name>ServiceProvider = Provider<I<Name>Service>((ref) => <Name>Service());
```

---

## Step 3 — Update barrel files

Add ONLY the implementation file to `lib/core/services/_services.lib.dart`:

```dart
export '<domain>/<name>_service.dart';
```

(If the interface and impl are in the same file, only one `export` line is needed.)

> **Rule 26 — never re-export shared interfaces:** `_services.lib.dart` must NOT `export` files from `shared/interfaces/` (e.g. `i_credential_store.dart`, `i_token_verifier.dart`). Each folder's barrel owns its symbols. `shared/interfaces/` is imported exclusively through `_interfaces.lib.dart`.

**Where does the interface go?**
- **Cross-cutting contract** (consumed by 2+ bounded contexts or by `core/`): `lib/shared/interfaces/i_<name>_service.dart`, exported by `_interfaces.lib.dart`.
- **Feature-local contract**: stays inside the feature's `domain/`, never in any barrel.
- The impl always lives in `lib/core/services/<domain>/` (or the feature's `infrastructure/` for feature contracts).

---

## Step 4 — Update consumers

Find every consumer by searching for direct usage of the concrete class:

```bash
grep -r "<Name>Service" lib/ --include="*.dart" -l
```

For each file found (excluding the service files themselves and the provider file):

### 4a — Riverpod Notifiers (have `ref`)

Replace direct constructor calls with `ref.watch(<name>ServiceProvider)`:

```dart
// before
final service = <Name>Service();
await service.someMethod();

// after
await ref.read(<name>ServiceProvider).someMethod();
```

Add the provider import from its `core/` source file if not present:

```dart
import 'package:clean_architecture_sdd_harness/core/services/<domain>/<name>_provider.dart';
```

### 4b — Infrastructure classes (datasources, repositories — no `ref`)

These classes must **never** call concrete constructors directly — that is a service-locator anti-pattern that violates **D** (Dependency Inversion). They must receive the abstract interface via constructor injection:

```dart
// before — anti-pattern
class MyDatasourceImpl implements IMyDatasource {
  Future<Data> fetch() async {
    final service = <Name>Service();
    return service.getData();
  }
}

// after — constructor injection
class MyDatasourceImpl implements IMyDatasource {
  final I<Name>Service _service;
  const MyDatasourceImpl(this._service);

  Future<Data> fetch() async {
    return _service.getData();
  }
}
```

Then update the provider/factory that constructs the datasource to pass `ref.watch(<name>ServiceProvider)` as the argument.

**Rule — provider access**: No feature or infrastructure file may use static locators for services — they must use `ref.watch(<name>Provider)`. See `MD/APP_PACKAGE_WRAPPER.md` for the access category table.

**Why this matters**: after the provider type changes to `Provider<I<Name>Service>`, any consumer whose constructor still declares `final <Name>Service` (concrete) will fail with `argument_type_not_assignable`. The fix is always to widen the field type to the interface.

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
| `The type 'I<Name>Service' isn't a class` | Confirm the import to the interface file is correct. |
| `Undefined name 'I<Name>Service'` | Add the import for the interface. |
| `'<Name>Service.instance' can't be used` | The static member was removed — use `ref.watch(<name>ServiceProvider)` instead. |
| `Missing concrete implementation of 'I<Name>Service.<method>'` | Add `@override` + body for the missing method in `<Name>Service`. |
| `argument_type_not_assignable`: `Provider<I<Name>Service>` can't be assigned to `ProviderListenable<<Name>Service>` | A datasource or repository impl still declares its field as `final <Name>Service`. Change the field type to `final I<Name>Service`. This is the Dependency Inversion fix — consumers must depend on the abstraction, not the concrete class. |

---

## Step 6 — SOLID report

After `flutter analyze` returns clean, output this table:

| Principle | ✓/✗ | Justification |
|---|---|---|
| **S** Single Responsibility | ✅ | `I<Name>Service` defines the contract; `<Name>Service` implements it; el provider vive en `core/services/<domain>/<name>_provider.dart` (Rule 20: DI separado de la implementación). |
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
- `_services.lib.dart` in `lib/core/services/` may need to be updated with new exports — impls only, NEVER shared interfaces (Rule 26).
- The provider file goes in `lib/core/services/<domain>/` for services or the appropriate subdirectory.
- Injectable services must expose a Riverpod provider from their `core/` source file (feature DI imports it directly).

---

## Memory Protocol (Engram)

### After completion — mandatory

```
mem_save(
  title: "SOLID-min applied: <ClassName>",
  type: "decision",
  content: "**What**: Applied DI + Riverpod + Interface to <ClassName> in core/services. **Why**: <motivation>. **Where**: lib/core/services/<domain>/<name>_service.dart, lib/core/services/<domain>/<name>_provider.dart. **Learned**: <any consumer update gotchas or analyze errors fixed>"
)
```
