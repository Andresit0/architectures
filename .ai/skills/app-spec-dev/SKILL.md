---
name: app-spec-dev
description: Implements a complete Flutter feature from a Spec-Definer spec folder. Reads all six artifacts (spec.md, domain.md, contracts.md, bdd.feature, tests.md, tasks.md) and produces every code file (domain, infrastructure, presentation, barrel, navigation) plus unit tests, widget tests, and integration tests following strict TDD order (stub → RED → implement → GREEN for each layer). Runs build_runner, dart analyze, and flutter test until zero issues. Use whenever you have a completed spec folder and want the full implementation generated end-to-end.
---

# Spec-Dev Skill

## Role

A fully autonomous implementing agent. Given a spec folder path, it reads all six artifacts and produces the complete working feature: code, barrel files, navigation wiring, and all three test tiers (unit, widget, integration). Tests are written **before** the implementation they cover (TDD Red → Green).

---

## Phase 0 — Context gathering and planning

### 0.1 Read all spec files

```
<spec_folder>/spec.md       ← business rules, flows, edge cases
<spec_folder>/domain.md     ← entities, state variants, interfaces, usecases, notifier pattern
<spec_folder>/contracts.md  ← HTTP endpoint, headers, response shape, timeout
<spec_folder>/bdd.feature   ← Gherkin scenarios → drives integration tests
<spec_folder>/tests.md      ← unit + widget + integration test plan
<spec_folder>/tasks.md      ← implementation checklist
```

### 0.2 Load project context

Read these MD files directly to understand the project:

- `MD/APP_ARCHITECTURE.md` — feature layer structure and folder conventions
- `MD/APP_DARTZ.md` — Result/guard/fold pattern (guard, fold, AppError types)
- `MD/APP_IMPORTANT_INFO.md` — critical rules and project constraints
- `MD/APP_TREE.md` — current app directory tree
- `MD/APP_PROVIDERS.md` — shared providers (dio, token, connectivity) + `IAppNavigator` seam
- `MD/APP_STATE_MANAGMENT.md` — Riverpod v2 state management conventions
- `MD/APP_PACKAGE_WRAPPER.md` — wrapper pattern and access categories
- `MD/APP_EXCEPTION.md` — exception types and CustomFunction.failure.launch() pattern

### 0.3 Read reference feature code

Read the auth feature as canonical example:
- `lib/features/auth/domain/entities/login_response_entity.dart`
- `lib/features/auth/infrastructure/datasources/auth_datasource_impl.dart`
- `lib/features/auth/infrastructure/repositories/auth_remote_repository_impl.dart`
- `lib/features/auth/presentation/notifiers/auth_state.dart`
- `lib/features/auth/presentation/notifiers/auth_notifier.dart`
- `lib/features/auth/di/auth_provider.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/widgets/<widget_name>.dart`  ← standalone (no barrel, no facade)
- `integration_test/auth_integration_test.dart` ← integration test pattern

### 0.4 Create TodoWrite task list

Convert every unchecked item in `tasks.md` into a todo. Track progress with the TodoWrite tool throughout execution.

---

## TDD execution model

**ALL tests are written FIRST (Phase 0.5), before any implementation code.**

The correct sequence is:

```
Phase 0   — Context gathering (read specs, reference feature, TodoWrite)
Phase 0.5 — Canonical API extraction → generated_api_contract.md
Phase 0.6 — Package Audit + Wrapper TDD (pub add → test RED → *_wrapper.dart GREEN) [BEFORE feature tests]
Phase 0.1 through 0.5b — Write ALL feature tests (domain, infra, presentation, integration, BDD)
            → Presentation tests use wrapper mocks (IFlChart, etc.) not raw package mocks
            → Tests cannot run yet because stubs don't exist
Phase 1   — Domain entities + build_runner
Phase 2   — Domain STUBS only (no test writing) → run tests → RED
Phase 3   — Domain implementation → GREEN
Phase 4   — Infrastructure STUBS only → run tests → RED
Phase 5   — Infrastructure implementation → GREEN
Phase 6   — State + notifier STUB + providers + codegen → run presentation tests → RED
Phase 7   — Confirm presentation tests are RED (written in Phase 0.5)
Phase 8   — Presentation implementation → GREEN (uses CustomFunction.<wrapper> from Phase 0.6)
Phase 9   — Confirm integration test (written in Phase 0.5) → analyze RED (nav not wired)
Phase 9.5 — Confirm BDD tests (written in Phase 0.5) → GREEN (fake notifiers)
Phase 10  — Barrels + navigation → analyze GREEN
Phase 11  — Final verification
```

Entity files (Freezed data classes) are an exception: they require build_runner before tests can compile, so entity tests PASS immediately after build_runner runs.

---

## Phase 0.5 — All Tests First (MANDATORY, before Phase 1)

**This phase creates ALL test files for the feature, derived from spec files only. No production code exists at this point.**

