# AGENTS.md

Compact orientation for AI agents working in this repo.

## Repo layout

```
clean_architecture_sdd_harness/
lib/              ← Flutter app source code
.ai/              ← Centralized AI artifacts (agents, skills, commands, etc.)
.opencode/        ← Symlinks of .ai/
MD/               ← Reference documentation
AGENTS.md         ← this file
```

**`.ai/` structure:**
```
.ai/
├── skills/           ← Unified skills and agents (source of truth)
│   ├── app-*             ← App skills (Flutter, Riverpod, etc.)
│   └── app-agent-*       ← App agents (Spec-Definer, Nav-Wirer, etc.)
├── commands/         ← CLI scripts (super-commit, etc.)
├── orchestrators/    ← Workflow orchestrators
├── memory/           ← Persistent memory (Engram/Openspec)
├── prompts/          ← Reusable prompt templates
├── specs/            ← SDD/OpenSpec specifications
├── templates/        ← File templates
```

**Attention: the following .md files are available.**

```
MD/APP_ARCHITECTURE.md      ← Architecture of app
MD/APP_BARREL_PATTERN.md    ← Indication how works each folder that has barrel files in the app
MD/APP_COMMANDS.md          ← Commands to run app (included its test)
MD/APP_DARTZ.md             ← Result/guard/fold pattern: guard, fold, AppError types, call-chain
MD/APP_EXCEPTION.md         ← Contains info about create and update code that contains app exceptions
MD/APP_IMPORTANT_INFO.md    ← Basic info that should knows when is working with app
MD/APP_PACKAGE_WRAPPER.md   ← How to wrap external packages: <pkg>_wrapper.dart pattern (interface+impl), when to create Riverpod bridge, goRouterProvider pattern (main.dart must NOT import go_router directly)
MD/APP_PROVIDERS.md         ← Shared providers inventory (dio, token, connectivity, goRouter), ref.watch/read/listen per context
MD/APP_SKILLS.md            ← Complete reference of all app_* skills and agents
MD/APP_STATE_MANAGMENT.md   ← State management overview (Riverpod v3 code-gen) + quick ref to APP_PROVIDERS.md
MD/APP_TREE.md              ← Show the file tree of the app. Use it always before write code
MD/AI_ARTIFACTS.md          ← How to create skills, agents, commands, orchestrators
```
---

## GIT
Before executing any git command, write the exact command and ask the user to confirm before running it.

### Git Flow (enforced)

Default branch: `main` (production). Integration branch: `develop`. See README.md → Git Flow section for the full model.

* `feature/*` → PR → `develop` (checks) → merge
* Dependabot (patch/minor) → PR → `develop` → checks → auto-merge
* `release/*` → PR → `main` (gate + checks + 2 approvals in config; personal-account exception documented in `.github/REPOSITORY_GOVERNANCE.md`) → tag `vX.Y.Z` → back-merge → `develop`
* `hotfix/*` → PR → `main`, then back-merge → `develop`
* Direct pushes to `main`/`develop` are blocked (branch protection, `enforce_admins`). All changes go through PRs.

### Dependency management

