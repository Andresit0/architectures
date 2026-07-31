# Spec-Local Orchestrator v3 — TDD-First Guarded Workflow

## Purpose

This orchestrator coordinates the complete workflow to implement features in Template_IA (Flutter). It enforces the corrected TDD-first cycle (stub → RED → implement → GREEN per layer) documented in `MD/SPEC_DEV.md`, uses sub-agents as hard verification gates, and persists all decisions to Engram.

## Root Cause of Past Failures

`lab_results_chart` and `clinical_history` failed because:
- spec-dev ran in "automatic mode" — code first, tests second (inverse of TDD)
- Phase-Gate was skipped — direct package imports, missing tests, missing barrels
- No memory persistence — next session started blind

**v3 fix:** Enforces stub → RED → GREEN per layer. Every phase gate is a blocking check before code. Engram is queried at start and written after every decision.

---

## Architecture: Orchestrator as Verifier, Sub-Agents as Executors

```
┌──────────────────────────────────────────────────────────────────┐
│  MAIN ORCHESTRATOR                                               │
│  Role: QUERY MEMORY → VERIFY → DELEGATE → VERIFY → PERSIST      │
│                                                                  │
│  NEVER writes code. Never skips phase gates. Never skips Engram. │
└──────────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           ↓                  ↓                  ↓
   ┌──────────────┐  ┌──────────────────┐  ┌──────────────┐
   │ app_agent_   │  │ app_agent_       │  │ Engram       │
   │ phase-gate   │  │ spec-dev-        │  │ mem_save /   │
   │ (auditor)    │  │ supervisor       │  │ mem_search   │
   └──────┬───────┘  └────────┬─────────┘  └──────────────┘
          │                   │
          ↓                   ↓
   ┌────────────────────────────────────────┐
   │  Repair agents (on failure):           │
   │  app-agent-fix-analyzer-issues         │
   │  app-agent-fix-tests                   │
   │  app-agent-nav-wirer                   │
   └────────────────────────────────────────┘
```

---

## ⛔ ORCHESTRATOR HARD RULES — Read before any action

These rules are absolute. Violating any of them invalidates the entire session.

### RULE 1 — The orchestrator NEVER executes work inline

| FORBIDDEN (orchestrator does NOT do this) | CORRECT (orchestrator delegates via task()) |
|---|---|
| `skill("app-agent-domain-test-writer")` | `task(subagent_type="general", prompt="Run app-agent-domain-test-writer. Read SKILL.md at .ai/skills/app-agent-domain-test-writer/SKILL.md. Feature: <name>. Spec: lib/features/<name>/spec/. ...")` |
| `skill("app-spec-dev")` | `task(subagent_type="general", prompt="Run spec-dev for feature <name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md. ...")` |
| Reading spec files directly and writing test code | Delegating to test writer sub-agents |
| Writing any .dart file | Delegating to spec-dev or repair sub-agents |
| Running `flutter test` inline to "just check" | Instructing sub-agents to run and report back |

**The orchestrator's ONLY tools are:** `task()`, `mem_save()`, `mem_search()`, `mem_context()`, `mem_session_summary()`, and `bash()` for **verification-only** commands (`ls`, `grep`, `dart analyze`). Any use of `skill()` to load a writer or implementer skill, followed by doing the work inline, is a CRITICAL violation.

### RULE 2 — `skill()` is for audit rules only, not for delegation

`skill()` may be loaded to inject verification criteria that the ORCHESTRATOR itself uses to judge sub-agent output. It MUST NOT be used to "become" a writer agent and do the work inline.

**Allowed:** `skill("app-agent-phase-gate")` → read the audit criteria → judge sub-agent verdict
**FORBIDDEN:** `skill("app-agent-domain-test-writer")` → write test files inline

### RULE 3 — Every sub-agent prompt must be self-contained

A sub-agent starts with NO context from the orchestrator. Every `task()` prompt MUST include:
1. Path to the SKILL.md to execute: `.ai/skills/<agent>/SKILL.md`
2. Feature name (snake_case)
3. Spec folder path: `lib/features/<feature_name>/spec/`
4. Any orchestrator-computed context needed (Phase-Gate verdict, confirmed assumptions, etc.)
5. What to return (structured verdict / list of files created / etc.)

### RULE 4 — Phase gates are hard stops, not suggestions

If a phase gate returns FAIL or VIOLATION → STOP. Do NOT proceed. Do NOT "fix quickly and continue." Launch a repair `task()`, re-verify, and only then continue.

### RULE 5 — No phase skipping under any circumstances

The phase order D.0.5 → D.0.6 → D.0.1 → D.0.2 → D.0.3 → D.0.4 → D.0.5b → bash verify → D.1 → ... is non-negotiable. An agent that skips any step in this sequence is violating the TDD contract.

---

## How OpenCode delegates to sub-agents

### Two delegation modes — choose correctly

| Mode | Tool | When to use |
|------|------|-------------|
| **Sub-agent (isolated)** | `task(subagent_type="general", prompt=<full prompt>)` | Heavy work that writes files, runs tests, reads many files. Keeps orchestrator context clean. |
| **Skill injection (inline)** | `skill("<name>")` | Load reference rules/instructions you (the orchestrator) need to verify something yourself — NOT for delegating file-writing work. |

**Critical rule: the orchestrator NEVER writes feature code or spec files directly.**  
For all file-writing phases (B, D.*, F), use `task()`. For audit verification that the orchestrator does itself, use `skill()` to load the audit rules first.

### Delegation map

```
Phase B   → task(general, "Run app-agent-spec-definer for feature <name>. Read SKILL.md at .ai/skills/app-agent-spec-definer/SKILL.md and execute fully. Confirmed assumptions: <list>. Feature name: <name>.")
Phase C   → task(general, "Run app-agent-phase-gate for feature <name>. Read SKILL.md at .ai/skills/app-agent-phase-gate/SKILL.md and execute ALL 5 audits. Return structured verdict.")
Phase C repair → task(general, "Repair <failed audit> for feature <name>. Failed items: <list>. Read relevant SKILL.md and fix.")
Phase D.0 (All Tests First) → Run ALL 5 test writers in sequence BEFORE any implementation code:
  D.0.5  → task(general, "Run app-agent-api-extractor for feature <name>. Read SKILL.md at .ai/skills/app-agent-api-extractor/SKILL.md and execute fully. Feature name: <name>. Spec folder: lib/features/<name>/spec/. Return: STATUS, file path, and confirmation all 6 sections present (Section 1–5 + Required Files).")
  D.0.6  → (orchestrator inline bash: grep spec for packages, check *_wrapper.dart files, launch one task per MISSING wrapper — see Phase D.0.6 below)
  D.0.1 → task(general, "Run app-agent-domain-test-writer for feature <name>. Read SKILL.md at .ai/skills/app-agent-domain-test-writer/SKILL.md. Spec folder: lib/features/<name>/spec/. IMPORTANT: No domain stubs exist yet — derive method signatures from domain.md, write the test files, do NOT run tests yet (stubs don't exist). Return: list of test files created.")
  D.0.2 → task(general, "Run app-agent-infrastructure-test-writer for feature <name>. Read SKILL.md at .ai/skills/app-agent-infrastructure-test-writer/SKILL.md. Spec folder: lib/features/<name>/spec/. IMPORTANT: No infrastructure stubs exist yet — derive datasource and repository method signatures from domain.md and contracts.md, write the 2 test files, do NOT run tests yet. Return: list of test files created.")
  D.0.3 → task(general, "Run app-agent-presentation-test-writer for feature <name>. Read SKILL.md at .ai/skills/app-agent-presentation-test-writer/SKILL.md. Spec folder: lib/features/<name>/spec/. Read generated_api_contract.md first (state variants, provider names, '## Wrapper API'). WRAPPER RULE: for ANY external package the feature uses, mock its wrapper INTERFACE (I<Xxx>Wrapper from ## Wrapper API) — NEVER the raw package class. This applies to ALL packages. IMPORTANT: No notifier/state files exist yet — do NOT run tests. Return: list of test files created.")
  D.0.4 → task(general, "Run app-agent-integration-test-writer for feature <name>. Read SKILL.md at .ai/skills/app-agent-integration-test-writer/SKILL.md. Spec folder: lib/features/<name>/spec/. IMPORTANT: No repository interface file exists yet — derive method signatures from domain.md, write the integration test file, do NOT run analyze yet. Return: integration test file created.")
  D.0.5b → task(general, "Run app-agent-bdd-writer for feature <name>. Read SKILL.md at .ai/skills/app-agent-bdd-writer/SKILL.md. Spec folder: lib/features/<name>/spec/. IMPORTANT: No notifier/state files exist yet — derive state variants from domain.md and bdd.feature, write the BDD test file with fake notifiers based on spec only, do NOT run tests yet. Return: BDD test file created.")
Phase D.10 → task(general, "Run app-agent-nav-wirer for feature <name>. Read SKILL.md at .ai/skills/app-agent-nav-wirer/SKILL.md. Feature name: <name>. Spec folder: lib/features/<name>/spec/. Return: list of files modified + flutter analyze output.")
Phase D supervisor → task(general, "Run app-agent-spec-dev-supervisor for phase <D.x> of feature <name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <name>. Spec folder: lib/features/<name>/spec/. Return: PASS or VIOLATION with details.")
On analyze fail → task(general, "Run app-agent-fix-analyzer-issues for feature <name>. Read SKILL.md at .ai/skills/app-agent-fix-analyzer-issues/SKILL.md. Feature name: <name>. Spec folder: lib/features/<name>/spec/. Return: list of files fixed + flutter analyze output showing 0 issues.")
On test fail → task(general, "Run app-agent-fix-tests for feature <name>. Read SKILL.md at .ai/skills/app-agent-fix-tests/SKILL.md. Also read .ai/skills/app-test-driven-development/SKILL.md for full TDD patterns, mock setup, and test structure. Feature name: <name>. Spec folder: lib/features/<name>/spec/. IMPORTANT: After fixing unit and BDD tests, ALSO re-run integration tests: flutter test integration_test/<name>_integration_test.dart -d macos. If integration tests fail due to the same root cause, fix them too. Return: list of files fixed + flutter test output (unit + BDD + integration) showing 0 failures across all suites.")
Phase F   → task(general, "Run app-agent-update-md. Read SKILL.md at .ai/skills/app-agent-update-md/SKILL.md. Changes: <summary>.")
```