> ⚠️ **Read `generated_api_contract.md` before writing any test, including the `## Wrapper API` section populated at Phase 0.6. Presentation and integration tests MUST use the wrapper interfaces (e.g. mock `IFlChart`, stub `lineChart()` to return `SizedBox.shrink()`) — NEVER mock the raw package class.**

### 0.5.1 Verify no production code exists yet

```bash
ls lib/features/<feature_name>/domain/ 2>/dev/null || echo "GOOD: no domain code yet"
ls lib/features/<feature_name>/presentation/ 2>/dev/null || echo "GOOD: no presentation code yet"
```

If production code already exists → spec-dev was run partially before. Check what exists and skip writing tests that already exist. Continue from Phase 1.

### 0.5.2 Write domain tests (from domain.md + tests.md)

Derive method signatures from `domain.md`. Do NOT read any production file — none exist.

Create:
- `test/features/<feature_name>/domain/<feature_name>_usecase_test.dart`
- `test/features/<feature_name>/domain/<feature_name>_entity_test.dart`

Use the patterns in Phase 2 section below. At this point, these files will have **compile errors** (imports resolve to nothing) — that is EXPECTED and CORRECT.

### 0.5.3 Write presentation tests (from domain.md + tests.md + ## Wrapper API)

Derive state variants, notifier method signatures, and provider names from `domain.md`. Read the `## Wrapper API` section of `generated_api_contract.md` for wrapper interfaces. Do NOT read any production file.

Create:
- `test/features/<feature_name>/presentation/notifiers/<feature_name>_notifier_test.dart`
- `test/features/<feature_name>/presentation/screens/<feature_name>_screen_test.dart`
- `test/features/<feature_name>/presentation/widgets/<feature_name>_widget_test.dart`

**Wrapper mock rule:** For any wrapper used in the presentation layer, mock its interface in the test — not the raw package. Example:
```dart
class _MockFlChart extends Mock implements IFlChartWrapper {}
// In test: when(() => mockFlChart.lineChart(any())).thenReturn(const SizedBox.shrink());
```

Use the patterns in Phase 7 section below.

### 0.5.4 Write integration test (from bdd.feature + domain.md)

Derive repository interface and method signatures from `domain.md`. Derive scenarios from `bdd.feature`. Do NOT read any production file.

Create:
- `integration_test/<feature_name>_integration_test.dart`

Use the template in Phase 9 section below.

### 0.5.5 Write infrastructure tests (from domain.md + tests.md)

Derive datasource interface methods and repository interface methods from `domain.md`. Do NOT read any production file.

Create:
- `test/features/<feature_name>/infrastructure/<feature_name>_datasource_test.dart`
- `test/features/<feature_name>/infrastructure/<feature_name>_repository_test.dart`

**Datasource test pattern:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/<feature_name>/domain/datasources/i_<feature_name>_datasource.dart';
import 'package:app/features/<feature_name>/infrastructure/datasources/<feature_name>_datasource_impl.dart';
// IDioWrapper, ICredentialStore, etc. are injected via Riverpod providers — no import needed here.

class _MockDio extends Mock implements IDioWrapper {}
class _MockCredentialStore extends Mock implements ICredentialStore {}

void main() {
  late _MockDio dio;
  late _MockCredentialStore credentialStore;
  late <Name>DatasourceImpl datasource;

  setUp(() {
    dio = _MockDio();
    credentialStore = _MockCredentialStore();
    datasource = <Name>DatasourceImpl(dio: dio, credentialStore: credentialStore);
  });

  group('<Name>DatasourceImpl', () {
    test('<methodName> returns data when HTTP call succeeds', () async {
      when(() => tokenService.read()).thenAnswer((_) async => 'token');
      when(() => dio.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => <fixture_json>);

      final result = await datasource.<methodName>(<args>);

      expect(result, isNotNull);
    });
  });
}
```

**Repository test pattern:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

import 'package:app/features/<feature_name>/domain/datasources/i_<feature_name>_datasource.dart';
import 'package:app/features/<feature_name>/domain/repositories/i_<feature_name>_repository.dart';
import 'package:app/features/<feature_name>/infrastructure/repositories/<feature_name>_repository_impl.dart';

class _MockDatasource extends Mock implements I<Name>Datasource {}

void main() {
  late _MockDatasource datasource;
  late <Name>RepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = <Name>RepositoryImpl(datasource);
  });

  group('<Name>RepositoryImpl', () {
    test('returns Success when datasource succeeds', () async {
      when(() => datasource.<methodName>(<args>)).thenAnswer(
        (_) async => <fixture_data>,
      );

      final result = await repository.<methodName>(<args>);

      expect(result.isSuccess, isTrue);
    });

    test('returns Failure when datasource throws', () async {
      when(() => datasource.<methodName>(<args>)).thenThrow(Exception('error'));

      final result = await repository.<methodName>(<args>);

      expect(result.isSuccess, isFalse);
    });
  });
}
```

