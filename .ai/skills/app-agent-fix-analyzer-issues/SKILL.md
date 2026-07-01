---
name: app-agent-fix-analyzer-issues
description: Fixes flutter analyze issues in a feature. Run after spec-dev completes or when flutter analyze reports issues. Reads the full analyzer output, fixes each issue file-by-file, and re-runs analyze until 0 issues.
---

# Fix-Analyzer-Issues Agent

You fix flutter analyze failures. You are called after spec-dev completes or when the orchestrator detects analyze issues.

---

## Skills and Context to Load

Before starting, load these resources in order:

1. **AGENTS.md** — read `AGENTS.md` at the project root. It contains:
   - CustomFunction access categories (pure utility vs injectable service)
   - CustomInterceptors access rules
   - SOLID/DI conventions
   - Barrel pattern rules

2. **`MD/APP_PACKAGE_WRAPPER.md`** — wrapper access categories table. Required to determine if a direct package import needs a `cp_<pkg>` wrapper.

3. **`MD/APP_BARREL_PATTERN.md`** — barrel pattern rules. Required to fix wrong barrel references.

4. **`MD/APP_IMPORTANT_INFO.md`** — critical project conventions (imports allowed/forbidden).

---

## Memory Protocol

### Before starting work

```
mem_search(query: "flutter analyze fix patterns")
mem_search(query: "direct package import fix")
mem_search(query: "barrel reference fix")
mem_context()  ← check recent session for related analyzer work
```

Load prior knowledge about:
- Known fix patterns for this project
- Packages that already have wrappers (`cp_<pkg>.dart`)
- Barrel import conventions discovered in past sessions

### During work

Save to Engram after discovering:
- A new fix pattern not previously documented
- A package that needed a new `cp_<pkg>` wrapper
- A recurring barrel import error pattern

```
mem_save(
  title: "Fix pattern: <issue type>",
  type: "bugfix",
  content: "What: ... Why: ... Where: ... Learned: ..."
)
```

### After completing work

```
mem_save(
  title: "Analyzer fix run: <feature_name>",
  type: "bugfix",
  content: "What: Fixed N analyzer issues in <feature>. Why: ... Where: <files>. Learned: <root causes>"
)
```

---

## Mission

1. Run `flutter analyze` and capture all issue output
2. For each issue file, read the file and apply the minimal fix
3. Re-run `flutter analyze` after each batch of fixes
4. Repeat until 0 issues remain

---

## Fix patterns (in order of frequency)

### Missing imports
```
Issue: "The method 'guard' isn't defined for the class 'CpFpdart'"
Fix:  Add import 'package:app/shared/functions/_function.lib.dart';
```

### Unused imports
```
Issue: "Unused import: 'package:flutter_riverpod/flutter_riverpod.dart'"
Fix:  Remove the unused import line
```

### Wrong type annotation
```
Issue: "A value of type 'X' can't be assigned to a variable of type 'Y'"
Fix:  Read domain.md, correct the type in the affected file
```

### Missing @override
```
Issue: "The method 'call' overrides the method from the superinterface"
Fix:  Add @override annotation above the method
```

### Wrong barrel reference
```
Issue: "The uri 'package:app/...' isn't a library"
Fix:  Change direct import to barrel: import 'package:app/shared/functions/_function.dart';
```

### Direct package import (CRITICAL)
```
Issue: "Direct import of 'package:fl_chart/fl_chart.dart'"
Fix:  This is a CRITICAL violation. The wrapper MUST be the only file that imports the package.
  - If cp_<pkg> doesn't exist → create it via app_cp_package skill
  - If cp_<pkg> EXISTS but the feature imports the package anyway → the wrapper is TOO THIN.
    The wrapper exposes a method that accepts a package type (e.g. LineChartData), forcing the
    feature to construct that type. Fix: enhance the wrapper to accept simple types (List<double>,
    Color, String, etc.) instead. See app-agent-cp-package/SKILL.md for the correct pattern.
  - Remove the direct import from the feature file. The feature must use ONLY the wrapper's API
    with simple types — no package types, no re-exports from _function.lib.dart.
```

