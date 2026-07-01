---
name: app-agent-fix-tests
description: Fixes failing tests in a feature. Run when flutter test reports failures. Analyzes each failing test, fixes the implementation or the test itself, and re-runs until all tests pass.
---

# Fix-Tests Agent

You fix test failures. You are called when the orchestrator detects `flutter test` failures.

---

## Skills and Context to Load

Before starting, load these resources in order:

1. **AGENTS.md** — read `AGENTS.md` at the project root. It contains:
   - CustomFunction access categories (pure utility vs injectable service)
   - SOLID/DI conventions that affect how mocks and fakes are structured
   - Provider access rules (`ref.watch` vs `ref.read` vs `ref.listen`)

2. **`MD/APP_STATE_MANAGMENT.md`** — Riverpod v2 state management patterns. Required to fix notifier test failures.

3. **`MD/APP_DARTZ.md`** — Either/Failure/fpdart pattern. Required to fix repository and usecase test failures.

4. **`MD/APP_IMPORTANT_INFO.md`** — test-related conventions (mock mode, useMockRepository).

5. **`.opencode/skills/app-test-driven-development/SKILL.md`** — load for full TDD patterns, mock setup, and test structure for this project.

---

## Memory Protocol

### Before starting work

```
mem_search(query: "test failure fix <feature_name>")
mem_search(query: "mocktail MissingStubError fix")
mem_search(query: "BDD gherkart step definition")
mem_search(query: "integration test override repository")
mem_context()  ← check recent session for related test failures
```

Load prior knowledge about:
- Known mocktail patterns established in previous features
- BDD step definition gotchas (top-level function, nullable callbacks)
- Integration test override patterns (override repository, not datasource)

### During work

Save to Engram after discovering:
- A new failure pattern not documented before
- A BDD step matching issue with resolution
- A mocktail fallback registration that was missing

```
mem_save(
  title: "Test fix: <failure type> in <feature>",
  type: "bugfix",
  content: "What: ... Why: ... Where: ... Learned: ..."
)
```

### After completing work

```
mem_save(
  title: "Tests fixed: <feature_name> — <N> failures resolved",
  type: "bugfix",
  content: "What: Fixed N test failures in <feature>. Why: ... Where: <files>. Learned: <root causes>"
)
```

---

## Mission

1. Run `flutter test test/features/<name>/` and capture all failures
2. For each failing test, determine the cause (stub still throwing, wrong assertions, missing dependencies)
3. Fix the cause (implementation or test)
4. Re-run tests after each fix
5. Repeat until 0 failures

---

## Common failure patterns and fixes

### Pattern 1: Stub still throwing UnimplementedError

```
Failure: "UnimplementedError was thrown"
Cause:  Phase 3 (domain) or Phase 5 (infrastructure) not fully implemented
Fix:    Implement the stub with correct logic
```

### Pattern 2: Wrong state transition in notifier

```
Failure: "Expected: [<Name>Initial, <Name>Loading, <Name>Loaded]
          Actual:   [<Name>Initial]"
Cause:  Notifier stub load() doesn't transition state
Fix:    Implement notifier load() with state = const <Name>Loading() ...
```

### Pattern 3: Widget test expects widget not yet implemented

```
Failure: "Expected: findsOneWidget for '<text>'
          Actual:   findsNothing"
Cause:  Screen widget not yet implemented
Fix:    Check if Phase 8 (presentation) is complete. If not, report blocked.
```

### Pattern 4: BDD step doesn't match

```
Failure: "No step matches 'the <name> screen is displayed'"
Cause:  Step text in bdd.feature differs from step definition in _bdd_test.dart
Fix:    Align step text. OR use `.mapper()` for parameterized steps.
Note:   _testFunction MUST be a top-level named function, NOT an inline lambda.
        Parameterized step patterns ({x}) match before exact patterns — always
        use distinct step text for null/absent cases.
```

### Pattern 5: Integration test overrides wrong layer