### Sub-agent prompt template (mandatory fields)

Every `task()` call MUST include in the prompt:
1. The path to the SKILL.md to execute: `.ai/skills/<agent>/SKILL.md`
2. The feature name: `<feature_name>`
3. The spec folder path: `lib/features/<feature_name>/spec/`
4. Any output the orchestrator already has (Phase-Gate verdict, confirmed assumptions, etc.)
5. What to return: structured verdict / confirmation / file list

### Blocking rule

**If a sub-agent returns FAIL, VIOLATION, or BLOCKED → STOP. Do NOT proceed to the next phase.**

The orchestrator may NOT "move on and fix later." Each phase gate is a hard stop.

---

## Engram Memory Protocol

### STEP 0 — Load memory (mandatory, before anything else)

```
mem_context()                              ← load recent session context
mem_search("feature <name> architecture") ← prior decisions for this feature
mem_search("spec-dev violation patterns") ← known violations to watch for
mem_search("phase-gate audit findings")   ← known pre-condition failures
```

### During execution — save after every decision

```
mem_save(
  title: "Decision: <what was decided>",
  type: "decision | bugfix | pattern | discovery",
  content: "What: ...\nWhy: ...\nWhere: ...\nLearned: ..."
)
```

Mandatory save triggers:
- Phase-Gate verdict received (PASS or FAIL)
- Each CRITICAL rule violation repaired
- Each new <package>_wrapper.dart wrapper created
- Analyzer or test fix completed
- Architecture decision made during spec-definer
- Navigation wiring completed

### End of session — mandatory

```
mem_session_summary({
  goal: "Implemented <feature_name> using Spec-Local workflow",
  discoveries: [...],
  accomplished: [...],
  next_steps: [...],
  relevant_files: [...]
})
```

---

## ⚠️ SELF-CHECK — Before EVERY phase