At this point, these files will have **compile errors** (imports resolve to nothing) — that is EXPECTED and CORRECT.

### 0.5.6 Write BDD test file (from bdd.feature + domain.md)

Derive state variants and provider names from `domain.md`. Derive scenarios from `bdd.feature`. Use fake notifiers based on spec only.

Create:
- `test/bdd/<feature_name>_bdd_test.dart`

Use the template in Phase 9.5 section below.

### 0.5.7 Gate check — ALL 5 test tiers must exist

```bash
ls test/features/<feature_name>/domain/
ls test/features/<feature_name>/infrastructure/
ls test/features/<feature_name>/presentation/
ls integration_test/<feature_name>_integration_test.dart
ls test/bdd/<feature_name>_bdd_test.dart
```

**If any tier is missing → STOP → create it → do NOT proceed to Phase 1.**

> ℹ️ Phase 0.6 (Package Audit + wrapper TDD) runs BEFORE Phase 0.5 (test writing) when using the orchestrator. When running spec-dev standalone, Phase 0.6 runs right after this gate check.

---

## Phase 0.6 — Package Audit + Wrapper TDD (MANDATORY, after Phase 0.5, before Phase 1)

> ℹ️ **This phase is executed by the orchestrator (D.0.6) BEFORE the feature test writers run.** When spec-dev is run standalone (without orchestrator), this phase must be executed here, between Phase 0.5 and Phase 1.

**Purpose:** Every pub package needed by the feature (presentation + infra) must have a `*_wrapper.dart` with passing tests BEFORE the feature tests are written. This ensures presentation tests mock the correct interface (`IFlChartWrapper`, not `LineChart`).

### 0.6.1 Detect packages

**Primary method — semantic reading (mandatory):** Read `tasks.md`, `spec.md`, and `domain.md` completely and extract every pub.dev package name mentioned for the Presentation or Infrastructure layers (e.g. `fl_chart`, `lottie`, `image_picker`). Do NOT rely only on keyword matching — read for intent (e.g. "line chart" → `fl_chart`, "PDF export" → `printing`).

**Secondary method — grep cross-check (after reading, catches missed names):**

```bash
grep -iE "fl_chart|lottie|syncfusion|image_picker|pdf|camera|qr_flutter|printing|webview|mapbox|google_maps|audioplayer|charts_flutter|graphic" \
  lib/features/<name>/spec/tasks.md \
  lib/features/<name>/spec/spec.md 2>/dev/null || true
```

**Final package list = semantic reading ∪ grep hits. Deduplicate.**

### 0.6.2 For each package: check if wrapper exists

```bash
find lib/core/services/ -name "<package_name>_wrapper.dart" 2>/dev/null && echo "EXISTS" || echo "MISSING"
```

If all EXISTS → skip to 0.6.4 (existing wrappers enumeration). No new wrappers needed, but `## Wrapper API` must still document GROUP 2.

### 0.6.3 For each MISSING wrapper: TDD cycle

```
1. pub add: run 'dart pub add <package_name>' from the project root.
2. Write test FIRST (RED):
   - File: test/core/services/<domain>/<package_name>_wrapper_test.dart
   - Test the wrapper's public API only. For UI packages: test factory returns a Widget.
   - Run flutter test → MUST FAIL (wrapper doesn't exist yet). Confirm RED.
3. Write wrapper (GREEN):
    - File: lib/core/services/<domain>/<package_name>_wrapper.dart (standalone file).
    - Pattern reference: see `.ai/skills/app-agent-cp-package/SKILL.md`.
    - UI-only: factory method accepting simple types, returning Widget.
    - NEVER invent types. NEVER add feature logic.
4. Run 'flutter test test/core/services/<domain>/<package_name>_wrapper_test.dart' → MUST PASS GREEN.
5. Run 'flutter analyze lib/core/services/' → 0 issues.
6. Apply SOLID interface pattern. Read `.ai/skills/app-class-to-solid-min/SKILL.md` and follow it
   for `<package_name>_wrapper.dart`. Concretely:
   a) In `<package_name>_wrapper.dart`, add `abstract interface class I<PkgName>Wrapper` ABOVE `class <PkgName>Wrapper`.
      The interface declares only the public method signatures — no bodies.
   b) Add `implements I<PkgName>Wrapper` to `<PkgName>Wrapper` and `@override` on every method.
   d) Re-run `flutter analyze lib/core/services/` → 0 issues before proceeding.
   Do NOT create a Riverpod provider for UI-only packages (fl_chart, lottie, etc.).
```

### 0.6.4 Update generated_api_contract.md — new AND existing wrappers

Append a `## Wrapper API` section documenting TWO groups:

**GROUP 1 — New wrappers** created in this phase:
- Wrapper class, interface (I<Name>), CustomFunction accessor, and every public method signature.

