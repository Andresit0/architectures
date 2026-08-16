---
name: app-class-to-solid
description: Transforms a plain Dart class into the full Dependency Injection + Abstraction with Riverpod pattern used in this project (interface → impl → repository → usecase → provider → notifier). Enforces SOLID principles and runs dart analyze to fix all issues. Use whenever the user passes a class and asks to convert it, apply SOLID, add DI, add Riverpod, refactor to clean architecture, or says "transform it", "apply SOLID", "DI with Riverpod", "clean architecture", etc.
---

# class_to_solid

## Goal

Take **one input class** (datasource, service, repository, or any business-logic class) and produce a complete **Dependency Injection + Abstraction with Riverpod** set of files matching this project's architecture, then validate SOLID compliance and run `dart analyze`.

---

## Step 0 — Read input

Ask the user to paste the class if they haven't already. Identify:

- **Feature name** (e.g. `auth`, `encounter`, `payment`).
- **Layer** the class belongs to (`datasource`, `repository`, `usecase`, or `service`).
- **Entity** it works with (infer from field/method types if not stated).

If the feature already has files (use `file_search` / `grep_search`), read them before generating to avoid conflicts.

---

## Step 1 — Apply pattern 5: DI + Abstraction with Riverpod

### Target file tree (feature = `<feature>`, entity = `<Entity>`)

```
lib/features/<feature>/
  domain/
    datasources/
      i_<feature>_datasource.dart      ← abstract class
    entities/
      <feature>_entity.dart            ← plain Dart entity (if missing)
    repositories/
      i_<feature>_repository.dart      ← abstract class
    usecases/
      <feature>_usecase.dart           ← orchestrates repository
  infrastructure/
    datasources/
      <feature>_datasource_impl.dart   ← implements i_<feature>_datasource
    mappers/
      <feature>_mapper.dart            ← fromJson / toJson (if HTTP involved)
    repositories/
      <feature>_repository_impl.dart   ← implements i_<feature>_repository
  presentation/
    notifiers/
      <feature>_state.dart             ← sealed class states (Equatable)
      <feature>_notifier.dart          ← @riverpod class extending _$…
    providers/
      <feature>_providers.dart         ← @riverpod wiring datasource→repo→usecase
```

### Canonical examples (copy exact style, no comments)

#### `domain/datasources/i_<feature>_datasource.dart`
```dart
import '../entities/<feature>_entity.dart';

abstract interface class I<Feature>Datasource {
  Future<<Feature>Entity> <primaryMethod>({required String param});
}
```

#### `domain/repositories/i_<feature>_repository.dart`
```dart
import '../../../../shared/error/_error.lib.dart';
import '../entities/<feature>_entity.dart';

abstract interface class I<Feature>Repository {
  Future<Result<<Feature>Entity>> <primaryMethod>({required String param});
}
```

#### `domain/usecases/<feature>_usecase.dart`
```dart
import '../../../../shared/error/_error.lib.dart';
import '../../../../shared/interfaces/i_usecase.dart';
import '../entities/<feature>_entity.dart';
import '../repositories/i_<feature>_repository.dart';

class <Feature>UseCase implements IUseCase<<Feature>Input, <Feature>Entity> {
  const <Feature>UseCase({required I<Feature>Repository repository})
      : _repository = repository;

  final I<Feature>Repository _repository;

  @override
  Future<Result<<Feature>Entity>> call(<Feature>Input input) =>
      _repository.<primaryMethod>(param: input.param);
}
```

> **UseCase → UseCase (Rule 18):** si este usecase orquesta OTRO usecase, el parámetro es `IUseCase<In, Out>` (nunca la clase concreta), y el provider concreto se inyecta solo en `features/<name>/di/`.
> **1 clase = 1 contrato (Rule 19b):** el repository impl implementa UNA sola interfaz de dominio. Si el feature necesita roles remote/local, se crean dos interfaces (`I<Feature>RemoteRepository`/`I<Feature>LocalRepository`) y dos impls separados.

#### `infrastructure/datasources/<feature>_datasource_impl.dart`
```dart
import '../../domain/datasources/i_<feature>_datasource.dart';
import '../../domain/entities/<feature>_entity.dart';

class <Feature>DatasourceImpl implements I<Feature>Datasource {
  const <Feature>DatasourceImpl();

  @override
  Future<<Feature>Entity> <primaryMethod>({required String param}) async {
    // real implementation
  }
}
```

#### `infrastructure/repositories/<feature>_repository_impl.dart`
```dart
import '../../../../shared/error/_error.lib.dart';
import '../../domain/datasources/i_<feature>_datasource.dart';
import '../../domain/entities/<feature>_entity.dart';
import '../../domain/repositories/i_<feature>_repository.dart';

class <Feature>RepositoryImpl implements I<Feature>Repository {
  final I<Feature>Datasource _datasource;

  const <Feature>RepositoryImpl(this._datasource);

  @override
  Future<Result<<Feature>Entity>> <primaryMethod>({required String param}) =>
      guard(() => _datasource.<primaryMethod>(param: param));
}
```