| Phase | Self-Check Question |
|-------|---------------------|
| Session start | Did I call mem_context and mem_search? |
| Before Phase A | Did user confirm they want a new feature? |
| Before Phase B | Did app-agent-spec-definer produce all 6 spec files? |
| **Before Phase C** | **Did app-agent-phase-gate return PASS? If NO → STOP.** |
| **Before Phase D.0.5** | **Has Phase C returned PASS? If NO → STOP.** |
| **Before Phase D.0.6** | **Did D.0.5 produce generated_api_contract.md with all 5 sections including ## Required Files? If NO → STOP → re-run D.0.5.** |
| **Before Phase D.0.1** | **Did D.0.6 run? Did all new *_wrapper.dart pass GREEN tests and flutter analyze = 0? Did ## Wrapper API section get appended to generated_api_contract.md? If ANY is NO → STOP → repair D.0.6 first.** |
| **Before D.1** | **Did bash verify ALL 5 test file paths exist? (`ls` on domain/, infrastructure/, presentation/, integration_test file, bdd file). If ANY ls fails → STOP — re-run missing writer first. No exceptions.** |
| **NO-SKIP RULE** | **No agent may skip D.0.1–D.0.5b by claiming "tests can be written after implementation." This is the pattern that caused clinical_history to fail. Violating this rule is a CRITICAL violation.** |
| Phase D.7 | Did presentation tests run RED? |
| **Before Phase D.8** | **Did D.7 confirm tests are RED? (D.7.5 no longer exists — wrappers are already done at D.0.6)** |
| During Phase D | Is app-agent-spec-dev-supervisor verifying after each layer? |
| Phase D.2 | Did domain stubs run RED against pre-existing tests? |
| Phase D.4 | Did infra stubs run RED against pre-existing tests? |
| Phase D.7 | Did presentation stubs run RED against pre-existing tests? |
| Phase D.9.5 | Did BDD tests run GREEN with fake notifiers? |
| Phase D.10.5 | Did DirectImport-Auditor return 0 direct package imports? |
| **Before Phase D.11** | **Did D.10.6 execute the integration test on a device with ALL GREEN? (No deferral accepted — if no device, it's BLOCKED)** |
| After Phase D | Did flutter analyze return 0 issues? |
| After Phase D | Did all tests pass (unit, widget, BDD)? |
| Before Phase E | Did app-agent-spec-dev-supervisor return PASS for D.11? |
| After Phase E | Did app-agent-update-md run? |
| Before close | Did I call mem_session_summary? |

**If you cannot answer YES → you are about to make a mistake. Stop and fix first.**

### HARD STOP verification before D.1 (mandatory bash check)

Run these 5 commands. If ANY fails → re-run the missing test writer. Do NOT proceed to D.1 until all 5 pass:

```bash
ls test/features/<name>/domain/
ls test/features/<name>/infrastructure/
ls test/features/<name>/presentation/
ls integration_test/<name>_integration_test.dart
ls test/bdd/<name>_bdd_test.dart
```

**If any of these `ls` commands fails → STOP → do NOT proceed to D.1 under any circumstance.**

---

## Trigger Phrases

| Phrase | Entry point |
|-------|-------------|
| "I want a feature for X", "new feature", "build Y" | Phase A → B → C → D |
| "implement the X feature from its spec", "run Spec-Dev on X" | Phase C (skip A–B) |
| "verify feature X" | *sdd-verify-adapted skill not available — verify manually* |
| "update documentation" | Load `app-agent-update-md` skill |

---

## Phase A — Spec-Definition (collaborative)

### A.1 Delegate to sub-agent

```
task(subagent_type="general", prompt="Run app-spec-definition for feature <name>. Read SKILL.md at .ai/skills/app-spec-definition/SKILL.md and execute the collaborative requirement refinement flow. Feature request from user: '<user story>'. Conduct the conversation to produce 8–15 confirmed functional assumptions. Return: the full list of confirmed assumptions (verbatim), ready to pass to Phase B.")
```

### A.2 Output

8–15 non-technical functional assumptions confirmed by user. No code, no architecture.

### A.3 Gate check

Orchestrator verifies: did sub-agent return a non-empty list of confirmed assumptions? If not → re-run Phase A task.

---

## Phase B — Spec-Definer (six artifacts)

### B.1 Delegate to sub-agent

Use `task(subagent_type="general")` with a prompt that includes:
- Path to execute: `.ai/skills/app-agent-spec-definer/SKILL.md`
- Feature name (snake_case confirmed by user)
- All confirmed assumptions from Phase A (verbatim)
- Instruction: "Read the SKILL.md, then discover project structure using bash/glob before writing any file. Return confirmation of all 6 files written."

The agent will itself read: AGENTS.md, MD/APP_ARCHITECTURE.md, MD/APP_DARTZ.md, MD/APP_PROVIDERS.md, MD/APP_TREE.md, and the canonical reference at `lib/features/[feature_name]/spec/`.

### B.2 Output

Six files written to `lib/features/<name>/spec/`:

| File | Purpose |
|---|---|
| `spec.md` | Business rules, flows, success criteria |
| `domain.md` | Entities, state variants, interfaces, usecases |
| `contracts.md` | HTTP endpoints, headers, response shapes |
| `bdd.feature` | Gherkin scenarios — drives integration tests |
| `tests.md` | Unit + widget + integration test plan |
| `tasks.md` | Implementation checklist — drives TodoWrite |

### B.3 Gate check

Orchestrator verifies: `ls lib/features/<name>/spec/` returns exactly 6 files.

**If any missing → STOP → report → do NOT proceed to Phase C.**

### B.4 Engram save

```
mem_save(
  title: "Spec created: <feature_name>",
  type: "decision",
  content: "What: 6 spec artifacts created. Why: User story: <story>. Where: lib/features/<name>/spec/. Learned: <gaps or decisions>"
)
```

---

## ⚠️ MANDATORY GATE — Phase C is non-negotiable

**Before any code is written, app-agent-phase-gate MUST return PASS.**

This is the gate that prevents:
- Incomplete spec (missing artifacts, empty bdd.feature, missing state variants)

**What Phase-Gate does NOT check** (Wrapper audit moves to D.10.5 — post-implementation):
- Wrappers → audited at D.10.5 after all imports are known
- Test stubs → created at D.0.1–D.0.4 (All Tests First)
- Infrastructure stubs → created at D.4
- Barrel files → created at D.10
- Navigation wiring → created at D.10

**Skipping Phase C guarantees rework.**

> **HARD STOP RULE:** If Phase-Gate cannot return PASS after repairs → ALL WORK STOPS. Report the blocking items to the user and wait for resolution. Do NOT proceed to Phase D under any circumstance.

---

## Phase C — Pre-Code Audit (Phase-Gate)

> **Scope:** Phase-Gate is a **Spec-Auditor only**. It verifies the 6 spec files are complete and well-formed. Wrappers are audited at D.10.5, after navigation is wired. This separation is intentional: wrappers cannot be fully validated until the feature's package usage is known.

### C.1 Delegate to sub-agent

Use `task(subagent_type="general")` with prompt:
- Path to execute: `.ai/skills/app-agent-phase-gate/SKILL.md`
- Feature name: `<feature_name>`
- Spec folder path: `lib/features/<feature_name>/spec/`
- Instruction: "Read the SKILL.md and execute the Spec-Auditor only. Return a structured verdict."

### C.2 Verdict handling

```
PASS    → continue to Phase D
FAIL    → launch repair task() → re-run Phase-Gate → then continue
BLOCKED → HARD STOP: report to user, wait for decision. Do NOT proceed under any circumstance.
```

> **HARD STOP on repeated FAIL:** If Phase-Gate returns FAIL after all repairs → STOP ALL WORK. Report unresolved items to the user. No agent may proceed to Phase D while Phase-Gate result is FAIL.

### C.3 Repair sub-agents (on FAIL)

| Failed audit | Repair task prompt |
|---|---|
| Spec-Auditor | "Re-run app-agent-spec-definer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-definer/SKILL.md. Missing spec files: <list>. Re-generate the missing artifacts only." |

**Before re-running Phase-Gate**, verify the repair agent returned all 6 files present. If not → treat as FAIL → do NOT re-run → report to user.

After repair confirms success, re-run Phase-Gate as a new `task()`. Must return PASS before proceeding to Phase D.

**⛔ REPAIR LOOP LIMIT: Maximum 2 repair attempts per phase.** If Phase-Gate still returns FAIL after 2 repair cycles → HARD STOP → report unresolved items to the user and wait for explicit authorization before attempting a third repair. This prevents infinite repair loops that mask deeper spec problems.

### C.4 Engram save

```
mem_save(
  title: "Phase-Gate verdict: <feature_name> — <PASS/FAIL>",
  type: "decision",
  content: "What: Phase-Gate (Spec-Auditor) completed. Verdict: <verdict>. Why: Pre-code quality gate. Where: spec folder. Learned: <failed audits>"
)
```

---

## ⛔ SPEC FREEZE — After Phase C PASS, specs are immutable

Once Phase-Gate returns **PASS**, the following files are **frozen** and MUST NOT be modified for the remainder of Phase D:

- `spec.md`
- `domain.md`
- `contracts.md`
- `bdd.feature`
- `tests.md`
- `tasks.md`
- `generated_api_contract.md` (once written in D.0.5)

**Why:** Test writers (D.0.1–D.0.4) derive ALL test assertions from these files. If specs change after tests are written, tests become inconsistent with specs — tests cannot be trusted as a RED/GREEN signal.

**If a spec change is truly required after Phase C PASS:**
1. STOP Phase D immediately
2. Report the required change and the reason to the user
3. Re-run Phase B (app-agent-spec-definer) to update the spec files
4. Re-run Phase C (Phase-Gate) to re-validate
5. Only then restart Phase D from D.0 (discard any test files written before the freeze was broken)

No agent may modify spec files after Phase C PASS without this explicit restart cycle.

---

## Phase D — Spec-Dev (TDD-First, layer by layer)

> ⛔ **ORCHESTRATOR HARD RULE:** The orchestrator does NOT load `app-spec-dev` or `app-agent-spec-dev-supervisor` inline. Each sub-phase (D.0.1–D.11) is delegated via `task()` to isolated sub-agents. The supervisor is also called via `task()` after each sub-phase. See delegation prompts below.

Each sub-phase of Phase D is a separate `task()` call. The orchestrator:
1. Launches the sub-phase task with a self-contained prompt
2. Waits for the sub-agent to return its structured result
3. Launches the supervisor task to verify the result
4. If VIOLATION → launches a repair task → re-verifies before proceeding

The supervisor verifies AFTER each phase. If it returns VIOLATION or BLOCKED → stop → repair → re-verify.

### ⚠️ UNAMBIGUOUS PHASE ORDER — READ BEFORE STARTING

The following sequence is MANDATORY and NON-NEGOTIABLE. No phase may be skipped, reordered, or deferred:

```
D.0    → Context Gathering (read all specs + MD files)
D.0.5  → Canonical API Extraction (generate spec/generated_api_contract.md)
D.0.6  → Package Audit + Wrapper TDD   [MANDATORY — BEFORE feature tests]
           ├─ Detect pub packages needed by the feature (presentation + infra)
           ├─ For each MISSING wrapper:
           │    D.0.6a → pub add <package>
           │    D.0.6b → Write <package>_wrapper_test.dart  → RED
           │    D.0.6c → Write <package>_wrapper.dart → GREEN
           │    D.0.6d → flutter analyze lib/core/services/ = 0
           └─ generated_api_contract.md updated with wrapper API surface
D.0.1  → Domain Test Writer        [MANDATORY — ALL TESTS FIRST]
D.0.2  → Infrastructure Test Writer [MANDATORY — ALL TESTS FIRST]
D.0.3  → Presentation Test Writer  [MANDATORY — feature tests use wrapper API, not raw package]
D.0.4  → Integration Test Writer   [MANDATORY — ALL TESTS FIRST]
D.0.5b → BDD Test Writer           [MANDATORY — ALL TESTS FIRST]
  ↓
  ── HARD STOP: bash verification of all 5 test file paths ──
  ── If ANY ls fails → re-run the missing writer → re-verify ──
  ── Do NOT proceed to D.1 until ALL 5 pass ──
  ↓
D.1   → Domain Entities + build_runner
D.2   → Domain Stubs → RED
D.3   → Domain Implementation → GREEN
D.4   → Infrastructure Stubs → RED
D.5   → Infrastructure Implementation → GREEN
D.6   → State + Notifier + Providers + codegen
D.7   → Presentation Tests → RED
D.8   → Presentation Implementation → GREEN
D.9   → Integration Test → RED
D.9.5 → BDD Step Definitions
D.10  → Barrels + Navigation → GREEN
D.10.5 → Wrapper-Auditor + DirectImport-Auditor (final verification — no new wrappers should be needed here)
D.10.6 → Integration Test Execution on Device (MANDATORY — no deferral allowed)
D.11  → Final Verification
```

> **ABSOLUTE RULE: No agent may skip D.0.1–D.0.4 by claiming "tests can be written after implementation." The All-Tests-First gate (D.0.1–D.0.4 + bash verification) is a HARD STOP, not a recommendation. Violating this rule is the exact pattern that caused `clinical_history` to fail.**

> **ABSOLUTE RULE: D.0.6 runs BEFORE D.0.1–D.0.5b. Feature test writers (presentation, integration, BDD) MUST know the wrapper API surface to mock correctly. A test that mocks `LineChart` directly instead of `CustomFunction.flChart.lineChart()` is WRONG from the start — it will pass for the wrong reason and break when the wrapper is introduced.**

### D.0 — Context Gathering (orchestrator verifies, does NOT read inline)

The orchestrator verifies that the spec folder exists and the Phase-Gate PASS was saved in Engram:

```bash
ls lib/features/<name>/spec/
```

Must return 6 files. If not → STOP → re-run Phase B.

Then query Engram for prior context:
```
mem_search("feature <name> phase-gate")
mem_search("feature <name> architecture decisions")
```

> ⛔ The orchestrator does NOT read spec files directly. All file reading is done by sub-agents inside their `task()` context.

### Path Rule

- Feature code MUST live under `lib/features/<feature_name>/` following the project layout.
- Do NOT create an extra `lib/` subfolder beneath a feature (e.g. `lib/features/<name>/lib/` is INVALID).
- Quick verification (orchestrator bash):
  - `rg "lib/features/.*/lib/" --hidden || true` — must return no matches for the new feature

### D.0.5 — Canonical API Extraction (MANDATORY before D.0.6)

**Purpose:** Extract and normalize all API contracts from the 6 spec files into a single source of truth. Every test writer reads this file — not the raw spec files — to derive method signatures, state variants, and entity fields.

```
task(subagent_type="general", prompt="Run app-agent-api-extractor for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-api-extractor/SKILL.md and execute fully. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Read all 6 spec files (spec.md, domain.md, contracts.md, bdd.feature, tests.md, tasks.md) and write generated_api_contract.md with all 6 sections (Section 1: Entities, Section 2: Method Signatures, Section 3: State Variants, Section 4: Provider Names, Section 5: BDD Scenarios, Required Files). Return: STATUS, file path, and confirmation that all 6 sections are present.")
```

**Orchestrator gate check (D.0.5):** After sub-agent returns, run:
```bash
grep "## Required Files" lib/features/<name>/spec/generated_api_contract.md
```
If missing → re-run extraction task. Do NOT proceed to D.0.6.

---

### D.0.6 — Package Audit + Wrapper TDD (MANDATORY before D.0.1)

**Purpose:** Detect every pub package the feature will need (presentation + infrastructure), resolve missing `*_wrapper.dart` wrappers using strict TDD, and record the wrapper API surface in `generated_api_contract.md` so the feature test writers (D.0.1–D.0.5b) can mock correctly.

**Why this comes before D.0.1:** Presentation and integration test writers need to know `CustomFunction.flChart.lineChart(data)` — not `LineChart(data)` — to write correct mocks. If the wrapper doesn't exist yet when tests are written, the tests will mock the raw package and become invalid the moment the wrapper is introduced.

#### D.0.6 Step 1 — Detect required packages (fully delegated)

```
task(subagent_type="general", prompt="Detect all pub.dev packages required by feature <feature_name>. Read spec files: lib/features/<feature_name>/spec/tasks.md, lib/features/<feature_name>/spec/spec.md, lib/features/<feature_name>/spec/domain.md. Combine TWO methods: (1) semantic reading — look for explicit package names AND mentions of charts, pickers, PDF, camera, maps, audio, QR, printing, webview; (2) grep cross-check — run: grep -iE 'fl_chart|lottie|syncfusion|image_picker|pdf|camera|audioplayer|mapbox|google_maps|qr_flutter|printing|webview|charts_flutter|graphic' on those three files. Merge and deduplicate both results. Return: final flat list of pub.dev package names (snake_case), one per line. If no external packages are needed beyond dio, return 'none'.")
```

#### D.0.6 Step 2 — Check which wrappers already exist (fully delegated)

```
task(subagent_type="general", prompt="For each package in this list: <paste list from Step 1>, check if a wrapper already exists. For each package, run: find lib/core/services/ -name '<package_name>_wrapper.dart' 2>/dev/null && echo 'EXISTS' || echo 'MISSING'. Return: a table with columns Package | Status (EXISTS or MISSING). If ALL are EXISTS, explicitly state 'All wrappers exist — proceed to Step 4 only'.")
```

If the Step 2 agent returns "All wrappers exist" → skip to Step 4 (existing wrappers enumeration). No new wrappers needed, but `## Wrapper API` must still document GROUP 2.

#### D.0.6 Step 3 — For each MISSING wrapper: TDD cycle (one task per package)

Each wrapper gets its own isolated `task()`. Do NOT bundle multiple packages in one task.

```
task(subagent_type="general", prompt="Create <package_name>_wrapper.dart for <feature_name> feature using strict TDD. Read SKILL.md at .ai/skills/app-cp-package/SKILL.md. Package: <package_name>. Used for: <what the feature needs it for, e.g. 'displaying charts in the screen', 'picking images from gallery', 'generating PDF reports'>. TDD STEPS — execute in this exact order:

STEP 1 — pub add:
  Run 'dart pub add <package_name>' directory. Confirm it appears in pubspec.yaml.

STEP 2 — Write wrapper test FIRST (RED):
  Create test/core/services/<domain>/<package_name>_wrapper_test.dart.
  Test only the wrapper's public API surface (the methods PackageNameWrapper exposes).
  For UI-only packages: test that the factory method returns a Widget given valid input.
  For service packages: test that the method returns the expected type given a mock input.
  Do NOT test business logic — the wrapper is a thin facade.
  Run 'flutter test test/core/services/<domain>/<package_name>_wrapper_test.dart'.
  EXPECTED: compile error or test failure (wrapper does not exist yet) — this is RED. Confirm RED before proceeding.

STEP 3 — Write the wrapper (GREEN):
  Create lib/core/services/<domain>/<package_name>_wrapper.dart (standalone file).
  Pattern reference: see `.ai/skills/app-agent-cp-package/SKILL.md`.
  Rules:
    - Thin facade only — expose the package's public API with NO business logic.
    - NEVER invent types. Only use types from the package's exported API.
    - NEVER add feature-specific logic to the wrapper (no data building, color mapping, etc.).
    - For UI-only packages (widget factories): expose methods accepting simple types and returning Widget.
    - For service packages (async operations): expose methods that delegate directly to the package.

STEP 4 — GREEN verification:
  Run 'flutter test test/core/services/<domain>/<package_name>_wrapper_test.dart'.
  MUST PASS GREEN.
  Run 'flutter analyze lib/core/services/'.
  MUST return 0 issues. Fix any issues before returning.

STEP 5 — Apply SOLID interface pattern to the wrapper:
  Read .ai/skills/app-class-to-solid-min/SKILL.md and follow it exactly for <package_name>_wrapper.dart.
  Concretely:
    a) In <package_name>_wrapper.dart, add 'abstract interface class I<PkgName>Wrapper' above 'class <PkgName>Wrapper'.
       The interface declares ONLY the public methods the wrapper exposes — no bodies.
       <PkgName>Wrapper adds 'implements I<PkgName>Wrapper' and '@override' on every method.
    c) Run 'flutter analyze lib/core/services/'. MUST return 0 issues.
       Fix any issues before returning.
  Do NOT create a Riverpod provider for pure utility/UI packages — they are pure utility wrappers accessed via CustomFunction.<camelName>. Only injectable services (dio, token) get a provider (see MD/APP_PACKAGE_WRAPPER.md access categories).

Return: (a) test file path, (b) wrapper file path, (c) test output GREEN, (d) analyze output 0 issues, (e) the exact method signatures exposed by the wrapper (for D.0.1–D.0.5b to use in mocks).")
```

Wait for the task to return before launching the next package's task. Each wrapper must be GREEN and analyze-clean before the next one starts.

#### D.0.6 Step 4 — Update generated_api_contract.md with wrapper API surface (new + existing)

After ALL new wrappers are GREEN, launch one task to append a `## Wrapper API` section. This section MUST document BOTH new wrappers created in D.0.6 AND existing wrappers in `core/services/` that the feature uses (e.g. `IDioWrapper`, `ICredentialStore`):

```
task(subagent_type="general", prompt="Append a '## Wrapper API' section to lib/features/<feature_name>/spec/generated_api_contract.md. This section must include TWO groups:

GROUP 1 — New wrappers created in D.0.6: For each *_wrapper.dart just created, document: wrapper class name, interface name (I<Name>), provider accessor, and each public method signature with parameter and return types.

GROUP 2 — Existing wrappers used by this feature: Read lib/core/services/ and the spec files to identify which existing wrappers the feature needs (e.g. IDioWrapper for HTTP calls, ICredentialStore for auth, ISharePlusWrapper for sharing). For each, document the same fields (class, interface, accessor, method signatures).

This combined section will be used by ALL test writers (D.0.1–D.0.5b) to write correct mocks. Test writers must mock interfaces from this section — never raw package classes.

Example entry format (use for EVERY wrapper, whatever the package):
### <WrapperName> — accessed via ref.watch(<name>Provider)
- <methodName>(<params>) → <returnType>

Concrete examples:
### FlChartWrapper — accessed via ref.watch(flChartProvider)
- lineChart({required List<double> values, List<String>? labels, Color? lineColor, Color? fillColor}) → Widget
- pieChart({required Map<String, double> segments, List<Color>? colors}) → Widget
### DioWrapper (IDioWrapper) — accessed via ref.watch(httpServiceProvider)
- get(String path, {Map<String, String>? headers}) → Future<dynamic>
### ImagePickerWrapper — accessed via ref.watch(imagePickerProvider)
- pickImage(ImageSource source) → Future<XFile?>

Return: confirmation that ## Wrapper API section is present and lists both new and existing wrappers used by <feature_name>.")
```

#### D.0.6 Gate check — orchestrator verification

**Step 1 — grep (orchestrator bash, allowed):**
```bash
grep "## Wrapper API" lib/features/<name>/spec/generated_api_contract.md
```
If missing → re-run the wrapper API documentation task.

**Step 2 — Wrapper tests (delegate to sub-agent):**
```
task(subagent_type="general", prompt="Run wrapper tests to verify D.0.6 is complete for feature <feature_name>. Execute: run 'flutter test test/core/services/' and report the result. Return: PASS (0 failures) or FAIL with the list of failing tests.")
```
If FAIL → re-run the wrapper TDD task for the failing package.

**Step 3 — Analyze (delegate to sub-agent):**
```
task(subagent_type="general", prompt="Run flutter analyze to verify D.0.6 wrappers are clean for feature <feature_name>. Execute: run 'flutter analyze lib/core/services/ --fatal-infos' and report the result. Return: PASS (0 issues) or FAIL with issue list.")
```
If FAIL → launch fix-analyzer-issues sub-agent on `lib/core/services/`.

All 3 steps must pass. Do NOT proceed to D.0.1 until all pass.

> **⛔ HARD RULE: If D.0.6 fails after 2 repair attempts → STOP ALL WORK → report to user. A broken wrapper in core/services/ will corrupt ALL subsequent phases.**

---

### D.0.1 — Domain Test Writer (MANDATORY before D.1)

**Before launching D.0.1, verify generated_api_contract.md exists:**

```bash
grep "## Required Files" lib/features/<name>/spec/generated_api_contract.md
```

If missing → re-run D.0.5 first. Do NOT launch D.0.1 without a complete generated_api_contract.md.

**Before writing a single line of implementation code, ALL test files for the feature MUST exist.**

```
task(subagent_type="general", prompt="Run app-agent-domain-test-writer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-domain-test-writer/SKILL.md and follow it exactly. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md first — this is your primary source for entity fields and method signatures. Also read domain.md and tests.md. CRITICAL: No domain stubs exist yet — do NOT run tests (they will fail to compile). Write the domain test files to test/features/<feature_name>/domain/. Return: list of test files created with their full paths.")
```

Wait for completion before launching D.0.2.

### D.0.2 — Infrastructure Test Writer (MANDATORY before D.1)

```
task(subagent_type="general", prompt="Run app-agent-infrastructure-test-writer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-infrastructure-test-writer/SKILL.md and follow it exactly. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md first — your primary source for datasource and repository method signatures. Also read domain.md, contracts.md, and tests.md. CRITICAL: No infrastructure stubs exist yet — do NOT run tests (they will fail to compile). Write test files to test/features/<feature_name>/infrastructure/ (one for datasource, one for repository). Return: list of test files created with their full paths.")
```

Wait for completion before launching D.0.3.

### D.0.3 — Presentation Test Writer (MANDATORY before D.1)

```
task(subagent_type="general", prompt="Run app-agent-presentation-test-writer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-presentation-test-writer/SKILL.md and follow it exactly. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md first — your primary source for state variants, provider names, AND the '## Wrapper API' section that lists every wrapper interface the feature uses. Also read domain.md and tests.md. CRITICAL: No notifier, state, or screen files exist yet — do NOT run tests (they will fail to compile). WRAPPER RULE: For ANY external package used by the feature, mock its wrapper INTERFACE (I<Xxx>Wrapper from ## Wrapper API) — NEVER the raw package class directly. This rule applies to ALL packages without exception (charts, PDF, camera, maps, audio, share, HTTP, etc.). Write test files to test/features/<feature_name>/presentation/ (notifier tests, screen tests, widget tests as defined in tests.md). Return: list of test files created with their full paths.")
```

Wait for completion before launching D.0.4.

### D.0.4 — Integration Test Writer (MANDATORY before D.1)

```
task(subagent_type="general", prompt="Run app-agent-integration-test-writer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-integration-test-writer/SKILL.md and follow it exactly. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md first — your primary source for repository method signatures. Also read domain.md and bdd.feature. CRITICAL: No repository interface file exists yet — derive method signatures from domain.md and generated_api_contract.md. Write the integration test file to integration_test/<feature_name>_integration_test.dart. One testWidgets per BDD scenario. Return: the integration test file path.")
```

Wait for completion before launching D.0.5b.

### D.0.5b — BDD Test Writer (MANDATORY before D.1)

```
task(subagent_type="general", prompt="Run app-agent-bdd-writer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-bdd-writer/SKILL.md and follow it exactly. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md first — your primary source for state variant names. Also read domain.md and bdd.feature. CRITICAL: No notifier or state files exist yet — derive state variants from generated_api_contract.md and bdd.feature only. Write fake notifiers based on spec only. Write the BDD test file to test/bdd/<feature_name>_bdd_test.dart. MANDATORY: _testFunction MUST be a top-level named function (NOT an inline lambda). Return: the BDD test file path.")
```

**Gate check — ALL 5 MUST complete before D.1:**

### ⛔ HARD STOP — Bash Verification Before D.1 (mandatory, no exceptions)

Run these 5 commands. If ANY returns an error → re-run the missing test writer → repeat until all 5 pass. **Do NOT write a single line of implementation code until all 5 succeed:**

```bash
ls test/features/<name>/domain/
ls test/features/<name>/infrastructure/
ls test/features/<name>/presentation/
ls integration_test/<name>_integration_test.dart
ls test/bdd/<name>_bdd_test.dart
```

**All 5 `ls` commands must succeed. If any fails → STOP → do NOT proceed to D.1 under any circumstance.**

> This verification is NOT optional. An agent that skips it and writes D.1 code is violating the TDD-First contract. The supervisor will flag this as VIOLATION and the phase must restart.

### D.1 — Domain Entities + build_runner

```
task(subagent_type="general", prompt="Run spec-dev Phase D.1 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.1 only. Also read MD/APP_DARTZ.md and MD/APP_IMPORTANT_INFO.md. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md for entity fields. Actions: (1) Write ONE .dart file per entity listed in generated_api_contract.md (there may be multiple — e.g. <feature_name>_entity.dart AND <feature_name>_detail_entity.dart). Each entity uses @freezed abstract class + const Entity._() constructor + @JsonSerializable. NEVER create _entities.lib.dart barrel — import entity files directly. (2) Run 'dart run build_runner build --delete-conflicting-outputs'. (3) Verify .freezed.dart and .g.dart were generated for EACH entity file. Return: list of ALL entity files written, build_runner exit code, confirmation that .freezed.dart and .g.dart exist for each.")
```

**Supervisor check after D.1:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.1 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) lib/features/<feature_name>/domain/entities/<feature_name>_entity.dart exists with @freezed abstract class and const Entity._() constructor. (2) .freezed.dart and .g.dart exist. (3) No _entities.lib.dart barrel was created. Return: PASS or VIOLATION with details.")
```

If VIOLATION → re-run D.1 task. Do NOT proceed to D.2 until supervisor returns PASS.

### D.2 — Domain Stubs → RED

```
task(subagent_type="general", prompt="Run spec-dev Phase D.2 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.2 only. Also read MD/APP_DARTZ.md. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md for method signatures. Actions: (1) Write i_<feature_name>_datasource.dart abstract class with all methods from generated_api_contract.md — throw UnimplementedError(). (2) Write i_<feature_name>_repository.dart abstract class — throw UnimplementedError(). (3) Write <feature_name>_usecase.dart — throw UnimplementedError(). (4) Run 'flutter test test/features/<feature_name>/domain/' — tests MUST FAIL RED (UnimplementedError). Return: files written + test output showing RED failures.")
```

**Supervisor check after D.2:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.2 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) Domain stub files exist (interface + usecase). (2) Test output shows RED failures (UnimplementedError). If tests PASS → VIOLATION (stubs must throw). Return: PASS or VIOLATION with details.")
```