**GROUP 2 — Existing wrappers used by this feature:**
- Scan `lib/core/services/` and the spec files to identify which existing wrappers the feature needs (e.g. `IDioWrapper` for HTTP, `ICredentialStore` for auth, `ISharePlusWrapper` for sharing).
- Document the same fields for each.

Example:
```
## Wrapper API
### FlChartWrapper — accessed via ref.watch(flChartProvider)
- lineChart({required List<double> values, List<String>? labels, Color? lineColor, Color? fillColor}) → Widget
- pieChart({required Map<String, double> segments, List<Color>? colors}) → Widget
### DioWrapper (IDioWrapper) — accessed via ref.watch(httpServiceProvider) (`core/network/dio/dio_providers.dart`)
- get(String path, {Map<String, String>? headers}) → Future<dynamic>
### CredentialStore (ICredentialStore) — accessed via ref.watch(credentialStoreProvider)
- read() → Future<String?>
```

**Why both groups:** Test writers for D.0.1–D.0.5b mock ALL wrapper interfaces — not only new ones. Without this section listing `IDioWrapper`, an infrastructure test writer might mock `Dio` directly.

### 0.6.5 Gate check

> ⛔ **ORCHESTRATOR SKIP:** If spec-dev was launched by the Spec-Local orchestrator, Phase 0.6 was already executed at D.0.6 — **DO NOT re-run this phase.** Proceed directly to Phase 1.

**Standalone only (no orchestrator):** Run all 3 checks below. You are an agent — running bash is allowed here. The orchestrator's "no inline flutter" rule applies only to the orchestrator itself, not to sub-agents.

```bash
grep "## Wrapper API" lib/features/<name>/spec/generated_api_contract.md
```
```bash
flutter test test/core/services/
```
```bash
flutter analyze lib/core/services/ --fatal-infos 2>&1 | tail -1
```

All 3 must pass. If not → fix → re-verify. Do NOT proceed to Phase 1 until all pass.

---

## Phase 1 — Domain entities + initial code generation

Feature path: `lib/features/<feature_name>/`

### 1.1 Write entity files

File: `domain/entities/<entity_name>.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<entity_name>.freezed.dart';

@freezed
abstract class <EntityName> with _$<EntityName> {
  const <EntityName>._();

  const factory <EntityName>({
    required <Type> <fieldName>,
    // ... other fields from domain.md
  }) = _<EntityName>;
}
```

**Rules:**
- `@freezed abstract class` with `const Foo._()` private constructor
- NO fromJson, NO @JsonKey, NO @JsonSerializable
- Each nested entity gets its own file in the same `domain/entities/` directory
- NEVER create `_entities.lib.dart` with `library`+`part` for @freezed entity files

### 1.2 Run build_runner for entities only

```bash
# From project root
dart run build_runner build --delete-conflicting-outputs
```

Verify that `.freezed.dart` and `.g.dart` are generated for each entity file.

### 1.3 Create DTOs in infrastructure/dtos/

Create Data Transfer Objects (DTOs) in `infrastructure/dtos/`. DTOs handle ALL JSON serialization — entities NEVER have fromJson/toJson.

Template for each DTO (create one per entity):

```dart
// infrastructure/dtos/<name>_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<name>_dto.freezed.dart';
part '<name>_dto.g.dart';

@freezed
abstract class <Name>Dto with _$<Name>Dto {
  const factory <Name>Dto({
    @JsonKey(name: '<json_key>') required <Type> <fieldName>,
  }) = _<Name>Dto;

  factory <Name>Dto.fromJson(Map<String, dynamic> json) => _$<Name>DtoFromJson(json);
}
```

Rules:
- Use `@freezed abstract class` for DTOs
- Include `fromJson` factory AND `toJson` (generated automatically)
- Use `@JsonKey(name: 'snake_case')` when the Dart field is camelCase and JSON is snake_case
- All fields `required` in the constructor
- `List<T>` with `@Default([])` instead of `List<T>?` nullable
- Create `_dtos.lib.dart` barrel that exports all DTOs

> **Si el DTO es un shared wire contract** (consumido por 2+ features, p. ej. clinical_history/patient), créalo en `core/network/contracts/` (barrel `_contracts.lib.dart`), NUNCA en `infrastructure/dtos/`. **Tras mover un DTO entre carpetas, borra los `.freezed.dart`/`.g.dart` de la carpeta de origen** — Rule 29 los detecta y hace fallar el CI.

Run build_runner:
```bash
dart run build_runner build
```

---

## Phase 2 — Domain stubs → RED

**Tests already exist from Phase 0.5. This phase only creates stub files, then runs the pre-existing tests.**

### 2.1 Write domain stubs

**Datasource interface** — `domain/datasources/i_<name>_datasource.dart`

```dart
abstract interface class I<Name>Datasource {
  Future<<ReturnType>> <methodName>(<args>);
}
```

**Repository interface** — `domain/repositories/i_<name>_repository.dart`

```dart
abstract interface class I<Name>Repository {
  Future<Result<<T>>> <methodName>(<args>);
}
```

