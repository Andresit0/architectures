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
MD/APP_PROVIDERS.md         ← Shared providers inventory (dio, token, goRouter), `_providers.lib.dart` composition root barrel, ref.watch/read/listen per context
MD/APP_SKILLS.md            ← Complete reference of all app_* skills and agents
MD/APP_STATE_MANAGMENT.md   ← State management overview (Riverpod v3 code-gen) + quick ref to APP_PROVIDERS.md
MD/APP_TREE.md              ← Show the file tree of the app. Use it always before write code
MD/AI_ARTIFACTS.md          ← How to create skills, agents, commands, orchestrators
```
---

## GIT
Before executing any git command, write the exact command and ask the user to confirm before running it.

### Git Flow (enforced)

Default branch: `main` (production). Integration branch: `develop`. See README §3 for the full model.

* `feature/*` → PR → `develop` (checks) → merge
* Dependabot (patch/minor) → PR → `develop` → checks → auto-merge
* `release/*` → PR → `main` (gate + checks + 1 approval) → tag `vX.Y.Z` → back-merge → `develop`
* `hotfix/*` → PR → `main`, then back-merge → `develop`
* Direct pushes to `main`/`develop` are blocked (branch protection, `enforce_admins`). All changes go through PRs.


---

## GoRouter — access via Riverpod provider

go_router is accessed exclusively via Riverpod `goRouterProvider` (in `app/di/router/router_provider.dart`). No static `CustomFunction` exists — use `ref.watch(goRouterProvider)` instead.

| Symbol | Access |
|---|---|
| `goRouterProvider` | `ref.watch(goRouterProvider)` in `main.dart` (returns `GoRouter`); `ref.read(goRouterProvider).go(...)` from features |

---

## Shared Models — barrel pattern

Shared domain entities live in `lib/shared/models/`. The barrel `_models.lib.dart` exports entity files directly.

| Subdirectory | Entities |
|---|---|
| `patient/` | `PatientEntity` |
| `clinical_history/` | `ClinicalHistoryEntity` + 6 sub-entities (service, facility, professional, diagnosis, attachment, state) |

**Access from features:**
```dart
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
```

Or import the barrel for convenience:
```dart
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
```

These entities were extracted from `features/auth/domain/entities/` and placed in `shared/models/` because they are shared domain models used by `core/database/` and potentially by multiple features.

---

## Database — access via Riverpod providers

Database access is now managed through `core/database/` with Riverpod providers, not `CustomDb`.

| Provider | Type | Access from features |
|---|---|---|
| `appDatabaseProvider` | `Provider<IAppDatabase>` | `ref.watch(appDatabaseProvider)` |
| `IAppDatabase.database` | `Future<ISembastDb>` | `await ref.read(appDatabaseProvider).database` — get sembast database wrapper |
| `IAppDatabase.resetDatabase()` | `Future<void>` | `await ref.read(appDatabaseProvider).resetDatabase()` — clears sembast database |

**Test override pattern:**
```dart
return ProviderScope(
  overrides: [
    appDatabaseProvider.overrideWith((ref) => FakeAppDatabase()),
  ],
  child: ...,
);
```

---

## CustomInterceptors — access rule

Interceptors live in `lib/core/network/interceptors/` with their own barrel `_interceptors.lib.dart`.

| Symbol | Access |
|---|---|
| `AuthInterceptor(onRetry, internalDio)` | Used internally by `DioWrapper` to add the `Authorization` header + handle 401 retry; do not use directly from features |

> JWT utilities (`isTokenExpired`, `decodeJwtPayload`) belong to `JwtWrapper` / `JwtTokenExpiryChecker` in `core/services/auth/`, accessible via `ref.watch(jwtWrapperProvider)` or `ref.watch(tokenVerifierProvider)`.

---

## SOLID / DI conventions

The project use 2 skills that must be used always to maintain SOLID principles to WRITE CODE.

- When code is inside lib/core/services/ the skill used is `.ai/skills/app-class-to-solid-min/SKILL.md`.

- When the code is written inside lib/features the skill used is `.ai/skills/app-class-to-solid/SKILL.md`.

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

---

## Important info about "shared" vs "core"

The project has two cross-cutting directories with distinct roles:

- **`lib/shared/`** — Pure domain abstractions: error handling (`error/` with `AppError`, `Result<T>`, `guard()`), domain interfaces (`interfaces/` with `IAppDatabase`, `ISembastDb`, `IConnectivityChecker`, `ITokenStore`, `ITokenVerifier`, `IAuthenticationObserver`, etc.), exception classes (`exceptions/`), models/entities (`models/`), offline-first mixin (`functions/offline_first_repository.dart`). Domain layer can import from `shared/`.

- **`lib/core/`** — Pure infrastructure: service wrappers (`services/`), database (`database/`), network (`network/`), router adapter (`router/`), utils (`utils/`). Domain layer must NEVER import from `core/`.

- **`lib/app/`** — Application composition root: `_providers.lib.dart` barrel (`di/`), GoRouter setup (`router/`), app initializer.

- **`lib/core/config/`** — `AppEnvironment` sealed class + `environmentProvider`.

- **`lib/design_system/`** — Theme and reusable UI components (loading indicator, theme).

- **`lib/l10n/`** — AppLocalizations for i18n, wired into MaterialApp.router.