### D.3 — Domain Implementation → GREEN

```
task(subagent_type="general", prompt="Run spec-dev Phase D.3 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.3 only. Also read MD/APP_DARTZ.md and MD/APP_EXCEPTION.md. Spec folder: lib/features/<feature_name>/spec/. Actions: (1) Implement <feature_name>_usecase.dart — replace UnimplementedError with real logic using Result<T> (guard from shared/error/result_guard.dart). (2) Run 'flutter test test/features/<feature_name>/domain/' — tests MUST ALL PASS GREEN. Return: implemented file + test output showing GREEN.")
```

**Supervisor check after D.3:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.3 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) Usecase has no UnimplementedError. (2) Domain tests all pass GREEN. Return: PASS or VIOLATION.")
```

### D.4 — Infrastructure Stubs → RED

```
task(subagent_type="general", prompt="Run spec-dev Phase D.4 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.4 only. Also read MD/APP_PACKAGE_WRAPPER.md, MD/APP_PROVIDERS.md. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md for method signatures. Actions: (1) Write <feature_name>_datasource_impl.dart stub — 10+ lines, UnimplementedError for all methods. (2) Write <feature_name>_mapper.dart stub. (3) Write <feature_name>_repository_impl.dart stub — UnimplementedError. HARDCODE RULE: infrastructure/ folder ALWAYS created even if spec says 'reuse existing'. (4) Run 'flutter test test/features/<feature_name>/infrastructure/' — tests MUST FAIL RED. Return: files written + test output showing RED.")
```

**Supervisor check after D.4:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.4 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: infrastructure/ is non-empty, infra test output shows RED failures. Return: PASS or VIOLATION.")
```

