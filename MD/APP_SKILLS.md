---
name: app-skills
description: Minimum skills that should be read before writing code in the app.
---

# App Skills — Minimum reading before writing code

## Before writing any new feature

| Order | Skill | When required |
|---|---|---|
| 1 | `app-spec-definer` | Always — run before any code for a new feature |
| 2 | `app-lib-structure` | Always — confirm file location and architecture layer |
| 3 | `app-class-to-solid` | When writing code inside `lib/features/` |
| 4 | `app-class-to-solid-min` | When writing code inside `lib/core/services/` |
| 5 | `app-barrel` | When a new folder is created under `lib/` |
| 6 | `app-cp-package` | When a new pub.dev package is added to the project |
| 7 | `app-test-driven-development` | Before writing implementation code for any feature or bugfix |
| 8 | `app-changes` | When preparing commits or updating documentation — run to generate the Path / Changes table |
| 9 | `app-agent-api-extractor` | When extending or debugging the spec-dev pipeline — generates `generated_api_contract.md` from 6 spec files at Phase D.0.5 |

---

## app-spec-definer — spec-first workflow

Every new feature starts with a specification, not code.

**Skill:** `.ai/skills/app-spec-definer/SKILL.md`

⚠️ **Invoked by the orchestrator only.** Do NOT call this skill directly in response to "new feature" or similar phrases. The entry point is always `.ai/orchestrators/Spec-Local-Orchestrator.md` (or the `/spec-local` command). Call this skill directly only when the user explicitly says "run app-spec-definer directly" or "load skill app-spec-definer".

**What it produces** (written to `lib/features/<feature_name>/spec/`):

| File | Content |
|---|---|
| `spec.md` | SDD functional specification (YAML) |
| `bdd.feature` | BDD Gherkin scenarios |
| `tests.md` | TDD test plan (YAML) |
| `contracts.md` | API endpoint contracts (YAML) |
| `domain.md` | Domain models and interfaces (YAML) |
| `tasks.md` | Implementation task checklist |

**Reference examples:**
- `lib/features/auth/spec/` — auth
- `lib/features/clinical_history/spec/` — clinical_history

**How spec files feed coding agents:**

| Spec file | Consumed by |
|---|---|
| `spec.md` + `domain.md` | `app-class-to-solid` skill |
| `bdd.feature` + `tests.md` | `app-test-driven-development` skill |
| `contracts.md` | Infrastructure layer (datasource + mapper) |
| `tasks.md` | TodoWrite tool |

---

## app-spec-definition — collaborative refinement protocol

**Skill:** `.ai/skills/app-spec-definition/SKILL.md`

⚠️ **Invoked by the orchestrator only.** Used internally by the Spec-Local orchestrator as Phase A. Do NOT invoke this skill directly in response to feature requests. Call it directly only when the user explicitly says "run app-spec-definition directly" or "load skill app-spec-definition" (e.g., to revise an already-written spec in isolation).

---

## app-class-to-solid — feature architecture scaffold

**Skill:** `.ai/skills/app-class-to-solid/SKILL.md`

Transforms a plain Dart class into the full DI + Abstraction + Riverpod pattern:

```
interface → impl → repository → usecase → provider → notifier
```

Required whenever writing new code inside `lib/features/`.
Reads `domain.md` and `spec.md` from the spec folder to align naming.

---

## app-class-to-solid-min — shared service scaffold

**Skill:** `.ai/skills/app-class-to-solid-min/SKILL.md`

Applies DI + Riverpod + Interface to service classes inside `lib/core/services/`.

---

## app-barrel — barrel file generation

**Skill:** `.ai/skills/app-barrel/SKILL.md`

Generates `_[name].lib.dart` **pure-export barrels** for a folder under `lib/` (one `export '<file>.dart';` per public file — no `part`, no facade). **Exception:** `presentation/widgets/` folders are NOT barrelled — widgets are standalone files with explicit imports, no facade.

---

## app-cp-package — new package wrapper

**Skill:** `.ai/skills/app-cp-package/SKILL.md`

Convention for adding a new pub.dev package and creating a local wrapper (`<package>_wrapper.dart`) in `lib/core/services/<domain>/`.

Run before using any new package that does not yet have a wrapper in `lib/core/services/<domain>/`.

---

## app-test-driven-development — TDD workflow

**Skill:** `.ai/skills/app-test-driven-development/SKILL.md`

Drives the red-green-refactor cycle for any feature or bugfix.

Reads `bdd.feature` and `tests.md` from the spec folder to derive test cases before writing implementation code.

---

## app-changes — change summary generator

**Skill:** `.ai/skills/app-changes/SKILL.md`

Produces a structured two-column Markdown table (Path / Changes) from git status, diff, and log.

**Trigger phrases:** "what changed", "show changes", "get changes", "summarize changes"

Used by `app-agent-update-md` to identify what needs documentation updates.

---

## Spec-Dev Orchestrator Agents

These agents support the spec-dev workflow (see AGENTS.md Phase Flow):

---

### app-agent-spec-definer — spec package generator

**Skill:** `.ai/skills/app-agent-spec-definer/SKILL.md`

Creates all six spec artifacts in `lib/features/<name>/spec/` before any code is written.

⚠️ **Invoked by the orchestrator only (Phase B).** Do NOT call this agent directly in response to "new feature" or similar phrases. Call it directly only when the user explicitly says "run app-agent-spec-definer directly" or "load skill app-agent-spec-definer".

---

### app-agent-spec-definer-summary — spec summary agent

**Skill:** `.ai/skills/app-agent-spec-definer-summary/SKILL.md`