**Usecase stub** — `domain/usecases/<name>_usecase.dart`

```dart
class <Name>UseCase {
  const <Name>UseCase(this._repository);
  final I<Name>Repository _repository;

  Future<Result<T>> call(<args>) => throw UnimplementedError();
}
```

### 2.2 Run domain tests → expect RED

```bash
flutter test test/features/<feature_name>/domain/
```

Expected: usecase tests FAIL with `UnimplementedError`. Entity tests PASS (entities are complete after build_runner).

---

## Phase 3 — Domain implementation → GREEN

### 3.1 Implement usecase

Replace `throw UnimplementedError()` with the correct delegation:

```dart
Future<Result<T>> call(<args>) => _repository.<methodName>(<args>);
```

### 3.2 Run domain tests → expect GREEN

```bash
flutter test test/features/<feature_name>/domain/
```

All domain tests must pass before proceeding.

---

## Phase 4 — Infrastructure stubs → RED

**Tests already exist from Phase 0.5. This phase only creates stub files, then runs the pre-existing tests.**

### 4.1 Write infrastructure stubs

**Datasource impl stub** — `infrastructure/datasources/<name>_datasource_impl.dart`

```dart
class <Name>DatasourceImpl implements I<Name>Datasource {
  const <Name>DatasourceImpl({
    required IDioWrapper dio,
    required ICredentialStore credentialStore,
  })  : _dio = dio,
        _credentialStore = credentialStore;

  final IDioWrapper _dio;
  final ICredentialStore _credentialStore;

  @override
  Future<<ReturnType>> <methodName>(<args>) => throw UnimplementedError();
}
```

**Mapper stub** — `infrastructure/mappers/<name>_mapper.dart`

```dart
class <Name>Mapper {
  <EntityType> fromDto(<Name>Dto dto) => throw UnimplementedError();
}
```

**Repository impl stub** — `infrastructure/repositories/<name>_repository_impl.dart`

```dart
class <Name>RepositoryImpl implements I<Name>Repository {
  const <Name>RepositoryImpl(this._datasource);
  final I<Name>Datasource _datasource;

  @override
  Future<Result<T>> <methodName>(<args>) => throw UnimplementedError();
}
```

### 4.2 Run infrastructure tests → expect RED

```bash
flutter test test/features/<feature_name>/infrastructure/
```

Expected: all infra tests FAIL with `UnimplementedError`.

---

## Phase 5 — Infrastructure implementation → GREEN

### 5.1 Implement datasource

Create a pure HTTP datasource — no mock mode, no conditional branches.

```dart
@override
Future<<ReturnType>> <methodName>(<args>) async {
  final token = await _tokenService.read();
  final response = await _dio.get(
    'api/v1/<endpoint>',
    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
  ) as Map<String, dynamic>;
  final dto = <Name>Dto.fromJson(response);
  return <Name>Mapper().fromDto(dto);
}
```

**For list responses** (`{"items": [...]}`):
```dart
final list = (response['<key>'] as List)
    .map((e) => <Name>Dto.fromJson(e as Map<String, dynamic>))
    .map((dto) => <Name>Mapper().fromDto(dto))
    .toList();
return list;
```

FakeDatasource classes are used for testing via Riverpod provider overrides, not via a useMock environment flag. The provider always returns the real implementation:
```dart
@riverpod
IDatasource datasource(Ref ref) =>
    DatasourceImpl(dio: ref.watch(dioProvider));
```
For tests, override the datasourceProvider with FakeDatasource in the ProviderScope.

**For routes with path parameters** (e.g., `/user/appointments/{id}/history`):
```dart
final response = await _dio.get(
  'api/v1/<endpoint>/${id}',
  headers: ...,
) as Map<String, dynamic>;
```

### 5.2 Implement mapper

```dart
<EntityType> fromDto(<Name>Dto dto) =>
    <EntityType>(
      field1: dto.field1,
      field2: dto.field2,
      // ... map each field from DTO to Entity using named constructors
    );


IMPORTANT VGV RULE: NEVER use Entity.fromJson() in mappers. Always use named constructors.```

### 5.3 Implement repository

```dart
@override
Future<Result<T>> <methodName>(<args>) =>
    guard(() => _datasource.<methodName>(<args>));
```

**Rule:** Always use `guard()` from `shared/error/result_guard.dart`. Never raw try/catch. Repositories wrap datasources; usecases wrap shared ports (raw values like `String?`, `bool`, `void`, records).

### 5.4 Run infrastructure tests → expect GREEN

```bash
flutter test test/features/<feature_name>/infrastructure/
```

All infra tests must pass before proceeding.

---

## Phase 6 — State + notifier stub + providers + codegen

### 6.1 Write state sealed class