#### `di/<feature>_providers.dart` (moved from `presentation/providers/`)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/datasources/i_<feature>_datasource.dart';
import '../../domain/repositories/i_<feature>_repository.dart';
import '../../domain/usecases/<feature>_usecase.dart';
import '../../infrastructure/datasources/<feature>_datasource_impl.dart';
import '../../infrastructure/repositories/<feature>_repository_impl.dart';

part '<feature>_providers.g.dart';

@riverpod
I<Feature>Datasource <feature>Datasource(Ref ref) =>
    <Feature>DatasourceImpl();

@riverpod
I<Feature>Repository <feature>Repository(Ref ref) =>
    <Feature>RepositoryImpl(ref.watch(<feature>DatasourceProvider));

@riverpod
<Feature>UseCase <feature>UseCase(Ref ref) =>
    <Feature>UseCase(ref.watch(<feature>RepositoryProvider));
```

#### `presentation/notifiers/<feature>_state.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/<feature>_entity.dart';

part '<feature>_state.freezed.dart';

@freezed
sealed class <Feature>State with _$<Feature>State {
  const factory <Feature>State.initial() = <Feature>Initial;
  const factory <Feature>State.loading() = <Feature>Loading;
  const factory <Feature>State.success(<Feature>Entity <entity>) = <Feature>Success;
  const factory <Feature>State.failure(String message) = <Feature>Failure;
}
```

After creating this file run `build_runner` (Step 4) to generate `<feature>_state.freezed.dart`.

#### `presentation/notifiers/<feature>_notifier.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/<feature>_providers.dart';
import '<feature>_state.dart';

part '<feature>_notifier.g.dart';

@riverpod
class <Feature>Notifier extends _$<Feature>Notifier {
  @override
  <Feature>State build() => const <Feature>Initial();

  Future<void> <primaryMethod>({required String param}) async {
    state = const <Feature>Loading();
    final result = await ref.read(<feature>UseCaseProvider).call(param: param);
    await result.fold<Future<void>>(
      (failure) async {
        state = <Feature>Failure(failure);
      },
      (data) async {
        state = <Feature>Success(data);
      },
    );
  }

  void reset() => state = const <Feature>Initial();
}
```

---

## Step 2 — SOLID audit

After generating all files, verify each principle:

| Principle | Check |
|-----------|-------|
| **S** Single Responsibility | Each class has one reason to change. Datasource only fetches; repository only delegates; usecase only orchestrates. |
| **O** Open/Closed | New behaviour via new implementations, not by modifying existing ones. Interfaces are extension points. |
| **L** Liskov Substitution | `Impl` classes are substitutable for their abstract types. No method throws `UnimplementedError`. |
| **I** Interface Segregation | Each interface declares only the methods that its consumers actually use. No fat interfaces. |
| **D** Dependency Inversion | High-level classes (`UseCase`, `RepositoryImpl`) depend on abstractions (`I*`), never on concretions. Riverpod providers wire concretions at the edge. Un usecase que orquesta otro usecase depende de `IUseCase<In, Out>`, nunca de la clase concreta (Rule 18). |

If a violation is found, fix it before moving on.

---

## Step 3 — Code rules (non-negotiable)

- **No comments** in generated code (`//`, `/* */`, `///` all forbidden).
- **No `.bak` files** — never create backup copies.
- Constructor injection only — dependencies via constructor parameters, never as setters or globals.
- No `late` fields for injected dependencies.
- `const` constructors wherever all fields are final and the class has no non-const parents.
- `sealed` + `@freezed` for state hierarchies — import `freezed_annotation` directly in `<feature>_state.dart` (cannot be wrapped; see `MD/APP_PACKAGE_WRAPPER.md`).
- `part` / `part of` in feature files only for generated `.g.dart` and `.freezed.dart` files. Never manually declare `part` relationships in domain, infrastructure, or presentation files generated by this skill. (Barrel files in `shared/` do use `part of` — that is handled by the `barrel` skill, not here.)

---

## Step 4 — Build & analyze

Run these commands in order from the project root:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Read every line of output. For each error or warning:

1. Open the reported file.
2. Apply the minimal fix.
3. Re-run `flutter analyze` until the output is `No issues found!`.

If `build_runner` reports conflicts, check for stale `.g.dart` and `.freezed.dart` files and delete them before re-running.

---

## Step 5 — Summary

Report to the user:

1. List of files created / modified with their workspace-relative paths as markdown links.
2. SOLID findings (one line per principle: ✓ pass or what was fixed).
3. `flutter analyze` final status.

---

## Memory Protocol (Engram)

### After completion — mandatory

```
mem_save(
  title: "SOLID applied: <ClassName>",
  type: "decision",
  content: "**What**: Transformed <ClassName> into full DI + Abstraction + Riverpod pattern (interface → impl → repository → usecase → provider → notifier). **Why**: <motivation>. **Where**: lib/features/<feature>/domain/, lib/features/<feature>/infrastructure/, lib/features/<feature>/presentation/. **Learned**: <any SOLID violations found and fixed, or Freezed/build_runner gotchas>"
)
```