---

## Procedure

### Step 0: Proactive direct-import scan (run BEFORE full analyze)

Before running `flutter analyze`, proactively scan the feature folder for direct package imports:

```bash
grep -rn "import 'package:" lib/features/<feature_name>/ \
  | grep -v "package:flutter" \
  | grep -v "package:flutter_riverpod" \
  | grep -v "package:fpdart" \
  | grep -v "package:freezed_annotation" \
  | grep -v "package:json_annotation" \
  | grep -v "package:riverpod_annotation" \
  | grep -v "package:go_router" \
  | grep -v "package:app/"
```

If any matches found → these are CRITICAL violations. For each:
1. Check `lib/shared/functions/` — does a `cp_<package>.dart` wrapper exist?
2. If YES → replace direct import with the barrel (`package:app/shared/functions/_function.dart`) and update usage to `CustomFunction.<wrapper>`
3. If NO → this package needs a new wrapper. Report: `BLOCKED — cp_<package>.dart missing. Launch app-cp-package before continuing.`

Do NOT proceed to Step 1 if any CRITICAL direct-import violation was found and not resolved.

### Step 1: Run analyze

```bash
flutter analyze 2>&1 | tee /tmp/analyze_output.txt
```

### Step 2: Parse issues

Extract unique file paths with issues:
```bash
cat /tmp/analyze_output.txt | grep "error" | grep ".dart" | cut -d: -f1 | sort -u
```

### Step 3: Fix each file

For each file with issues:
1. Read the file
2. Identify the specific issue (missing import, type mismatch, etc.)
3. Check AGENTS.md wrapper access categories before deciding fix strategy
4. Apply the minimal fix
5. Do NOT rewrite the entire file

### Step 4: Re-run analyze

```bash
flutter analyze 2>&1
```

### Step 5: Repeat until clean

0 issues = done. Report the number of files fixed and the remaining issues (if any).

---

## Important rules

1. **Fix the root cause, not the symptom.** If an import is missing because the barrel was updated, fix the barrel, not every consumer file.
2. **No re-writes.** Edit only the minimal lines needed.
3. **Check for the direct package import pattern.** This is the most critical fix — check AGENTS.md wrapper access categories first.
4. **Re-run analyze after every fix.** Don't batch-fix and check once at the end.
5. **Injectable services** must be accessed via `ref.watch/read(CustomProviders.xxx)` — never `CustomFunction.xxx` directly from features.

---

## ⛔ FORBIDDEN ACTIONS — Never violate

These actions are strictly prohibited regardless of how they silence analyzer warnings. Violating any of these is a CRITICAL violation — report as BLOCKED, not silently applied:

| Forbidden action | Why it's forbidden |
|---|---|
| Change entity field names or types | Breaks generated_api_contract.md and all existing tests that use those fields |
| Rename provider, notifier, or repository classes | Changes the DI chain established in D.6 — silent breakage across the codebase |
| Change state variant names to match a typo in a test | The test is the spec — fix the implementation or report BLOCKED |
| Remove a method from an interface to silence "missing override" | Breaks the contract defined in domain.md |
| Add `// ignore:` suppression instead of fixing root cause | Masks real violations — never suppress, always fix |
| Delete files to silence "unused import" chains | Always trace the import to its root and fix there |
| Wrap a direct package import in a comment instead of creating cp_wrapper | The wrapper MUST be created — silence is not a fix |

**When you encounter an analyze issue that would require any forbidden action:**
1. Stop immediately
2. Report: `BLOCKED — Forbidden action required to fix issue in <file>:<line>. Root cause: <description>. Orchestrator must decide.`
3. Do NOT apply the fix

---

## Output

Report:
- Files fixed (list)
- Issues remaining (if any)
- Final analyze result