File: `presentation/notifiers/<name>_state.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<name>_state.freezed.dart';

@freezed
sealed class <Name>State with _$<Name>State {
  const factory <Name>State.initial() = <Name>Initial;
  const factory <Name>State.loading() = <Name>Loading;
  const factory <Name>State.loaded(<T> data) = <Name>Loaded;
  const factory <Name>State.failure(String message) = <Name>Failure;
}
```

**Rule:** Sealed state — NO `._()` constructor.

### 6.2 Write notifier stub

File: `presentation/notifiers/<name>_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '<name>_notifier.g.dart';

@riverpod
class <Name>Notifier extends _$<Name>Notifier {
  @override
  <Name>State build() => const <Name>State.initial();

  // Stub — tests expect this to transition to Loading then Loaded/Failure
  Future<void> load(<args>) async {}

  void reset() => state = const <Name>State.initial();
}
```

### 6.3 Write providers (DI chain)

File: `di/<name>_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '<name>_provider.g.dart';

@riverpod
I<Name>Datasource <name>Datasource(<Name>DatasourceRef ref) =>
    <Name>DatasourceImpl(
      dio: ref.watch(httpServiceProvider),
      tokenService: ref.watch(tokenStoreProvider),
    );

@riverpod
I<Name>Repository <name>Repository(<Name>RepositoryRef ref) =>
    <Name>RepositoryImpl(ref.watch(<name>DatasourceProvider));

@riverpod
<Name>UseCase <name>UseCase(<Name>UseCaseRef ref) =>
    <Name>UseCase(ref.watch(<name>RepositoryProvider));
```

### 6.4 Run build_runner for state + notifier + providers

```bash
dart run build_runner build --delete-conflicting-outputs
```

Verify `.freezed.dart` for state and `.g.dart` for notifier and providers are generated.

---

## Phase 7 — Presentation tests → RED

**Tests already exist from Phase 0.5. This phase only confirms RED after notifier stub is in place.**

### 7.1 Run presentation tests → expect RED

```bash
flutter test test/features/<feature_name>/presentation/
```

Expected: notifier tests FAIL (load() stub does nothing, no state transitions). Screen tests FAIL (screen is not implemented yet).

---

## Phase 8 — Presentation implementation → GREEN

> ℹ️ All wrappers required by this feature were already created and tested GREEN at Phase 0.6. The `## Wrapper API` section of `generated_api_contract.md` lists every wrapper and its method signatures. Use `ProviderName` or `ref.watch(provider)` — NEVER import the raw package directly.

### 8.1 Implement notifier

Replace the stub `load()` with:

```dart
Future<void> load(<args>) async {
  state = const <Name>State.loading();
  final result = await ref.read(<name>UseCaseProvider).call(<args>);
  result.fold(
    (failure) => state = <Name>State.failure(
      failure, // AppError passed directly to state; UI localizes via localizeError()
    ),
    (data) => state = <Name>State.loaded(data),
  );
}
```

### 8.2 Implement screen

File: `presentation/screens/<name>_screen.dart`

```dart
class <Name>Screen extends ConsumerStatefulWidget {
  const <Name>Screen({super.key});

  @override
  ConsumerState<<Name>Screen> createState() => _<Name>ScreenState();
}

class _<Name>ScreenState extends ConsumerState<<Name>Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(<name>NotifierProvider.notifier).load(<args>);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(<name>NotifierProvider);

    ref.listen(<name>NotifierProvider, (_, next) {
      if (next is <Name>Failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(<name>NotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('<Title>')),
      body: switch (state) {
        <Name>Initial() => const SizedBox.shrink(),
        <Name>Loading() => const Center(child: CircularProgressIndicator()),
        <Name>Loaded(:final data) => _buildList(data),
        <Name>Failure() => const SizedBox.shrink(),
      },
    );
  }
}
```

**Rules for screens with parameters** (e.g., id from GoRouter):
- Declare final fields on `ConsumerStatefulWidget`
- Parse from GoRouter `state.pathParameters['id']`
- Pass to `load(id)` in `initState`

### 8.3 Implement widgets

Create one file per widget from `tasks.md` → Presentation section.