### D.5 — Infrastructure Implementation → GREEN

```
task(subagent_type="general", prompt="Run spec-dev Phase D.5 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.5 only. Also read MD/APP_DARTZ.md, MD/APP_PACKAGE_WRAPPER.md, MD/APP_PROVIDERS.md, MD/APP_EXCEPTION.md. Spec folder: lib/features/<feature_name>/spec/. Also read lib/features/[feature_name]/infrastructure/ as a reference implementation. Actions: (1) Implement DatasourceImpl: pure HTTP (no mock conditional inside datasource). Create FakeDatasource at infrastructure/datasources/fake_*_datasource.dart if mock data is needed. The provider returns DatasourceImpl directly (useMock removed): @riverpod IDatasource datasource(Ref ref) => DatasourceImpl(dio: ref.watch(httpServiceProvider)). For testing, override the datasourceProvider with FakeDatasource. (2) Implement Mapper: uses Dto.fromJson + Mapper.fromDto() with named constructors (VGV-standard — NEVER Entity.fromJson). (3) Implement RepositoryImpl: uses guard() from shared/error/result_guard.dart — NEVER raw try/catch. CRITICAL: httpServiceProvider NEVER used as CustomFunction.dio directly — always via ref.watch(httpServiceProvider). (4) Run 'flutter test test/features/<feature_name>/infrastructure/' — MUST ALL PASS GREEN. Return: implemented files + test output showing GREEN.")
```