Creates the 6 spec artifacts in `lib/features/<name>/spec/` and returns ONLY a concise summary table (file/path/summary) to keep orchestrator context small.

Used internally by `app-agent-spec-definer` to deliver structured output.

---

### app-agent-api-extractor — canonical API contract generator

**Skill:** `.ai/skills/app-agent-api-extractor/SKILL.md`

Reads all 6 spec artifacts for a feature and produces a single normalized `generated_api_contract.md` that every subsequent test writer and implementation agent uses as the source of truth.

Invoked at Phase D.0.5 by the orchestrator. Never call directly.

---

### app-agent-phase-gate — pre-code audit

**Skill:** `.ai/skills/app-agent-phase-gate/SKILL.md`

Audits spec pre-conditions before spec-dev: 6 spec files complete with valid bdd.feature, domain.md usecases and state variants, and unchecked tasks.md items. Wrappers are NOT checked here — that audit runs at D.10.5 after all imports are known.

**Verdict:** PASS | FAIL | BLOCKED — blocks spec-dev until all checks pass.

---

### app-spec-dev — TDD implementation skill

**Skill:** `.ai/skills/app-spec-dev/SKILL.md` (Spec-Local v3 — TDD-First Guarded Workflow)

Full TDD implementation from spec folder: All-Tests-First + 12 phases (Phase 0.1–0.4 write all tests from spec, then stub → RED → implement → GREEN per layer). Orchestrator delegates sub-phases via `task()`; spec-dev must be invoked through the Spec-Local orchestrator unless the user explicitly runs the skill directly.

Required for complete feature implementation after spec is ready.

---

### app-agent-spec-dev-supervisor — phase auditor

**Skill:** `.ai/skills/app-agent-spec-dev-supervisor/SKILL.md`

Phase-by-phase verifier for spec-dev. Verifies each D sub-phase (returns PASS | VIOLATION), enforces the All-Tests-First contract, runs a RED Quality Audit to detect artificial test failures, and performs contract-drift checks against `generated_api_contract.md`. On critical violations it stops execution and triggers repair; a repair loop limit (maximum 2 attempts per phase) is enforced before escalation.

---

### app-agent-domain-test-writer — domain test stub creator

**Skill:** `.ai/skills/app-agent-domain-test-writer/SKILL.md`

Writes domain tests from domain.md BEFORE any stubs exist (Phase D.0). Tests compile-pending until stubs exist at Phase D.2, then run RED.

---

### app-agent-presentation-test-writer — presentation test stub creator

**Skill:** `.ai/skills/app-agent-presentation-test-writer/SKILL.md`

Writes presentation tests from domain.md BEFORE any notifier, state, or screen exists (Phase D.0). Tests compile-pending until Phase D.6 writes the code, then run RED at D.7.

---

### app-agent-integration-test-writer — integration test creator

**Skill:** `.ai/skills/app-agent-integration-test-writer/SKILL.md`

Creates the integration test file from bdd.feature + domain.md (Phase D.0). Derives repository interface from domain.md before production code exists.

---

### app-agent-bdd-writer — BDD test writer

**Skill:** `.ai/skills/app-agent-bdd-writer/SKILL.md`

Creates the BDD test file from bdd.feature using gherkart (Phase D.0). Derives state variants from domain.md before notifier exists. Enforces top-level `_testFunction` rule. Runs GREEN at D.9.5 after implementation is complete.

---

### app-agent-fix-analyzer-issues — analyze fixer

**Skill:** `.ai/skills/app-agent-fix-analyzer-issues/SKILL.md`

Fixes flutter analyze issues file-by-file. Re-runs analyze until 0 issues.

---

### app-agent-fix-tests — test fixer

**Skill:** `.ai/skills/app-agent-fix-tests/SKILL.md`

Fixes failing tests. Analyzes each failure, fixes implementation or test, re-runs until 0 failures.

---

### app-agent-nav-wirer — navigation wiring

**Skill:** `.ai/skills/app-agent-nav-wirer/SKILL.md`

Wires navigation: AppRoute enum entry in `shared/router/app_route.dart`, GoRoute in `app_router.dart`, screen import, trigger in parent screen via `IAppNavigator` (never `goRouterProvider`).

---

### app-agent-update-md — documentation sync

**Skill:** `.ai/skills/app-agent-update-md/SKILL.md`

Updates MD/* and AGENTS.md based on project changes. Bucket A (`.ai/*`) requires user approval, Bucket B (lib/*, test/*, integration_test/*) auto-updates.

**Trigger phrases:** "update docs", "update MD files", "sync documentation"

---

### app-agent-cp-package — wrapper creator

**Skill:** `.ai/skills/app-agent-cp-package/SKILL.md`

Sub-agent dedicated to creating `<package>_wrapper.dart` wrappers for new pub.dev packages. Invoked by the orchestrator at D.10.5 (DirectImport-Auditor repair) when a direct package import is found in feature code.

⚠️ **Do NOT use `app-cp-package` skill directly for wrappers required by a feature.** The orchestrator delegates this via `task()` to this agent.

---

### app-agent-context-reader — context centralizer

**Skill:** `.ai/skills/app-agent-context-reader/SKILL.md`

Reads Engram memory and the relevant MD/* files for a given feature/query and returns a structured context report.

⚠️ No longer part of the spec-dev workflow — spec-dev reads MD files directly.

---

### app-agent-dry-enforcer — DRY scanner

**Skill:** `.ai/skills/app-agent-dry-enforcer/SKILL.md`

Scans `.ai/` for duplicated content across skills, agents, commands, orchestrators. Extracts shared logic into reusable `app_*` skills.

**Trigger phrases:** "find duplicates", "enforce DRY", "extract shared skill"