### 8.4 Run full build_runner + presentation tests

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/<feature_name>/presentation/
```

All presentation tests must pass before proceeding.

---

## Phase 8.5 — Golden tests → GREEN

**Requirement:** every feature with a `presentation/screens/` folder ships a golden test with committed fixtures. Golden tests are snapshot tests of real rendered UI, so they are created here (after the screen exists) — NOT at Phase 0.5.

Reference pattern: `test/features/auth/presentation/screens/login_screen_golden_test.dart`.

1. Create `test/features/<feature_name>/presentation/screens/<feature_name>_screen_golden_test.dart` with `@Tags(['golden']);` then `library;` at the top (exact form of the login reference). Use `golden_toolkit`'s `testGoldens`.
2. Build a fake notifier that fixes the state: extend the feature's notifier, override `build()` to return the target state and `load()`/`refresh()` as no-ops (so any screen auto-load `postFrameCallback` cannot change the state). Override the screen's notifier provider with it.
3. Pump the real screen inside `ProviderScope(overrides:)` + `MaterialApp(theme: ThemeData(fontFamily: 'Roboto'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: <Name>Screen())`.
4. Cover ONLY stable visible states (no animations; failure is not goldenable when the body renders nothing/transient snackbar): **loading** (use the Loading variant, NOT Initial, to avoid the auto-load callback), **loaded** (2+ realistic fixture entities), **empty** (loaded with empty list). Add other stable states if the screen has them (e.g. expanded card).
5. Assert with `matchesGoldenFile('goldens/<feature_name>_screen_<state>.png')` — fixtures live in `test/features/<feature_name>/presentation/screens/goldens/`.
6. Do NOT call `loadAppFonts` — fonts are loaded globally by `test/flutter_test_config.dart` (deterministic across macOS local and Linux CI).
7. Generate the PNGs: `flutter test --tags golden --update-goldens` from repo root. Confirm the PNGs were created under `goldens/`.
8. Verify: `flutter test --tags golden` → GREEN.
9. Do NOT modify spec files (frozen) — golden files were already listed in `## Required Files` of `generated_api_contract.md` at Phase 0.5.

---

## Phase 9 — Integration test → RED (analyze)

**Integration test already exists from Phase 0.5 (`integration_test/<feature_name>_integration_test.dart`).**

### Run analyze on integration test

```bash
flutter analyze integration_test/<feature_name>_integration_test.dart
```

Expected at this point: FAIL because screen is not yet imported in `_configs.lib.dart` or the route is not wired. That is the RED state — proceed to Phase 10 to fix.

### Rules for integration tests

1. One `testWidgets` per BDD `Scenario`
2. Always start from login (app always boots at LoginScreen)
3. Override **only repositories** — repositories are the DI seam
4. Fake repositories return deterministic data, no HTTP calls
5. Use `find.byType(IdFormField)` and `find.byType(PasswordFormField)` for login form
6. Use `find.byTooltip('...')` to tap navigation icons added to AppBar
7. Use `find.text(...)` for asserting screen content
8. `await tester.pumpAndSettle()` after every tap that triggers navigation or async state
9. For error snackbar: use `await tester.pump(Duration(seconds: 2))` not `pumpAndSettle` (snackbar auto-dismisses after 4s)
10. The `integration_test` package is already a dependency

---

## Phase 9.5 — BDD step definitions → GREEN

**BDD test file already exists from Phase 0.5 (`test/bdd/<feature_name>_bdd_test.dart`).**

### Run BDD tests → expect GREEN

```bash
flutter test test/bdd/<feature_name>_bdd_test.dart
```

All scenarios must pass. If any fail:
- Step match failure → review step text for ambiguity
- Assertion failure → fix widget or step assertion (do NOT rewrite the whole file)

### Critical rules for step definitions (reference when fixing)

1. **`_testFunction` MUST be a top-level named function, never an inline lambda.**

2. **Step text ambiguity:** parameterized steps `{x}` match before exact steps — use distinct step text for null/absent cases.

3. **Parameterized steps:** use `.mapper(types: {'n': int})` to declare integer parameters.

4. **`rootPaths` is relative to the project root** — use `'lib/features/<name>/spec/bdd.feature'`.

5. **Widget pump sequence for error snackbar:** `pumpWidget` → `pump()` → `pump(Duration(seconds: 2))` — do NOT use `pumpAndSettle`.

---

## Phase 10 — Widgets + navigation wiring → GREEN

### 10.1 Widgets (standalone — NO barrel, NO facade)

Each widget is a **standalone file** with explicit imports — no `_widgets.lib.dart` barrel
and no `Custom[Name]Widgets` static facade (project convention since the widgets refactor;
see `MD/APP_BARREL_PATTERN.md` → "presentation/widgets exception").

```dart
// presentation/widgets/<widget_name>.dart
import 'package:flutter/material.dart';
// other imports (value_objects, l10n, design_system, shared/models)

class <WidgetName> extends StatelessWidget {
  const <WidgetName>({super.key, ...});

  @override
  Widget build(BuildContext context) { ... }
}
```

Consumers import the widget file directly and use its constructor:

```dart
import 'package:clean_architecture_sdd_harness/features/<name>/presentation/widgets/<widget_name>.dart';
// ...
<WidgetName>(...)
```

### 10.2 Add AppRoute entry

In `lib/shared/router/app_route.dart`:

```dart
<name>(path: '/<path>', name: '<name>'),
```

### 10.3 Add GoRoute

In `lib/app/router/app_router.dart`, add the screen import at the top:

```dart
import 'package:clean_architecture_sdd_harness/features/<name>/presentation/screens/<name>_screen.dart';
```

Then add the GoRoute:

```dart
GoRoute(
  path: '/<path>',
  name: AppRoute.<name>.name,
  builder: (context, state) => const <Name>Screen(),
),
```

For routes with path parameters:
```dart
GoRoute(
  path: '/<path>/:id',
  name: AppRoute.<name>.name,
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return <Name>Screen(id: id);
  },
),
```

### 10.6 Add navigation trigger to parent screen

If `tasks.md` specifies adding a trigger on a parent screen:

```dart
IconButton(
  tooltip: '<Tooltip Text>',
  icon: const Icon(Icons.<icon>),
  onPressed: () => ref.read(appNavigatorProvider).push(
    AppRoute.<name>,
  ),
),
```

Add the one-line `appNavigatorProvider` re-export to the feature's `di/` file to use it from presentation code (see MD/APP_PROVIDERS.md).

### 10.7 Run analyze → expect GREEN

```bash
flutter analyze integration_test/<feature_name>_integration_test.dart
flutter analyze
```

All analyze errors must be resolved before proceeding.

---

## Phase 11 — Final verification

### 11.1 Full build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 11.2 Flutter analyze

```bash
flutter analyze
```

Fix every issue. Common fixes:
- Missing imports — add correct `package:app/...` import
- Unused variables — remove or use
- Wrong type annotations — check `domain.md`
- Missing `part` declarations — check barrel files

### 11.3 Flutter test (unit + widget + BDD)

Run all unit and widget tests including BDD:

```bash
flutter test test/features/<feature_name>/
flutter test test/bdd/<feature_name>_bdd_test.dart
```

Fix every failing test. Do not skip tests.

### 11.4 Integration test execution on device (MANDATORY — no deferral)

Execute the integration test on a device using bash. Integration test execution is MANDATORY and cannot be deferred:

```bash
# List available devices first (prefer macos > android > ios)
flutter devices --machine

# Run integration test on macOS (most reliable for CI)
flutter test integration_test/<feature_name>_integration_test.dart -d macos

# If macOS fails, try Android emulator or iOS simulator
flutter test integration_test/<feature_name>_integration_test.dart -d <device_id>
```

**If any test fails:**
1. Read the failure output — identify the root cause (widget finder type mismatch, missing widget, wrong key, etc.)
2. Fix the integration test file — do NOT modify production code
3. Re-run `flutter test integration_test/<feature_name>_integration_test.dart -d <device_id>`
4. Repeat until ALL tests pass GREEN

**Common runtime failures that analyze cannot catch:**
- Generic widget finder type: `find.byType(DropdownButton)` → `DropdownButton<dynamic>` at runtime. Must use `find.byType(DropdownButton<String>)` to match the actual widget type.
- Missing `pumpAndSettle` alternative: `LineChart` (fl_chart) has continuous animations → use `pump(Duration(...))` instead.
- Widget not in tree: verify the widget is rendered at the expected stage (loading → loaded → chart).

> **Integration tests must actually execute on a device — analyze-clean is NOT sufficient. Widget-finder type mismatches and animation issues are only detectable at runtime.**

### 11.5 Integration test analyze fallback — REMOVED

> ⛔ Execution deferral is no longer allowed. Use 11.4 to execute on a device. If no device is available, report BLOCKED — do not defer.

---

## Canonical example

The `auth` feature is the reference implementation:
- `lib/features/auth/` — all layers
- `test/features/auth/` — all unit + widget tests
- `integration_test/auth_integration_test.dart` — integration test pattern

When in doubt, read the corresponding file from auth and adapt it.

---

## Constraints (never violate)

| Rule | Correct | Wrong |
|---|---|---|
| Injectable services | `ref.watch(httpServiceProvider)` | direct static locator |
| Repository error handling | `guard(...)` from `shared/error/result_guard.dart` | raw `try/catch` |
| Notifier error message | `state = State.failure(error)` passes `AppError` to state | `failure.message` directly |
| Freezed entity | `@freezed abstract class` + `const Foo._()` | `@freezed class` without `._()` |
| Freezed state | `@freezed sealed class` | state with `._()` |
| Entity barrel | import entity files directly | `library`+`part` barrel for `@freezed` entities |
| Widget imports | `import '<widget_file>.dart'` (standalone) | `import '_widgets.lib.dart'` (barrel facade) |
| Integration test boot | `app.main(overrides: [...])` | `runApp(...)` directly |
| Build runner | run from project root | run from repo root |
| Notifier pattern | non-family; params via `load(<args>)` from initState | `@riverpod` family |
| TDD order | stubs → tests RED → implement → GREEN | code first, tests last |

---

## Memory Protocol (Engram)

### After completion — mandatory

```
mem_save(
  title: "Feature implemented: <feature_name>",
  type: "decision",
  content: "**What**: Full TDD implementation of <feature_name> across all 11 phases. **Why**: <motivation from spec>. **Where**: lib/features/<feature_name>/, test/features/<feature_name>/, integration_test/<feature_name>_integration_test.dart, test/bdd/<feature_name>_bdd_test.dart. **Learned**: <any gotchas encountered during TDD phases>"
)
```