**Supervisor check after D.5:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.5 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) No raw try/catch in repository. (2) Injectable services use ref.watch(providerName) — never direct CustomFunction or static locator. (3) Infra tests GREEN. Return: PASS or VIOLATION.")
```

### D.6 — State + Notifier + Providers + codegen

```
task(subagent_type="general", prompt="Run spec-dev Phase D.6 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.6 only. Also read MD/APP_STATE_MANAGMENT.md, MD/APP_PROVIDERS.md, MD/APP_DARTZ.md. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md for state variants and provider names. Also read lib/features/[feature_name]/presentation/ as reference. Actions: (1) Write <feature_name>_state.dart as @freezed sealed class — NO ._() constructor — with variants from generated_api_contract.md. (2) Write <feature_name>_notifier.dart with @riverpod — stub load() with throw UnimplementedError(). (3) Write DI chain providers: datasource → repository → usecase. (4) Run 'dart run build_runner build --delete-conflicting-outputs'. (5) Verify .freezed.dart for state and .g.dart for notifier/providers. Return: files written + codegen confirmation.")
```

**Supervisor check after D.6:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.6 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) State is sealed class with NO ._() constructor. (2) @riverpod annotation on notifier. (3) .freezed.dart and .g.dart codegen artifacts exist. Return: PASS or VIOLATION.")
```

### D.7 — Presentation Tests → RED

```
task(subagent_type="general", prompt="Run spec-dev Phase D.7 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.7 only. Actions: Run 'flutter test test/features/<feature_name>/presentation/'. Tests MUST FAIL RED — the notifier is still a stub with UnimplementedError. Return: test output confirming RED failures. If tests PASS → report as VIOLATION (notifier must be a stub at this point).")
```

**Supervisor check after D.7:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.7 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: presentation test output shows RED failures. If tests pass → VIOLATION. Return: PASS or VIOLATION.")
```

### D.8 — Presentation Implementation → GREEN

```
task(subagent_type="general", prompt="Run spec-dev Phase D.8 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.8 only. Also read MD/APP_STATE_MANAGMENT.md, MD/APP_PROVIDERS.md, MD/APP_EXCEPTION.md, MD/APP_PACKAGE_WRAPPER.md. Spec folder: lib/features/<feature_name>/spec/. Read generated_api_contract.md — specifically the '## Wrapper API' section which lists all wrappers created at D.0.6 and their method signatures. Also read lib/features/[feature_name]/presentation/ as reference. WRAPPER RULE: All pub packages must be used via ref.watch(<wrapper>Provider) or via the wrapper's own provider — NEVER import the raw package directly in feature files. For goRouter, use ref.read(goRouterProvider).go(...). Actions: (1) Implement notifier load(): state=Loading → call usecase → on Right: state=Loaded(data) → on Left: state = Failure(error) (pass AppError to state). (2) Implement screen as ConsumerStatefulWidget: ref.watch for state, ref.listen for failure → localizeError(error, AppLocalizations.of(context)!) to get message → show snackbar + ref.read(notifier.notifier).reset(). (3) Implement feature widgets using wrapper providers (e.g. ref.watch(flChartProvider) or a chart notifier). (4) Run 'dart run build_runner build --delete-conflicting-outputs'. (5) Run 'flutter test test/features/<feature_name>/presentation/' — MUST ALL PASS GREEN. CRITICAL RULES: localizeError() at UI layer, NEVER failure.message directly. ref.listen + snackbar + reset() are MANDATORY. Feature-specific logic (ChartDataBuilder, color mapping, etc.) stays in the widget/notifier — NEVER in a wrapper. Return: files written + test output showing GREEN.")
```

**Supervisor check after D.8:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.8 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) Notifier passes AppError to state via Failure(error) (not failure.message). (2) ref.listen for failure state present with localizeError(). (3) reset() called after failure. (4) No direct package imports in presentation files — all packages accessed via ref.watch(<wrapper>Provider) or their own provider. (5) Presentation tests GREEN. Return: PASS or VIOLATION with details.")
```

### D.9 — Integration Test → RED

```
task(subagent_type="general", prompt="Run spec-dev Phase D.9 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.9 only. Actions: Run 'flutter analyze integration_test/<feature_name>_integration_test.dart'. This will likely fail because navigation is not wired yet — that is EXPECTED and CORRECT. Return: analyze output. Confirm test file exists and only overrides repositories (no business logic). This RED state is intentional — the route will be wired in D.10.")
```

**Supervisor check after D.9:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.9 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: integration test file exists at integration_test/<feature_name>_integration_test.dart and contains only repository overrides (no business logic inline). Return: PASS or VIOLATION.")
```

### D.9.5 — BDD Tests → GREEN

```
task(subagent_type="general", prompt="Run spec-dev Phase D.9.5 for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md and execute Phase D.9.5 only. Actions: Run 'flutter test test/bdd/<feature_name>_bdd_test.dart'. BDD tests use fake notifiers and MUST PASS GREEN. If tests fail → repair step definitions in the existing BDD test file (do NOT rewrite from scratch). CRITICAL: _testFunction MUST be a top-level named function, NOT an inline lambda. Return: test output showing GREEN (or list of step definition fixes applied).")
```

**Supervisor check after D.9.5:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.9.5 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) _testFunction is a top-level named function. (2) BDD tests pass GREEN. Return: PASS or VIOLATION.")
```

**After D.9.5 passes — integration analyze check:**
```
task(subagent_type="general", prompt="After BDD fixes in Phase D.9.5, run flutter analyze on integration test for feature <feature_name>. Execute: flutter analyze integration_test/<feature_name>_integration_test.dart. Return: PASS (0 issues) or FAIL with issue list. Ensures BDD fixes did not break integration test compile.")
```

### D.10 — Barrels + Navigation → GREEN

> ⛔ D.10 is TWO separate task() calls in sequence. Barrel files first, navigation second. Do NOT merge them into one task — they use different SKILL.md files and have different verification gates.

**D.10a — Barrel files:**

