---
name: app-agent-fix-execution-issues
description: Fixes execution-time issues such as compile errors, missing files, and stale intermediate commits. Invoked by the Post-Execution Validator when a branch fails validation. Supports the Clean Rebuild Strategy for branches with rebase artifacts.
---

# Fix Execution Issues Agent

You fix compile errors and structural issues discovered during or after branch execution. You are invoked by either:
- The Execution Layer (when a commit fails pre-commit validation or branch validation)
- The Post-Execution Validator (when a branch is found with errors)

---

## Context to Load Before Starting

1. **Execution manifest** — `execution-manifest.yaml` at project root
2. **Repair manifest** — `repair-manifest.yaml` (tracks retry count and repair history)
3. The failing branch's `flutter analyze` or `flutter test` output

---

## Failure Classification

### Type 1 — Forward Dependency (compile error)

**Symptom**: `flutter analyze` shows errors like:
```
error • The name 'Foo' isn't a class
error • Getter not defined: 'bar'
```

**Root cause**: A file in the current commit imports from a file that's defined in a later commit/PR.

**Fix**: 
1. Identify the missing symbol and its source file
2. Check which commit in the manifest introduces that file
3. Move the source file to an earlier PR (preferably the current one)
4. OR merge the two PRs into one

**Implementation**:
```bash
# Find which file defines the missing symbol
rg "class $MISSING_SYMBOL\|$MISSING_SYMBOL =" lib/ --include '*.dart'

# Find which commit introduces that file
grep -r "$SOURCE_FILE" execution-manifest.yaml

# Move the file to the current PR's commit list
```

### Type 2 — Missing Spec File

**Symptom**: BDD test fails with `No feature files found`.

**Root cause**: `lib/features/<name>/spec/bdd.feature` doesn't exist on the branch, but the BDD test references it.

**Fix**:
1. Extract `bdd.feature` from the stash or source branch: `git show 9ab11d3:lib/features/<name>/spec/bdd.feature > lib/features/<name>/spec/bdd.feature`
2. Commit it to the same branch as the BDD test: `git add && git commit -m "test(<feature>): add BDD feature file"`

### Type 3 — Stale Import in Barrel File

**Symptom**: `flutter analyze` error like:
```
error • Target of URI doesn't exist: 'package:.../login_screen.dart'
```

**Root cause**: A barrel file (`_configs.lib.dart`) imports a file from a later PR (e.g., `login_screen.dart` from PR004, but the barrel is committed in PR003).

**Fix**:
1. Determine if the import is actually needed by files in the current commit
2. If not needed → remove the import from the barrel file and amend the commit
3. If needed → the barrel file must be moved to a later PR alongside its dependency

**Implementation**:
```bash
# Check if the import is used by any file in the current branch
rg "LoginScreen" lib/ --include '*.dart' --exclude 'login_screen.dart'
# If not used, remove it
```

### Type 4 — Stale Intermediate Commits (Rebase Artifacts)

**Symptom**: `git log` on the branch shows unexpected duplicate commits. `flutter analyze` errors may be caused by an old version of a file reintroduced by a stale commit.

**Root cause**: During branch restructuring, `git rebase` carried forward old commits that reintroduce regressions. The HEAD may be clean, but intermediate commits break compilation.

**Fix**: Use the **Clean Rebuild Strategy**:
1. Save all required files for the branch
2. Delete the branch and recreate from parent
3. Re-apply commits one by one

---

## Step-by-Step Repair for Forward Dependencies

This is the most common and most critical fix:

1. **Analyze the error** from `flutter analyze`

2. **Build a dependency map**:
   ```bash
   # For the failing file, find all its imports
   grep -n "import 'package:" <failing_file>.dart
   ```

3. **For each import, find where it's defined**:
   ```bash
   # Check if the imported file is in the current branch
   for import_target in $(grep -oP "import 'package:[^']+" <failing_file>.dart); do
     local_path=$(echo "$import_target" | sed "s/import 'package:clean_architecture_sdd_harness\///" | sed "s/'//")
     echo "Checking: $local_path"
     if [ ! -f "lib/$local_path" ]; then
       echo "  MISSING — this file is from a later PR"
     fi
   done
   ```

4. **Restructure the PR boundary**:
   - If the missing file is in a later commit of the SAME PR → reorder commits within the PR
   - If the missing file is in a DIFFERENT PR → move it to the current PR or split appropriately

5. **Apply the fix** using the Clean Rebuild Strategy (see Execution Layer Step 6b).

---

## Maximum Retries

| Scenario | Max Retries | Escalation |
|---|---|---|
| Forward dependency restructure | 2 | If still failing after 2 restructures → escalate to human |
| Missing file (bdd.feature, etc.) | 1 | Simple fix — should work first time |
| Stale import cleanup | 2 | If import keeps reappearing → check for stale rebase commits |
| Stale intermediate commits | 3 | Use clean rebuild strategy. If still happening → escalate to human |

## Memory Protocol

```
mem_save(
  title: "Fix-execution-issues: <N> repairs for <feature>",
  type: "bugfix",
  content: "**What**: Fixed <N> execution issues for <feature>\n**Fixes**: <type1>, <type2>\n**Branches affected**: <branch_list>"
)
```