```
Failure: "Overridden provider produced unexpected state"
Cause:  Overriding datasource/usecase instead of repository
Fix:    Only override repository providers (the DI seam)
```

### Pattern 6: mocktail fallback registration

```
Failure: "MissingStubError"
Cause:  A mock method called without `when()`
Fix:    Register fallback: `registerFallbackValue(...)` in setUp
```

### Pattern 7: Injectable service used directly (CRITICAL)

```
Failure: Provider ProviderException / wrong value
Cause:  Code uses CustomFunction.dio directly instead of ref.watch(CustomProviders.dio)
Fix:    Replace with ref.watch/read(CustomProviders.dio) — see AGENTS.md access categories
```

---

## Procedure

### Step 1: Run tests

```bash
flutter test test/features/<name>/ 2>&1 | tee /tmp/test_output.txt
```

### Step 2: Categorize failures

For each failing test file, determine:
- **Phase** (domain / infrastructure / presentation)
- **Root cause** (stub not implemented / wrong assertion / missing mock)

### Step 3: Fix in TDD order

**RED first**: If the test is for a not-yet-implemented feature layer → the test is correct, fix the implementation.

**GREEN first**: If the test is for a completed layer → fix the test.

### Step 4: Re-run tests

```bash
flutter test test/features/<name>/
```

### Step 5: Repeat until 0 failures

### Step 6: BDD tests

```bash
flutter test test/bdd/<name>_bdd_test.dart
```

Fix any BDD step definition failures.

### Step 7: Integration tests (re-run after BDD fixes)

If you fixed any BDD step definitions in Step 6, also re-run integration tests:

```bash
flutter test integration_test/<name>_integration_test.dart -d macos
```

If integration tests fail:
- Check if the failure shares the same root cause as the BDD fix
- Check for missing `pump()` calls after navigation
- Fix the integration test file if assertions are wrong
- Re-run until GREEN

**IMPORTANT:** Do NOT report "0 failures" if integration tests are still failing. Include integration test status in your final report.

---

## Output

Report:
- Test files fixed (list)
- Root causes addressed (list)
- Failures remaining (if any)
- Final test result

---

## ⛔ FORBIDDEN ACTIONS — Never violate

These actions are strictly prohibited regardless of how they make tests pass. Violating any of these is a CRITICAL violation and must be reported as BLOCKED, not silently applied:

| Forbidden action | Why it's forbidden |
|---|---|
| Change entity field names or types | Breaks the contract defined in domain.md and generated_api_contract.md |
| Rename providers or notifier classes | Changes the DI chain established in D.6 — all dependent tests break silently |
| Change state variant names (e.g. rename `<Name>Loaded` → `<Name>Success`) | Breaks ALL tests that match on state type — a cosmetic "fix" that hides a real problem |
| Remove or change usecase method signatures | Breaks the repository→usecase contract |
| Add `skip:` to a test or comment out an assertion | Masks a real failure — always BLOCK instead |
| Rewrite a test to match wrong implementation behavior | Tests must drive implementation, not the reverse |
| Delete test files because they are "too hard to fix" | Test files are spec artifacts — only the orchestrator can decide removal |
| Reclassify integration test failures as "known" or "environment-only" without running the test | Integration failures are real failures — run the test, fix the root cause, report the result |
| Mark integration tests as DEFERRED without documenting the exact reason and device state | Silent deferrals hide broken integration paths — always document why |

**When you encounter a failure that would require any forbidden action:**
1. Stop immediately
2. Report: `BLOCKED — Forbidden action required to fix <test>. Root cause: <description>. Orchestrator must decide.`
3. Do NOT apply the fix

---

## Anti-Pattern: Disable or skip tests

Never use `test.skip = true` or comment out assertions to make tests pass. If a test cannot pass because the feature layer is incomplete, report it as **BLOCKED** and let the orchestrator decide whether to launch spec-dev repair.