```
task(subagent_type="general", prompt="Run spec-dev Phase D.10 barrel step for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md (Phase D.10 section). Also read MD/APP_BARREL_PATTERN.md for barrel file conventions. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Actions: (1) Create presentation/widgets/_widgets.lib.dart (library declaration + part directives for all widget files). (2) Create presentation/widgets/_widgets.dart (CustomWidgets facade class). (3) Run 'dart run build_runner build --delete-conflicting-outputs'. (4) Run 'flutter analyze' — must return 0 issues. Return: list of barrel files created + analyze output showing 0 issues.")
```

Wait for D.10a to return PASS before launching D.10b.

**D.10b — Navigation wiring:**

```
task(subagent_type="general", prompt="Run app-agent-nav-wirer for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-nav-wirer/SKILL.md and execute fully. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Also read tasks.md to identify the parent screen and navigation trigger. Actions: (1) Add AppRoute entry to lib/app/router/app_route.dart. (2) Add GoRoute + screen import to lib/app/router/app_router.dart. (3) Add navigation trigger to parent screen if required by tasks.md. (4) Run 'flutter analyze' — MUST return 0 issues GREEN. Return: list of files modified + analyze output showing 0 issues.")

```
**Supervisor check after D.10a (barrels):**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.10a (barrel files) for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) _widgets.lib.dart exists in presentation/widgets/. (2) _widgets.dart exists in presentation/widgets/. (3) flutter analyze returns 0 issues. Return: PASS or VIOLATION with details.")
```

If VIOLATION → re-run D.10a task. Do NOT proceed to D.10b until supervisor returns PASS.

**Supervisor check after D.10b (navigation):**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.10b (navigation wiring) for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) URI added to uries.dart. (2) AppRoute enum entry added to app_route.dart. (3) GoRoute added to app_router.dart. (4) Screen import added to _configs.lib.dart. (5) flutter analyze returns 0 issues. Return: PASS or VIOLATION with details.")
```

If VIOLATION → re-run D.10b task. Do NOT proceed to D.10.5 until supervisor returns PASS.

### D.10.5 — Wrapper-Auditor + DirectImport-Auditor (post-navigation)

**Purpose:** Now that the full feature is implemented, audit all package usage. This is intentionally post-implementation — wrappers cannot be validated until actual imports are known.

**Step 1 — DirectImport-Auditor (grep):**

```bash
grep -rn "import 'package:" lib/features/<name>/ \
  | grep -v "package:flutter" \
  | grep -v "package:flutter_riverpod" \
  | grep -v "package:clean_architecture_sdd_harness" \
  | grep -v "package:freezed_annotation" \
  | grep -v "package:json_annotation" \
  | grep -v "package:riverpod_annotation" \
  | grep -v "package:go_router" \
  | grep -v "package:clean_architecture_sdd_harness/"
```

If any direct package import is found → create a wrapper for that package.

**Step 2 — Wrapper repair (on FAIL):**

```
task(subagent_type="general", prompt="Create <package>_wrapper.dart. Read SKILL.md at .ai/skills/app-cp-package/SKILL.md. Package: <name>. Feature: <feature_name>. MANDATORY: thin facade only — no business logic, no widget-building, no invented types. Return ONLY when flutter analyze lib/core/services/ outputs 0 issues.")
```

**Step 3 — Re-run DirectImport-Auditor** after each repair. Repeat until 0 direct package imports remain.

**Supervisor check:** grep returns 0 direct package imports. All packages used via `ref.watch(<x>Provider)`.

### D.10.6 — Integration Test Execution on Device (MANDATORY)

**Purpose:** Execute the integration test on a real device BEFORE final verification. This catches runtime errors that `flutter analyze` cannot detect (wrong widget types, missing finders, animation mismatches, navigation timing). **No deferral is allowed** — if no device is available, the orchestrator must report BLOCKED to the user.

**Why this is separate from D.9 (analyze-only):** D.9 intentionally runs before nav wiring to confirm the test file is structurally sound. D.10.6 runs AFTER navigation is wired (D.10) and direct imports resolved (D.10.5), so the test can execute end-to-end.

> **HARD RULE:** An integration test that passes `flutter analyze` is NOT verified. Only execution on a device proves the test works. Widget-finder type mismatches (`DropdownButton` vs `DropdownButton<String>`), missing keys, and animation issues are ONLY detectable at runtime.

**Step 1 — Device discovery:**
```
task(subagent_type="general", prompt="Discover available Flutter devices for running integration test on feature <feature_name>. Run 'flutter devices --machine' and parse the JSON output. Return: list of available device IDs + platforms, or 'NONE' if no devices found. Prefer: macOS > Android emulator > iOS simulator > physical device.")
```

**Step 2 — Execute integration test:**
```
task(subagent_type="general", prompt="Run integration test for feature <feature_name> on device <device_id>.
(1) Read the integration test at integration_test/<feature_name>_integration_test.dart.
(2) Run 'flutter test integration_test/<feature_name>_integration_test.dart -d <device_id>'.
(3) ALL tests MUST pass GREEN. If any test fails:
    a. Read the full failure output.
    b. Read spec files at lib/features/<feature_name>/spec/ for expected behavior.
    c. Read the integration test file, identify root cause (widget finder mismatch, wrong type, missing key, etc.).
    d. Fix the test file — do NOT modify production code to make the test pass.
    e. Re-run on device. Repeat until ALL GREEN.
(4) Return: device_id, original result, fixes applied, final result (must be ALL GREEN).")
```

**Step 3 — If NO device is available (BLOCKED):**
```
→ HARD STOP → report to user: 'No Flutter device available. Start a device and re-run D.10.6.'
→ Do NOT proceed to D.11 until a device is available.
```

**Step 4 — Orchestrator post-check:**
```bash
# Verify sub-agent returned ALL GREEN before allowing D.11
```

