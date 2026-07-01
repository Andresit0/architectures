# Super Pull-Request Orchestrator — Full Pipeline (v2 — Reparado)

## Purpose

Transforms a fully implemented feature into:
1. Atomic commit history with structured PRs
2. Machine-verified validation artifacts
3. GitHub Pull Requests with correct dependency chains

**This v2 incorporates lessons from the first execution**:
- Inter-PR dependency detection prevents compile errors across PR boundaries
- TDD-First ordering ensures tests ship with their production code
- Post-Execution validation loop catches and repairs failures automatically
- Engram error handling prevents memory issues from blocking the pipeline

---

## Orchestrator Hard Rules

### RULE 1 — Never execute work inline

The orchestrator writes NO code, runs NO git commands directly, and generates NO artifacts. All work is delegated via `task()`.

### RULE 2 — Phase gates are hard stops (with repair routing)

If validation returns FAIL with a repair agent → route to that agent, let it fix, then re-run validation. Only STOP permanently after max retries.

### RULE 3 — Every task() prompt must be self-contained

Each prompt must include:
1. Path to the SKILL.md to execute: `.ai/skills/<agent>/SKILL.md`
2. Feature name
3. Any context from previous steps (warnings, manifest path, repair history)
4. What to return

### RULE 4 — Engram errors are non-blocking

If Engram operations fail (memory conflicts, ambiguous projects, etc.), log the issue and continue. Never let memory persistence block the pipeline.

---

## Pipeline

### Phase 1 — Plan (Core Planner)

Delegate to `app-agent-core-planner`:

```
task(
  subagent_type: "general",
  prompt: "
    You are the Core Planner. Load and follow SKILL.md at:
    .ai/skills/app-agent-core-planner/SKILL.md

    Feature: <name>
    Working directory: <project_root>

    Steps:
    1. Run repository analysis (git status, diff, log)
    2. Run security scan
    3. Run barrel integrity scan (soft warnings)
    4. Run direct import audit (soft warnings)
    5. Classify files into layers
       CRITICAL: lib/shared/configs/ and lib/shared/jsons/ are 'shared:configs', NOT 'navigation'
    6. Detect capabilities
    7. Run TDD analysis (tests MUST ship with their production code in the same PR)
    8. Run INTER-PR DEPENDENCY ANALYSIS (Step 3.6) — detect forward cross-PR imports
    9. Build commit plan with TDD ordering
    10. Cluster into PRs with cohesion scoring
    11. Generate execution-manifest.yaml (state: planned)
    12. Generate future-pr-plan.md
    13. Return warnings summary

    Return: paths to execution-manifest.yaml, future-pr-plan.md, and warnings[].
  "
)
```

**Output**: `execution-manifest.yaml` + `future-pr-plan.md` + `warnings[]`

---

### Phase 2 — Validate (Validation Layer)

Delegate to `app-agent-validation-layer`:

```
task(
  subagent_type: "general",
  prompt: "
    You are the Validation Layer. Load and follow SKILL.md at:
    .ai/skills/app-agent-validation-layer/SKILL.md

    Feature: <name>
    Manifest: execution-manifest.yaml

    Run all 11 validation checks:
    1. Manifest structure
    2. Layer limits (max 2 per PR, max 4 commits, max 20 files)
    3. Capability purity (one capability per PR)
    4. Barrel integrity (hard — scan for cross-layer barrel imports too)
    5. Direct import audit (hard — check fpdart, go_router, dio)
    6. Generated files presence
    7. Test coverage + TDD rule (every production file → test in SAME PR)
    8. BDD feature file sync (bdd.feature must be in same PR as BDD test)
    9. Naming consistency between artifacts
    10. DAG integrity (no cycles, correct parent/merge_target)
    11. INTER-PR DEPENDENCY ANALYSIS (forward cross-PR imports)

    IMPORTANT: For Check 11, run the actual grep-based import analysis on
    the changed files to detect forward dependencies.

    IMPORTANT: For Check 7, verify that bdd.feature is in the SAME PR as
    the BDD test. Also verify that every spec file referenced by tests
    exists in the same branch.

    For every FAIL, include repair_agent field:
    - Restructuring → 'app-agent-core-planner'
    - Missing files → 'app-agent-execution-layer'
    - Test issues → 'app-agent-fix-tests'
    - Compile errors → 'app-agent-fix-execution-issues'

    Return validation-report.yaml with status: PASS or FAIL and repair routing.
  "
)
```

**Gate**: If `validation.status` is FAIL → do NOT proceed to Phase 3. Instead, read the repair routing from `violations[].repair_agent` and dispatch repair tasks (Phase 2.5).

#### Phase 2.5 — Repair Loop (NEW)

For each violation in validation-report.yaml:

```
task(
  subagent_type: "general",
  prompt: "
    You are the repair agent for <violation.repair_agent>.
    Fix this issue from validation-report.yaml:
    - Branch: <branch>
    - Detail: <violation.detail>
    - Manifest: execution-manifest.yaml

    Use the Clean Rebuild Strategy if restructuring branches:
    1. Delete the affected branch
    2. Recreate from parent
    3. Apply commits one by one

    Return: summary of what was fixed.
  "
)
```

After ALL repairs complete, re-run Phase 2 (Validation) on the updated manifest.

**Max repair iterations**: 3. After 3 failed attempts → STOP and escalate to human.

---

### Phase 3 — Execute (Execution Layer)

Only if Phase 2 returned PASS.

Delegate to `app-agent-execution-layer`:

```
task(
  subagent_type: "general",
  prompt: "
    You are the Execution Layer. Load and follow SKILL.md at:
    .ai/skills/app-agent-execution-layer/SKILL.md

    Manifest: execution-manifest.yaml (state: planned)

    CRITICAL — Run these safety checks during execution:
    1. PRE-COMMIT IMPORT VALIDATION: Before each commit, verify every import
       in the staged files resolves to an existing file.
    2. TDD-FIRST ORDERING: If a commit has both tests and production code,
       commit tests FIRST, then production code.
    3. CLEAN REBUILD STRATEGY: If a branch fails, recreate from parent
       instead of rebasing.

    Steps:
    1. Verify input (state: planned, base branch exists)
    2. Display commit plan → wait for user confirmation
    3. Derive execution order via topological sort
    4. Generate dynamic validation commands per branch
    5. Execute commits per PR in topological order (with pre-commit validation)
    6. Validate each branch (flutter pub get → build_runner → analyze → test)
    7. If validation fails → use Clean Rebuild Strategy (Step 6b)
    8. Collect execution metadata
    9. Finalize artifacts (manifest → executed, pr-intent.yaml)

    Return: execution summary (commits executed, branches created, any failures).
  "
)
```

**Output**: `execution-manifest.yaml` (state: `executed`) + `pr-intent.yaml`

---

### Phase 4 — Post-Execution Validation (NEW — repair loop)

Delegate to `app-agent-post-execution-validator`:

```
task(
  subagent_type: "general",
  prompt: "
    You are the Post-Execution Validator. Load and follow SKILL.md at:
    .ai/skills/app-agent-post-execution-validator/SKILL.md

    Manifest: execution-manifest.yaml (state: executed)

    Steps:
    1. Collect all branches from manifest
    2. Validate EVERY branch (flutter analyze + flutter test)
    3. Classify any failures
    4. Route failures to repair agents:
       - Forward dependencies → app-agent-core-planner
       - Missing files → app-agent-execution-layer
       - Test failures → app-agent-fix-tests
       - Compile errors → app-agent-fix-execution-issues
    5. Re-validate downstream branches after repair
    6. Loop until ALL branches pass or max retries exceeded (3)
    7. Handle Engram errors gracefully (log and continue)
    8. Finalize manifest state → validated

    Return: final validation table, repair count.
  "
)
```

**Gate**: If after max retries any branch still fails → STOP. Present failure to user.

**Output**: `execution-manifest.yaml` (state: `validated`) + `repair-manifest.yaml`

---

### Phase 5 — Publish (VCS Adapter)

Only if all prior phases passed.

Delegate to `app-agent-vcs-adapter`:

```
task(
  subagent_type: "general",
  prompt: "
    You are the VCS Adapter. Load and follow SKILL.md at:
    .ai/skills/app-agent-vcs-adapter/SKILL.md

    Read pr-intent.yaml.

    Steps:
    1. Verify gh CLI installed and authenticated
    2. Push all branches to origin
    3. Create PRs in dependency order (independents first, then draft dependents)
    4. Record results in execution-manifest.yaml
    5. Update manifest state → published

    Return: list of PR URLs and their status.
  "
)
```

**Output**: `execution-manifest.yaml` (state: `published`) + GitHub PRs

---

## Engram Error Handling

Engram is used for persistent memory across sessions. These errors may occur and must be handled gracefully:

| Error | Detection | Handling |
|---|---|---|
| `judgment_required: true` | Check `mem_save` response envelope | Call `mem_judge` per candidate. If confidence < 0.7, ask user. Otherwise resolve autonomously with `related` or `compatible`. |
| `ambiguous_project` | Engram returns ambiguous_project error | Call `mem_current_project` to detect project from cwd. Use `project_choice_reason: user_selected_after_ambiguous_project` + `recovery_token`. |
| `mem_search` returns empty | No prior context | Proceed normally — no memory context available for this feature. |
| `mem_save` returns error | Save failure | Log the error to console. Do NOT block the pipeline. Continue with local state. |
| `mem_session_summary` fails | Session end failure | Try once more. If still failing, log and proceed. The session context is preserved in the code artifacts. |

**General rule**: Engram is advisory, not critical. The pipeline MUST continue even if memory persistence fails.

---

## Final Summary

After Phase 5 completes, display:

```
╔══════════════════════════════════════════════════════════════╗
║  Super Pull-Request — Complete                              ║
║  Commits: <N>                                               ║
║  PRs:     <M>                                               ║
║  Branches: <B>                                              ║
║  Repairs: <R> (from post-execution validation)              ║
║  Warnings: <W> (from planner)                               ║
╚══════════════════════════════════════════════════════════════╝

PR URLs:
  PR001  https://github.com/.../pull/42  Auth dependencies
  ...

State: published
```

---

## Completion Criteria

1. ✅ spec folder has 6 files (from spec-dev flow)
2. ✅ Core Planner generated execution-manifest.yaml + future-pr-plan.md
3. ✅ Validation Layer passed (11 checks) or repaired via loop
4. ✅ Execution Layer created all branches with TDD ordering
5. ✅ Post-Execution Validator confirmed 0 errors on all branches
6. ✅ No forward cross-PR dependencies (Check 11)
7. ✅ Every production file has its test in the same PR (TDD rule)
8. ✅ BDD feature file exists in same PR as BDD test
9. ✅ No stale intermediate commits (clean rebuild strategy)
10. ✅ Engram errors handled without blocking
11. ✅ VCS Adapter pushed branches and created PRs (if Phase 5 ran)