- The Flutter SDK pinned in CI (`3.44.0`) pins `intl` (0.20.2), `test_api` (0.7.11), `matcher`, `meta`, `vector_math` to **exact** versions. If a dependabot PR fails `flutter pub get` on `intl`/`test`, revert those constraint bumps — do not hand-edit the lock; regenerate with `flutter pub get`.
- Never adopt prerelease-major codegen (e.g. `freezed 4.0.0-dev.x`) in production — the analyzer-13 toolchain has no stable freezed (issue #62).
- Dependabot ignores `intl`, `test` and `freezed` (semver-major). Note: Dependabot reads `.github/dependabot.yml` from the **default branch (`main`)**; config changes on `develop` activate after the next release promotes them (issue #63).
- Android `compileSdk`/`minSdk` are set explicitly when a plugin requires more than the Flutter default (e.g. `flutter_secure_storage 11` → `compileSdk 37`).


---

## GoRouter — access via Riverpod provider + IAppNavigator seam

go_router is accessed exclusively via Riverpod. The composition root (`main.dart`) uses `ref.watch(goRouterProvider)` (in `app/di/router/router_provider.dart`). **Features never import `go_router` or `app/` (Rules 6/11)**: when a feature needs imperative navigation it re-exports the `IAppNavigator` seam (`appNavigatorProvider` in `core/router/`) from its own `di/` file — on-demand, only when actually navigating. `features/clinical_history` is the first feature that navigates imperatively (its AppBar "Lab Results" action): its `di/` re-exports `appNavigatorProvider`. Auth-flow navigation (login/logout/deep-link restore) stays declarative via `AuthGuard` redirect + `?from=`.

| Symbol | Access |
|---|---|
| `goRouterProvider` | `ref.watch(goRouterProvider)` in `main.dart` (returns `GoRouter`); bound by `app/di/router/router_overrides.dart` → `routerOverrides()` merged in `main.dart` |
| `appNavigatorProvider` | `Provider<IAppNavigator>` seam in `core/router/app_navigator_provider.dart`; a feature that navigates imperatively adds a one-line re-export in its `di/` and calls `ref.read(appNavigatorProvider).go/push(AppRoute.x)` — assertado en el boot (`main.dart` `_assertDiSeamsBound`) |
| `AppRoute` | Typed route registry in `lib/shared/router/app_route.dart` (Shared Kernel, pure Dart) — used by `app_router.dart` and `AuthGuard`; features navigate via `IAppNavigator` |

---

## Shared Models — barrel pattern

Shared domain entities live in `lib/shared/models/`. The barrel `_models.lib.dart` exports entity files directly.

| Subdirectory | Entities |
|---|---|
| `patient/` | `PatientEntity` |
| `clinical_history/` | `ClinicalHistoryEntity` + 6 sub-entities (service, facility, professional, diagnosis, attachment, state) |
| `lab_results/` | `LabResultEntity` + sub-entities (`LabResultValueEntity`, `LabResultReferenceRangeEntity`) + enums `LabResultKind`, `LabResultStatus` (with `deriveLabResultStatus`) |

**Access from features:**
```dart
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
```

Or import the barrel for convenience:
```dart
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
```

`lib/shared/models/` is the **domain Shared Kernel** (DDD): pure domain models shared by two or more bounded contexts, owned by NO single feature. They cannot live in a feature because `core/database/` persists them and `core/` is feature-agnostic (Rule 14).

| Model | Consumers |
|---|---|
| `PatientEntity` | `features/auth` (login envelope) + `core/database` (`PatientSerializer`) |
| `ClinicalHistoryEntity` + 6 sub-entities | `features/clinical_history` + `core/database` (`ClinicalHistorySerializer`) |
| `LabResultEntity` + sub-entities | `features/lab_results` (domain/infrastructure/presentation) + `core/database` (`LabResultsSerializer`) |

**Criteria to add a model:** ≥ 2 bounded contexts consume it, it is 100% Dart puro, and it does not depend on `core/`, `app/`, `l10n/`, or any feature. **Governance:** changing a Shared Kernel model impacts all consumers — run the full suite and update every serializer/mapper/store; the round-trip guards `test/core/database/*_serializer_test.dart` protect consistency.

---

## Database — access via Riverpod providers

Database access is now managed through `core/database/` with Riverpod providers, not `CustomDb`.

| Provider | Type | Access from features |
|---|---|---|
| `appDatabaseProvider` | `Provider<IAppDatabase>` | `ref.watch(appDatabaseProvider)` |
| `IAppDatabase.database` | `Future<ISembastDb>` | `await ref.read(appDatabaseProvider).database` — get sembast database wrapper |
| `IAppDatabase.resetDatabase()` | `Future<void>` | `await ref.read(appDatabaseProvider).resetDatabase()` — full local wipe: deletes the DB file AND the encryption key (account reset / GDPR). NOT used on logout — logout clears the session via `clearSession()`. Features do NOT call it directly: the production consumer is `ResetAccountUseCase` (auth) → `LocalAuthDatasourceImpl.resetAccount()` = `clearSession()` + `resetDatabase()`. |
| `clinicalHistoryStoreProvider` | `Provider<IClinicalHistoryStore>` | `ref.watch(clinicalHistoryStoreProvider)` — from `core/database/tables/clinical_history_providers.dart` |
| `patientInfoStoreProvider` | `Provider<IPatientInfoStore>` | `ref.watch(patientInfoStoreProvider)` — from `core/database/tables/patient_info_providers.dart` |
| `labResultsStoreProvider` | `Provider<ILabResultsStore>` | `ref.watch(labResultsStoreProvider)` — from `core/database/tables/lab_results_providers.dart` |

> **Providers viven en archivos `*_providers.dart` dedicados, nunca embebidos en las clases de tabla (Rule 20, enforced by CI).**

**Test patterns (real, used across the suite):**
- DB-backed store/datasource tests use real in-memory sembast with **always-on encryption** (the factory no longer bypasses the codec): `AppDatabase(databaseFactory: newDatabaseFactoryMemory(), keyService: DatabaseKeyService(storage: FakeSecureStorage()))`. The fake key storage lives in `test/helpers/mocks.dart`; never rely on the platform key store in unit tests.
- Feature/widget/integration tests override repository or usecase providers via `ProviderScope(overrides: [...])` / `app.main(overrides: [...])`.

---

## CustomInterceptors — access rule

Interceptors live in `lib/core/network/interceptors/` with their own barrel `_interceptors.lib.dart`.

| Symbol | Access |
|---|---|
| `AuthInterceptor(onRetry, internalDio)` | Used internally by `DioWrapper` to add the `Authorization` header + handle 401 retry; do not use directly from features |

> JWT utilities: `ITokenVerifier.isExpired()` (via `tokenVerifierProvider`, impl `JwtTokenExpiryChecker`) delegates payload decoding to `IJwtWrapper.decodePayload()` (via `jwtWrapperProvider`, impl `JwtWrapper`). The app never verifies JWT signatures locally (server-side concern).

> **CI barrels:** `shared/error` solo via `_error.lib.dart` (Rule 22), `shared/exceptions` solo via `_exceptions.lib.dart` (Rule 23), `shared/interfaces` solo via `_interfaces.lib.dart` (Rule 26 — y sin `export` de interfaces fuera de esa carpeta).

---

## SOLID / DI conventions

The project use 2 skills that must be used always to maintain SOLID principles to WRITE CODE.

- When code is inside lib/core/services/ the skill used is `.ai/skills/app-class-to-solid-min/SKILL.md`.

- When the code is written inside lib/features the skill used is `.ai/skills/app-class-to-solid/SKILL.md`.

**Convenciones aplicadas por CI (`test/architecture/dependency_rules_test.dart`):**
- **DIP entre usecases (Rule 18):** un usecase que orquesta otro usecase inyecta `IUseCase<Input, Output>`, nunca la clase concreta (`RestoreSessionUseCase`/`Handle401UseCase` inyectan `IUseCase<NoParams, LoginResponseEntity?>` y `IUseCase<RefreshTokenInput, TokenEntity>`).
- **1 contrato = 1 impl (Rule 19a):** cada interfaz de `domain/repositories/` + `domain/datasources/` tiene exactamente 1 implementación en `infrastructure/`.
- **1 clase = 1 contrato (Rule 19b):** ninguna clase de `infrastructure/` implementa >1 interfaz de dominio (el split de auth: `AuthRemoteRepositoryImpl`/`AuthLocalRepositoryImpl`).
- **Barrel de errores (Rule 22):** `shared/error/` solo se importa vía el barrel `_error.lib.dart`, nunca archivos crudos (convención de barrels, ver `LEARN.md`).
- **Composition root sin re-exports (Rule 27):** `app/` NO re-exporta símbolos de `features/` — la composition root importa features explícitamente; los re-exports ocultos crean dependencias transitivas.
- **Campos inyectados privados (Rule 28):** dependencias inyectadas por constructor (tipos `I...`, `VoidCallback`, `Future<String?> Function()`) deben ser campos privados `_x`; el parámetro nombrado público se deriva del initializing formal (`this._x` → `x`). Motivo: encapsulación y seam limpio (p. ej. `IAuthInterceptorProvider`).
- **Sin archivos generados huérfanos (Rule 29):** todo `*.freezed.dart`/`*.g.dart` debe tener su fuente `*.dart` hermana en el mismo directorio que lo declare como `part`. Migrar DTOs/entidades sin borrar los generados viejos hace fallar el CI (protege contra restos tras migraciones de `infrastructure/dtos/` → `core/network/contracts/`).

---

## Spec-Local Orchestrator — Hybrid Workflow (SDD + Spec-Dev)

This project uses **Spec-Local** (hybrid) that combines the collaborative conversation of spec-definition
with the strict TDD of spec-dev skill and SDD verification.

### Phase Flow (v3 — TDD-First Guarded)

```
User Story
    ↓
Phase A: [app-spec-definition skill] → collaborative conversation (assumptions confirmed)
    ↓
Phase B: [app-agent-spec-definer] → generates 6 files in lib/features/<name>/spec/
    ↓
Phase C: [app-agent-phase-gate] → pre-code audit (spec completeness only — Wrapper audit at D.10.5)
    │  FAIL → repair sub-agents → re-audit → PASS
    ↓
Phase D: [app-spec-dev skill] → All-Tests-First + 12 phases:
    │  D.0.5  → Canonical API extraction → generated_api_contract.md
    │  D.0.6  → Package Audit + Wrapper TDD (pub add → test RED → *_wrapper.dart GREEN) ← BEFORE feature tests
    │  D.0.1–D.0.5b → Write ALL feature tests from spec (domain, infra, presentation, integration, BDD)
    │           → Presentation tests mock wrapper interfaces (IFlChart etc.), never raw packages
    │  D.1–D.11 → stub → RED → implement → GREEN per layer
    │  Phase D.8.5   → [Golden Tests] (screen golden test + committed fixtures + flutter test --tags golden; golden tag declared in dart_test.yaml)
    │  Supervised by [app-agent-spec-dev-supervisor] after each sub-phase
    │  Analyze failure → [app-agent-fix-analyzer-issues]
    │  Test failure   → [app-agent-fix-tests]
    │  Phase D.10     → [app-agent-nav-wirer]
    │  Phase D.10.5   → [DirectImport-Auditor] → [app-agent-cp-package repair: creates missing wrapper if direct imports found]
    ↓
Phase E: [sdd-verify-adapted skill] → formal verification (PASS / FAIL)
    ↓
Phase F: [app-agent-update-md] → update documentation (MD/*)
    ↓
Phase G: [Engram persistence] → session summary
```

### Orchestrator Prompt

  The complete orchestrator is at: `.ai/orchestrators/Spec-Local-Orchestrator.md` (Spec-Local Orchestrator v3 — TDD-First Guarded Workflow)

### Skills and Agents Used

| Phase | Tool | Location | Notes |
|------|------|-----------|-------|
| A | app-spec-definition | `.ai/skills/app-spec-definition/SKILL.md` | Collaborative spec |
| B | app-agent-spec-definer | `.ai/skills/app-agent-spec-definer/SKILL.md` | Generates 6 spec files |
| B — summary | app-agent-spec-definer-summary | `.ai/skills/app-agent-spec-definer-summary/SKILL.md` | Returns concise summary table (internal to Phase B) |
| C | app-agent-phase-gate | `.ai/skills/app-agent-phase-gate/SKILL.md` | Pre-code audit gate (spec completeness only — Wrapper audit deferred to D.10.5) |
| D | app-spec-dev | `.ai/skills/app-spec-dev/SKILL.md` | All-Tests-First + TDD implementation (D.0.5 API extraction → D.0.6 wrapper TDD → D.0.1–D.0.5b all tests → stub→RED→GREEN per layer) |
| D — supervisor | app-agent-spec-dev-supervisor | `.ai/skills/app-agent-spec-dev-supervisor/SKILL.md` | Phase-by-phase verifier |
| D.0.6 | *(orchestrator inline + app-cp-package)* | `.ai/skills/app-cp-package/SKILL.md` | Package Audit: detects missing wrappers, runs TDD (test RED → *_wrapper.dart GREEN), appends ## Wrapper API to generated_api_contract.md — RUNS BEFORE D.0.1 |
| D.0.1 | app-agent-domain-test-writer | `.ai/skills/app-agent-domain-test-writer/SKILL.md` | Writes domain tests from domain.md before stubs exist |
| D.0.2 | app-agent-infrastructure-test-writer | `.ai/skills/app-agent-infrastructure-test-writer/SKILL.md` | Writes infrastructure tests (datasource + repository) from domain.md + contracts.md before infrastructure stubs exist. These tests are written from spec-derived contracts and will intentionally be compile-pending until Phase D.4 creates stubs. |
| D.0.3 | app-agent-presentation-test-writer | `.ai/skills/app-agent-presentation-test-writer/SKILL.md` | Writes presentation tests from domain.md; reads ## Wrapper API to mock IFlChart etc., never raw packages |
| D.0.4 | app-agent-integration-test-writer | `.ai/skills/app-agent-integration-test-writer/SKILL.md` | Writes integration test from domain.md + bdd.feature before repository exists |
| D.0.5b | app-agent-bdd-writer | `.ai/skills/app-agent-bdd-writer/SKILL.md` | Writes BDD test from domain.md + bdd.feature before notifier exists |
| D.0.5 | app-agent-api-extractor | `.ai/skills/app-agent-api-extractor/SKILL.md` | Reads 6 spec files, writes generated_api_contract.md with 6 sections |
| D — repair | app-agent-fix-analyzer-issues | `.ai/skills/app-agent-fix-analyzer-issues/SKILL.md` | Fixes flutter analyze issues |
| D — repair | app-agent-fix-tests | `.ai/skills/app-agent-fix-tests/SKILL.md` | Fixes test failures |
| D.10 | app-agent-nav-wirer | `.ai/skills/app-agent-nav-wirer/SKILL.md` | Wires navigation |
| D.10.5 — audit | *(inline grep)* | D.10.5 | DirectImport-Auditor: 0 direct package imports in feature folder |
| D.10.5 — repair | app-agent-cp-package | `.ai/skills/app-agent-cp-package/SKILL.md` | Creates *_wrapper.dart on direct-import violation |
| E | sdd-verify-adapted | `~/.config/opencode/skills/sdd-verify-adapted/SKILL.md` | Formal verification |
| F | app-agent-update-md | `.ai/skills/app-agent-update-md/SKILL.md` | Documentation sync |

### Constraint: No Spec-Dev Agent

⚠️ **spec-dev is a SKILL, not an agent.** The full implementation lives at `.ai/skills/app-spec-dev/SKILL.md` (all 12 TDD phases, templates, rules). Do not look for an agent file — there is none.

### Trigger Phrases

⚠️ **Rule: OpenCode NEVER calls a skill directly in response to a feature request. The orchestrator is ALWAYS the entry point. Skills are called only BY the orchestrator, or when the user explicitly names the skill (e.g. "run app-spec-definition directly", "load skill X").**

| Phrase | Entry point |
|-------|-------------|
| "I want a feature for X", "new feature", "build X", "create feature", "define spec for", "I want to build", "plan feature" | Load `.ai/orchestrators/Spec-Local-Orchestrator.md` (Spec-Local v3) — it calls skills in order |
| "implement the X feature from its spec", "run Spec-Dev on X" | Load `.ai/orchestrators/Spec-Local-Orchestrator.md` (Spec-Local v3) starting from Phase C |
| "verify feature X" | Load `.ai/orchestrators/Spec-Local-Orchestrator.md` (Spec-Local v3) starting from Phase E |
| "update documentation" | Load `.ai/orchestrators/Spec-Local-Orchestrator.md` (Spec-Local v3) starting from Phase F |
| "run skill X directly", "load skill X", "execute skill X" | Only then invoke the skill directly via the `skill` tool |
| "extract X out of Y", "move X into its own feature", "decommission X" | Load `.ai/orchestrators/Spec-Local-Orchestrator.md` (Spec-Local v3) starting at Phase R |

### Completion Criteria

The flow is complete when:
1. ✅ spec folder has 6 files
2. ✅ spec-dev executed the 12 TDD phases
3. ✅ flutter analyze returns 0 issues
4. ✅ flutter test unit + widget pass (0 failures)
5. ✅ flutter test BDD scenarios pass (0 failures)
6. ✅ integration test executed on device — deferral NOT accepted (D.10.6)
7. ✅ No direct package imports in feature code (D.10.5 audit)
8. ✅ sdd-verify-adapted verdict: PASS or PASS WITH WARNINGS
9. ✅ MD/* updated
10. ✅ Engram has session summary

---

## Commands
| Path | Description |
|---|---|
| `.ai/commands/super-commit.md` | Script with steps to group changes into semantic commits and push the branch |
| `.ai/commands/super-md-update.md` | Script to sync MD/* and AGENTS.md from git changes |
| `.ai/commands/spec-local.md` | Entry point for the Spec-Local TDD-First workflow — invoke as `/spec-local <feature name>` |
| `.ai/commands/super-pull-request.md` | Smart PR Split pipeline: classify changes, plan stacked PRs (English Conventional Commit titles + type-prefixed git-flow branches), execute and validate each PR (analyzer, tests, dart format matching CI), publish stacked PRs |
| `.ai/commands/super-pull-request-reviewer.md` | Review open GitHub PRs against 6 quality gates (introspects branch protection; local analyzer/tests/dart format; sequential squash merge gated by GitHub auto-merge + required-check matrix; no self-approval) |

---

## Important info about "shared" vs "core"

The project has two cross-cutting directories with distinct roles:

- **`lib/shared/`** — Pure domain abstractions (100% Dart, NO Flutter and NO third-party types): error handling (`error/` with `AppError` — sealed, **no `userMessage`** (UI localizes by type via `localizeError()`), flags `isNetworkRelated`/`isTransient`, diagnostic `technicalMessage`/`stackTrace` consumed by the `ILogger` seam in `shared/interfaces/` via `loggerProvider`, re-exported by feature `di/`; `Result<T>`, `guard()`, `RetryResult`), domain interfaces (`interfaces/` with `IConnectivityChecker`, `ITokenStore`, `ITokenVerifier`, `ICredentialStore`, `IPasswordHasher`, `IClinicalHistoryStore` + the ISP split `IClinicalHistoryReader`/`IClinicalHistoryWriter`, `IPatientInfoStore`, `ILabResultsStore` + the ISP split `ILabResultsReader`/`ILabResultsWriter`), exception classes (`exceptions/`), models/entities (`models/`), online-first repository helper (`functions/online_first.dart` — remote first, cache fallback ONLY on a genuine connectivity failure; `fetchOrFallback()` owns all boundary guarding internally and returns `OnlineFirstResult` with `DataOrigin` remote/cache). Domain layer can import from `shared/`. **Boundary rule:** `guard()` wraps EVERY fallible boundary — repositories wrap datasources; usecases wrap shared ports that return raw values (`String?`, `bool`, `void`, records) so exceptions never escape the `Result` chain; the composition root does the same for startup ports (`AppInitializer.checkJailbreak()` returns `Result<void>` via `guard()`, and `main.dart` folds — see `MD/APP_EXCEPTION.md`). VOs/entities stay pure (no wrap): value objects build their own `Result` directly via their single `result()` factory (no `guard()`, no exceptions, no `tryCreate`), and trusted construction uses the freezed `raw` constructor. `localizeError()` lives in `lib/l10n/error_localizer.dart` (UI layer), NOT in `shared/`. **Enforced by CI:** `shared/error` is imported only via the barrel `_error.lib.dart` (architecture Rule 22); `shared/exceptions` is imported only via the barrel `_exceptions.lib.dart` (architecture Rule 23); the guard↔localizer mapping coverage and exception-barrel completeness are enforced by `test/architecture/error_mapping_consistency_test.dart`.

- **`lib/core/`** — Pure infrastructure: service wrappers (`services/`, incl. `IAuthenticationObserver` — extends `Listenable`, in `core/services/auth/`), database (`database/` incl. `IAppDatabase`/`ISembastDb` in `core/database/i_app_database.dart`), network (`network/` incl. `dio_providers.dart`, `internetStatusProvider` in `connectivity/connectivity_providers.dart`), router adapter (`router/`), utils (`utils/`). Domain layer must NEVER import from `core/`. Cross-cutting abstractions that expose third-party types (e.g. sembast `Database`) live in `core/`, not `shared/`. **Shared wire transport contracts** (DTOs consumed by 2+ features, e.g. `PatientDto`, `ClinicalHistoryDto`, `ClinicalHistoryMapper`) live in `core/network/contracts/`; feature-private DTOs live in `features/<name>/infrastructure/dtos/`. Al mover un DTO entre carpetas, borra los `.freezed.dart`/`.g.dart` de la carpeta de origen (Rule 29).

- **`lib/app/`** — Application composition root: GoRouter setup (`router/`), app initializer, the offline banner (`app/widgets/connectivity_banner.dart`), and the DI seam bindings (`app/di/network/dio_overrides.dart`). Features must NEVER import `app/` — feature DI imports providers directly from `core/` (one-way dependency, enforced by architecture Rule 11).

- **`lib/core/config/`** — `AppEnvironment` sealed class + `environmentProvider`.

- **`lib/design_system/`** — Theme and reusable UI components (loading indicator, theme).

- **`lib/l10n/`** — AppLocalizations for i18n, wired into MaterialApp.router.

## Online-first (offline mode only when there is no internet)

The app is **online-first**: the network is always preferred; the offline/cache
path activates ONLY when the user genuinely has no connectivity. This is a
deliberate design decision, documented as acceptance scenarios in
`lib/features/auth/spec/spec.md`.

| Escenario | Qué hace la app | Qué ve el usuario | ¿Offline? |
|---|---|---|---|
| 1/4 | Restore hace login completo (online + credenciales) | Clinical history actualizada | - |
| 2/3 | Restore carga solo cache | Clinical history offline | ✅ |
| 5 | Restore NO fuerza logout, usa cache | Clinical history offline (sin login) | ✅ |
| 6 | Sin sesión → `Success(null)` | Pantalla de login | - |
| 7 | 401 → refresh / re-login | Sigue viendo lo mismo, sin interrupción | - |
| 8 | 401 → RetryFailed → force logout | Login (sesión realmente inválida) | - |
| 9 | 401 sin conexión → RetryNoConnection → NO logout | Sigue viendo datos cacheados | ✅ |
| 10 | `guard()` → `Failure(NetworkError)` → notifier | Snackbar "No internet connection" | ✅ |

Reglas de implementación:
- `login()` es **estrictamente remoto** (nunca cae a la sesión cacheada).
- `fetchOrFallback` cae a cache SOLO en `NetworkError`/`ServerUnreachableError`.
  Un `TimeoutError` NO es offline (no cae a cache) — `isNetworkRelated == false`.
- `fetchOrFallback` (`shared/functions/online_first.dart`) guarda las 3 fronteras
  (remote/local/onRemoteSuccess) internamente — el caller pasa closures raw. Una
  falla de lectura local se superficie como `Failure` con su stack trace.
- El cache write es best-effort en clinical_history (load y refresh): el repo
  (`_storeCache`) captura el `Exception`, lo loguea con stack trace via `ILogger`
  y devuelve los datos remotos (`Success`); `Error` rethrow (fail-fast).
- `RestoreSessionUseCase` nunca hace logout; `Handle401UseCase` distingue
  fallos transitorios (`RetryNoConnection`, sin logout) de rechazos reales
  (`RetryFailed`, logout).
- El banner `ConnectivityBanner` (en `app/widgets/`) se muestra cuando
  `internetStatusProvider` emite `false`.
- El `AuthInterceptor` adjunta el `Authorization` header en `onRequest`
  (vía `getToken`) y maneja el 401.

## Boundary adapters: mapper vs serializer (no unificar)

`ClinicalHistoryMapper` (wire DTO ↔ Entity, `core/network/contracts/`) y
`ClinicalHistorySerializer` (Entity ↔ sembast Map, `core/database/serializers/`)
son **dos adaptadores de frontera distintos** con formatos de destino distintos.
No se fusionan por diseño. El `test/core/database/clinical_history_serializer_test.dart`
es el *guard* de consistencia: si el schema de la entidad cambia, el round-trip
falla hasta que ambos límites lo cubran.

Lo mismo aplica a `lab_results`: `LabResultsMapper` (wire DTO ↔ Entity, feature `infrastructure/mappers/`) y `LabResultsSerializer` (Entity ↔ sembast Map, `core/database/serializers/`) son adaptadores de frontera distintos con formatos de destino distintos — no se fusionan. El `test/core/database/lab_results_serializer_test.dart` es el guard de consistencia (round-trip con discriminador `LabResultKind`).