**Step 5 — Engram save:**
```
mem_save(
  title: "Integration test executed: <feature_name> — PASS",
  type: "verification",
  content: "What: Integration test executed on device <device_id>. ALL GREEN. Why: Runtime verification catches widget-finder mismatches, animation issues, navigation timing that analyze cannot detect. Where: integration_test/<feature_name>_integration_test.dart. Learned: <any fixes applied>"
)

### D.11 — Final Verification

> ⛔ D.11 is delegated via task() — the orchestrator does NOT run flutter test inline.

```
task(subagent_type="general", prompt="Run spec-dev Phase D.11 Final Verification for feature <feature_name>. Read SKILL.md at .ai/skills/app-spec-dev/SKILL.md (Phase D.11 section). Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Actions — execute in this exact order:

(1) Run 'flutter analyze' → must return 0 issues.
(2) Run 'flutter test test/features/<feature_name>/' → must return 0 failures.
(3) Run 'flutter test test/bdd/<feature_name>_bdd_test.dart' → must return 0 failures.
(4) Integration test: if D.10.6 was already executed (check for Engram entry 'Integration test executed: <feature_name> — PASS'), skip execution and report the D.10.6 result. Otherwise run: 'flutter test integration_test/<feature_name>_integration_test.dart -d macos'. If device unavailable → FAIL → do NOT proceed. **Integration test execution is MANDATORY — no deferral allowed.** If D.10.6 failed or was skipped, this step must fail.
(5) Cross-feature import check: run grep -rn \"import 'package:clean_architecture_sdd_harness/features/\" lib/features/<feature_name>/ | grep -v 'package:clean_architecture_sdd_harness/features/<feature_name>/'. If any match found → CRITICAL VIOLATION — report and stop.
(6) Required Files check: read ## Required Files section from lib/features/<feature_name>/spec/generated_api_contract.md and verify each listed file exists via ls. Report any missing file as BLOCKED.

Return: structured report with (a) analyze result, (b) unit+widget test result, (c) BDD test result, (d) integration test result or deferral reason, (e) cross-feature import result, (f) required files check result. Overall verdict: PASS, FAIL, or BLOCKED.")
```

**Supervisor check after D.11:**
```
task(subagent_type="general", prompt="Verify spec-dev Phase D.11 for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-spec-dev-supervisor/SKILL.md. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Check: (1) flutter analyze = 0 issues. (2) unit + widget tests GREEN. (3) BDD tests GREEN. (4) Integration test executed on device with ALL tests GREEN (D.10.6 PASS) — deferral is NOT accepted. (5) No cross-feature imports. (6) All Required Files from generated_api_contract.md exist. Return: PASS or VIOLATION with details.")
```

If VIOLATION → launch repair agent (`fix-analyzer-issues` or `fix-tests`) → re-run D.11 verification task → repeat until PASS.

### D.11 Engram save

```
mem_save(
  title: "Feature implemented: <feature_name>",
  type: "decision",
  content: "What: Full TDD implementation of <feature> completed. Why: User story. Where: lib/features/<name>/, test/features/<name>/, integration_test/. Learned: <violations caught, patterns established>"
)
```

---

## Phase E — Formal Verification

```
# sdd-verify-adapted skill (at ~/.config/opencode/skills/sdd-verify-adapted/SKILL.md) does not exist — skip formal verification or run manually
```

---

## Phase F — Documentation Sync

```
task(subagent_type="general", prompt="Run app-agent-update-md for feature <feature_name>. Read SKILL.md at .ai/skills/app-agent-update-md/SKILL.md. IMPORTANT: The skill requires loading .ai/skills/app-changes/SKILL.md as its Phase 1 — follow that instruction exactly before gathering changes. Feature name: <feature_name>. Spec folder: lib/features/<feature_name>/spec/. Changes made this session: <summary of what was implemented>. Update MD/* and AGENTS.md as needed. Return: list of files updated.")
```

---

## Phase G — Engram Session Summary (MANDATORY)

```
mem_session_summary({
  goal: "Implemented <feature_name> using Spec-Local v3 workflow",
  instructions: "<user preferences discovered>",
  discoveries: [
    "...",
  ],
  accomplished: [
    "✅ Spec created (6 artifacts)",
    "✅ Phase-Gate PASS",
    "✅ Domain layer TDD (RED → GREEN)",
    "✅ Infrastructure layer TDD (RED → GREEN)",
    "✅ Presentation layer TDD (RED → GREEN)",
    "✅ Integration test written and executed",
    "✅ BDD tests (N scenarios GREEN)",
    "✅ flutter analyze 0 issues",
    "✅ MD/* updated",
  ],
  next_steps: ["..."],
  relevant_files: [
    "lib/features/<name>/ — full feature implementation",
    "test/features/<name>/ — unit + widget tests",
    "integration_test/<name>_integration_test.dart — integration test",
    "lib/features/<name>/spec/ — specification artifacts",
  ]
})
```

---

## Critical Rules — Never Violate

| Rule | Correct | Wrong |
|------|---------|-------|
| Package import | `ref.watch(<name>Provider)` or wrapper's provider | direct `package:fl_chart/...` |
| Injectable services | `ref.watch(httpServiceProvider)` | direct `CustomFunction` / static locator |
| Repository error | `guard()` from `shared/error/result_guard.dart` | raw try/catch |
| Notifier error | `state = State.failure(error)` passes `AppError`; UI uses `localizeError()` | `failure.message` directly |
| GoRouter | `ref.read(goRouterProvider).go(...)` | direct `package:go_router/...` |
| Freezed entity | `@freezed abstract class` + `const Foo._()` | missing `._()` |
| Freezed state | `@freezed sealed class` (NO `._()`) | sealed state with `._()` |
| Entity barrel | import entities directly (no barrel for @freezed) | `library`+`part` barrel |
| BDD _testFunction | TOP-LEVEL named function | inline lambda |
| Snackbar pump | `pump()` → `pump(Duration(2s))` | `pumpAndSettle` |
| TDD order | stub → RED → implement → GREEN | code first, tests after |

---

## Completion Criteria (all MUST pass)

| # | Criterion | Verified by |
|---|-----------|-------------|
| 1 | 6 spec files in spec/ folder | Orchestrator glob |
| 2 | generated_api_contract.md exists with entity fields, method sigs, state variants, provider names | Supervisor D.0.5 |
| 3 | Phase-Gate PASS (spec completeness only) | app-agent-phase-gate |
| 4 | Domain stubs ran RED | app-agent-spec-dev-supervisor |
| 5 | Infrastructure stubs ran RED | app-agent-spec-dev-supervisor |
| 6 | Presentation stubs ran RED | app-agent-spec-dev-supervisor |
| 7 | Integration test written and analyze-only RED before nav wiring (D.9) | app-agent-spec-dev-supervisor |
| 8 | BDD tests pass (gherkart) | flutter test |
| 9 | D.10.5 DirectImport-Auditor returns 0 direct package imports | Orchestrator grep |
| 10 | <package>_wrapper.dart for every pub package used | Wrapper-Auditor D.10.5 |
| 11 | D.10.6 Integration test EXECUTED on device — ALL GREEN (no deferral) | bash `flutter test ... -d <device>` |
| 12 | flutter analyze = 0 issues | flutter analyze |
| 13 | flutter test = 0 failures | flutter test |
| 14 | MD/* updated | app-agent-update-md |
| 15 | Engram session summary saved | mem_session_summary |

**If ANY criterion is not verified → the feature is NOT complete.**

---

## Sub-Agents Registry

| Agent | Skill file | Phase | Returns |
|-------|-----------|-------|---------|
| app-agent-spec-definer | `.ai/skills/app-agent-spec-definer/SKILL.md` | B | 6 spec files |
| app-agent-phase-gate | `.ai/skills/app-agent-phase-gate/SKILL.md` | C | PASS / FAIL / BLOCKED (Spec-Auditor only — Wrapper audit is D.10.5) |
| **app-agent-api-extractor** | **`.ai/skills/app-agent-api-extractor/SKILL.md`** | **D.0.5** | **generated_api_contract.md with 6 sections** |
| app-agent-domain-test-writer | `.ai/skills/app-agent-domain-test-writer/SKILL.md` | D.0.1 (All Tests First) | Domain test stubs |
| app-agent-infrastructure-test-writer | `.ai/skills/app-agent-infrastructure-test-writer/SKILL.md` | D.0.2 (All Tests First) | Infrastructure test stubs |
| app-agent-presentation-test-writer | `.ai/skills/app-agent-presentation-test-writer/SKILL.md` | D.0.3 (All Tests First) | Presentation test stubs |
| app-agent-integration-test-writer | `.ai/skills/app-agent-integration-test-writer/SKILL.md` | D.0.4 (All Tests First) | Integration test file |
| app-agent-bdd-writer | `.ai/skills/app-agent-bdd-writer/SKILL.md` | D.0.5b (All Tests First) | BDD test GREEN |
| app-agent-nav-wirer | `.ai/skills/app-agent-nav-wirer/SKILL.md` | D.10b | Wired routes |
| app-agent-spec-dev-supervisor | `.ai/skills/app-agent-spec-dev-supervisor/SKILL.md` | After each D sub-phase | Phase report PASS/VIOLATION |
| app-agent-fix-analyzer-issues | `.ai/skills/app-agent-fix-analyzer-issues/SKILL.md` | On analyze failure | Fixed files |
| app-agent-fix-tests | `.ai/skills/app-agent-fix-tests/SKILL.md` | On test failure | Fixed tests |
| app-agent-update-md | `.ai/skills/app-agent-update-md/SKILL.md` | F | Updated MD files |
| *(inline grep)* | D.10.5 DirectImport-Auditor | D.10.5 | 0 direct package imports |
| app-agent-cp-package | `.ai/skills/app-agent-cp-package/SKILL.md` | D.0.6 + D.10.5 repair | <pkg>_wrapper.dart + analyze clean |
| *(task delegate)* | Integration test execution on device | D.10.6 | ALL GREEN or BLOCKED |


---

## Anti-Pattern: Code-first, tests-after

This is what `clinical_history` did. Tests were written after all production code existed — they validated behavior, not drove API design. No file was ever RED before being written.

The corrected pattern (vaccines, lab_results): every production file has at least one failing test BEFORE its implementation is written.

---

## Post-Feature Verification Checklist

```bash
# 1. No direct package imports in feature
grep -rn "import 'package:" lib/features/<name>/ \
  | grep -v "package:flutter" \
  | grep -v "package:flutter_riverpod" \
  | grep -v "package:clean_architecture_sdd_harness" \
  | grep -v "package:freezed_annotation" \
  | grep -v "package:json_annotation" \
  | grep -v "package:riverpod_annotation" \
  | grep -v "package:go_router" \
  | grep -v "package:clean_architecture_sdd_harness/"

# 2. Barrel files exist
ls lib/features/<name>/presentation/widgets/_widgets.lib.dart
ls lib/features/<name>/presentation/widgets/_widgets.dart

# 3. All test tiers present
ls test/features/<name>/
ls test/bdd/<name>_bdd_test.dart
ls integration_test/<name>_integration_test.dart

# 4. No unimplemented stubs in production code
grep -rn "throw UnimplementedError" lib/features/<name>/

# 5. Navigation wired
grep "<name>" lib/app/router/app_router.dart
grep "<name>" lib/app/router/app_route.dart

# 6. Analyze clean
# Run commands
flutter analyze

# 7. Tests green
# Run commands
flutter test test/features/<name>/
flutter test test/bdd/<name>_bdd_test.dart
```

**If any check fails → the feature is NOT complete.**
