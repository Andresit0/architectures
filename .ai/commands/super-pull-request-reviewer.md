---
description: |
  Review open GitHub PRs against 6 quality gates. Supports filtering by
  label, branch, or author. Fetches and tests each PR locally before
  approval. Generates structured review report per PR.
---

# Super Pull-Request Reviewer

Analyze open GitHub PRs and evaluate them against the 6 quality gates.
Generates a structured review table and detailed per-PR review blocks.

---

## Step 0 — Load skills

Load:

- `.opencode/skills/app-agent-context-reader/SKILL.md`
- `.opencode/skills/app-changes/SKILL.md`

---

## Step 1 — Ask for optional filters

Ask the user:

> "¿Quieres filtrar los PRs a revisar? Puedes especificar (opcional):
> - `--label <label>`: solo PRs con cierto label
> - `--branch <pattern>`: solo PRs cuya rama coincida con el patrón (glob)
> - `--author <username>`: solo PRs de un autor específico
>
> Deja vacío para revisar **todos** los PRs abiertos."

Collect `$FILTER_LABEL`, `$FILTER_BRANCH`, `$FILTER_AUTHOR` from the user response.

---

## Step 2 — List open PRs

```bash
gh pr list --state open --json number,title,headRefName,author,updatedAt,labels,mergeable,reviews,additions,deletions --limit 50
```

Apply filters if provided:

| Filter | jq expression |
|--------|---------------|
| `$FILTER_LABEL` | `map(select(.labels | any(.name == "$FILTER_LABEL")))` |
| `$FILTER_BRANCH` | `map(select(.headRefName | test("$FILTER_BRANCH")))` |
| `$FILTER_AUTHOR` | `map(select(.author.login == "$FILTER_AUTHOR"))` |

If no PRs match → STOP. Inform user.

Generate the initial summary table:

```
| # | Title | Branch | Author | Labels | ± Lines | Updated | Mergeable |
|---|---|---|---|---|---|---|---|
| 1 | Dependencies & Platform | chore/deps | user1 | build | +45 -12 | 2026-07-05 | MERGEABLE |
| 2 | Shared Models | feat/models | user2 | feat | +120 -30 | 2026-07-04 | MERGEABLE |
```

Also record `$PR_NUMBERS` — the list of PR numbers to review.

---

## Step 3 — Collect review data per PR

For each PR in `$PR_NUMBERS`:

### 3.1 — Get PR details

```bash
gh pr view <N> --json body,title,additions,deletions,files,commits,statusCheckRollup
```

### 3.2 — Get full diff

```bash
gh pr diff <N>
```

### 3.3 — Extract key data

| Field | Source | Purpose |
|-------|--------|---------|
| `description` | `body` | Compare scope against diff |
| `files` | `files[].path` | Detect unrelated changes |
| `statusCheckRollup` | `statusCheckRollup[].conclusion` | CI status |
| `mergeable` | from Step 2 | Merge readiness |
| `diff` | `gh pr diff` | Full code review |

Save per-PR data for evaluation.

---

## Step 4 — Evaluate the 6 quality gates

For each PR, evaluate all 6 gates:

### Gate 1 — ✓ Scope matches PR description

Compare the PR `body` (description) against the files changed and the actual diff.

- If description mentions "database migration" and all changes are in `lib/core/database/` + `test/core/database/` → **PASS**
- If description mentions "auth" and changes include unrelated files (e.g., `MD/`, `pubspec.yaml`) → flag them
- If description is empty or too vague → **WARN** (partial pass)

Result: `PASS` / `WARN` / `FAIL`

### Gate 2 — ✓ No unrelated changes detected

Inspect the file list. For each file, determine if it belongs to the PR's declared scope.

| Category | Classification |
|----------|---------------|
| `pubspec.yaml` / `pubspec.lock` | Always acceptable if PR updates deps; otherwise flag |
| `*.g.dart` / `*.freezed.dart` | Acceptable if their source `.dart` file is also in the PR |
| `MD/**` / `AGENTS.md` | Acceptable if PR includes doc updates; otherwise flag |
| Build artifacts (`build/`, `.dart_tool/`) | Always flag — should not be committed |
| Files from a different feature layer | Flag (e.g., infra changes in a domain-only PR) |

Result: `PASS` / `FAIL`

### Gate 3 — ✓ Architecture remains consistent

Validate clean architecture rules:

- `lib/**/domain/` must NOT import from `infrastructure/` or `presentation/`
- `lib/**/infrastructure/` may import from `domain/` only
- `lib/**/presentation/` may import from `domain/` and `infrastructure/`
- `lib/features/{f1}/` must NOT import from `lib/features/{f2}/` (feature isolation)
- `lib/shared/` should not import from `lib/features/`

Analyze imports in the diff to detect violations.

Result: `PASS` / `FAIL`

### Gate 4 — ✓ Tests are appropriate for the modified code

For each modified file in `lib/`, check if the corresponding test file exists in `test/`:

| Modified file | Expected test file |
|---------------|-------------------|
| `lib/shared/models/patient_entity.dart` | `test/shared/models/patient_entity_test.dart` |
| `lib/core/database/tables/clinical_history.dart` | `test/core/database/tables/clinical_history_test.dart` |
| `lib/features/auth/domain/login_usecase.dart` | `test/features/auth/domain/login_usecase_test.dart` |
| `lib/features/auth/infrastructure/auth_repository.dart` | `test/features/auth/infrastructure/auth_repository_test.dart` |
| `lib/features/auth/presentation/login_notifier.dart` | `test/features/auth/presentation/login_notifier_test.dart` |

Exceptions:
- Config files, `pubspec.*`, generated files → no test required
- `lib/**/spec/**` → no test required (spec docs)
- Pure UI files (widgets without logic) → widget test recommended but not required

Also check that test files are actually modified in the PR (or already exist in the repo).

Result: `PASS` / `WARN` / `FAIL`

### Gate 5 — ✓ Run code to verify it works (local checkout)

This is performed in Step 5 as a separate operation. For now, mark as `PENDING`.

### Gate 6 — ✓ Ready to merge

Check:

| Condition | Pass criteria |
|-----------|---------------|
| Mergeable | `mergeable == "MERGEABLE"` |
| No merge conflicts | `mergeable != "CONFLICTING"` |
| CI status | All `statusCheckRollup[].conclusion == "SUCCESS"` |

If `statusCheckRollup` is empty → **WARN** (no CI configured).

Result: `PASS` / `WARN` / `FAIL`

---

## Step 5 — Local verification (Run Code)

For each PR in `$PR_NUMBERS`:

### 5.1 — Fetch and checkout

```bash
git fetch origin pull/<N>/head:review/pr-<N>
git checkout review/pr-<N>
```

### 5.2 — Install dependencies

```bash
flutter pub get
```

### 5.3 — Run tests

```bash
flutter test
```

Record result (`PASS` / `FAIL`). If `flutter test` fails → log the failure output.

### 5.3.5 — Build smoke check (Android APK)

If the PR diff touches `lib/**`, `pubspec.*` or `android/**`, also run a build smoke check:

```bash
flutter build apk --debug
```

Record result (`PASS` / `FAIL`). This catches compile/build regressions that
`flutter test` does not (e.g. plugin/namespace issues). If it fails → log the
failure output and mark Gate 5 as FAIL. Skip this step for docs-only PRs.

### 5.4 — Return to original branch

```bash
git checkout -
```

Update Gate 5 result for the PR.

---

## Step 6 — Generate approval verdict

For each PR, apply the verdict rules:

| Condition | Verdict |
|-----------|---------|
| All 6 gates PASS | ✅ **Approve** — candidate for auto-approval |
| 5 PASS + 1 WARN (Gate 4 or Gate 6) | ✅ **Approve** — minor warning, acceptable |
| Any FAIL | ❌ **Needs review** — explain which gate(s) failed |
| Gate 5 (Run Code) = FAIL | ❌ **Blocked** — tests fail locally |

Also apply **content-based heuristics** to decide if auto-approve is safe:

| PR contains... | Auto-approve safe? |
|---|---|
| Only `pubspec.*`, platform configs, `*.g.dart` | ✅ Yes — low risk |
| `lib/features/*/spec/**`, `MD/**`, `AGENTS.md`, `.ai/**`, docs only | ✅ Yes — documentation |
| `lib/shared/models/**` + corresponding tests passing | ✅ Yes — model changes with test coverage |
| `lib/**/domain/**` (entities, interfaces, use cases) + tests passing | ✅ Yes — domain layer with test coverage |
| `lib/shared/exceptions/**` + tests | ✅ Yes — simple exception changes |
| `lib/**/infrastructure/**` (implementations, datasources, repositories) | ❌ Needs human review — implementation logic |
| `lib/**/presentation/**` (notifiers, screens, widgets) | ❌ Needs human review — UI/state logic |
| Database migrations, engine changes | ❌ Needs human review — critical infra |
| New package dependencies added | ❌ Needs human review — dependency audit |
| Merge conflict or CI failure | ❌ Blocked — must resolve first |

**Auto-approval requires BOTH**:
- All gates PASS (or 5 PASS + 1 WARN)
- Content-based heuristic says safe

If auto-approval criteria are met → label as `✅ Auto-Approve Candidate`
Otherwise → label as `❌ Needs Review`

---

## Step 7 — Generate review report

### 7.1 — Approval summary table

```
╔══════════════════════════════════════════════════════════════════════════╗
║  PR Review — Summary                                                    ║
╠════╤═══════════════════╤═══════╤══════════╤══════╤═══════╤════════╤══════╣
║ #  │ Title             │ Scope │ Unrelated│ Arch │ Tests │ Run    │Ready│
║    │                   │ Match │          │      │       │ Code   │     ║
╠════╪═══════════════════╪═══════╪══════════╪══════╪═══════╪════════╪══════╣
║ 1  │ Dependencies      │   ✓   │    ✓     │  ✓   │   ✓   │   ✓    │  ✓  ║
║ 2  │ Shared Models     │   ✓   │    ✓     │  ✓   │   ✓   │   ✓    │  ✓  ║
║ 3  │ Auth Infra        │   ✓   │    ✓     │  ✓   │   ✓   │   ✓    │  ✓  ║
║ 4  │ Migration         │   ✓   │    ✓     │  ✓   │   ✓   │   ✗    │  ✓  ║
╠════╪═══════════════════╪═══════╪══════════╪══════╪═══════╪════════╪══════╣
║    │                   │       │          │      │       │        │      ║
║    │ ✅ Auto-Approve:  │ #1, #2                                                  ║
║    │ ❌ Needs Review:  │ #3 (infra — human review recommended)                    ║
║    │ 🔴 Blocked:       │ #4 (tests failing locally)                              ║
╚══════════════════════════════════════════════════════════════════════════╝
```

### 7.2 — Detailed review blocks

For each PR, generate a structured review block:

**Auto-Approve candidates get:**
```
### PR #<N> — <title>
Reviewed <area>.

Verified:
- <specific verification point 1>
- <specific verification point 2>
- <specific verification point 3>
- <specific verification point 4>
- Tests pass.
- Code is ready to merge.

Approved.
```

**Needs Review get:**
```
### PR #<N> — <title>
Reviewed <area>.

Verified:
- <specific verification point 1> ✓
- <specific verification point 2> ✓
- ⚠️ <issue found> — <explanation>
- <specific verification point 4> ✓

❌ Needs review — <reason for flagging>.
```

**Blocked get:**
```
### PR #<N> — <title>
Reviewed <area>.

Verified:
- <specific verification point 1> ✓
- <specific verification point 2> ✓
- <specific verification point 3> ✓
- 🔴 <blocking issue> — <explanation>

🔴 Blocked — <reason>.
```

Use the examples provided as the style template:

```
### PR #1 — Dependencies & Platform
Reviewed dependency and platform changes.

Verified:
- Dependency updates are consistent.
- Platform configuration changes are generated/expected.
- No functional behavior introduced.
- CI and tests passed.

Approved.
```

### 7.3 — Visual indicators per PR

Based on review depth (heuristic):

| Classification | Label |
|---------------|-------|
| Auto-approve (docs/config/models/domain) | `📋 Review` (light) |
| Needs human review (infra/presentation/deps) | `🔍 Review` (thorough) |
| Blocked | `🚫 Blocked` |

Output this note after each blocked/needs-review PR:

> *Este PR requiere revisión manual. Enfócate en: <specific areas>*

---

## Step 8 — STOP. Confirm approvals and merges

### 8.1 — Detect stacked PRs

From the Step 2 data (which includes `baseRefName`), identify if PRs form a stack:

| Condition | Stack detected |
|---|---|
| All PRs have `baseRefName == develop` (or `main`) | **No** — independent PRs |
| Any PR has `baseRefName != develop` and `baseRefName != main` | **Yes** — stacked PRs |

If stacked, determine the merge order by analyzing the dependency chain. The first PR has `baseRefName == develop`; each subsequent PR's `baseRefName` equals the previous PR's `headRefName`.

### 8.2 — Show summary and ask

Show the summary table from Step 7.1 to the user and ask:

> "Los siguientes PRs pasaron todos los gates y están listos para aprobar y mergear:
> - #<N1> — <title>
> - #<N2> — <title>
>
> ¿Quieres que ejecute `gh pr review --approve` y luego los mergee en orden?"

If stacked PRs were detected, also add:

> "⚠️ Se detectó un stack de PRs. Se mergearán secuencialmente: se aprobarán todos, luego se mergeará el PR base, se retargeteará el siguiente a develop, se mergeará, y así sucesivamente hasta el último."

Valid affirmative answers: `yes`, `approve`, `approve all`, `execute`, `merge`, `merge all`, `si`, `sí`, `adelante`

If the user says no or provides a subset → only process the ones they confirm.

If the user says nothing affirmative → STOP. Do not approve or merge any PR.

---

## Step 9 — Execute approvals

For each PR the user confirmed:

```bash
for N in <PR_NUMBER_1> <PR_NUMBER_2> ...; do
  gh pr review $N --approve && echo "✅ PR #$N: Approved via CLI" || echo "❌ PR #$N: approval failed"
done
```

---

## Step 10 — Merge execution

### ⚠️ GOLDEN RULE — SEQUENTIAL MERGE ONLY

In a stacked chain, each PR's branch is based on the previous PR's branch. Merging out of order or in parallel will cause "Base branch was modified" errors and potential conflicts.

**NEVER** use parallel tool calls (`bash` invocations in the same message) for merge operations. Always use a **single sequential `for` loop** in one `bash` call.

### 10.1 — Independent PRs (all target develop)

```bash
for N in <PR_NUMBER_1> <PR_NUMBER_2> ...; do
  echo "🔀 Merging PR #$N..."
  gh pr ready $N 2>/dev/null
  gh pr merge $N --merge && echo "✅ PR #$N merged" || echo "❌ PR #$N failed"
done
```

### 10.2 — Stacked PRs (each targets the previous PR's branch)

Merge in dependency order (base PR first, then each subsequent PR):

```bash
# 1. Merge the base PR (it already targets develop/main)
BASE_N=<BASE_PR_NUMBER>
gh pr ready $BASE_N 2>/dev/null
gh pr merge $BASE_N --merge || { echo "❌ PR #$BASE_N failed. STOP."; exit 1; }

# 2. For each remaining PR in the stack:
for N in <NEXT_N1> <NEXT_N2> ...; do
  echo "🔀 Processing PR #$N..."
  gh pr ready $N 2>/dev/null
  gh pr edit $N --base develop
  gh pr merge $N --merge && echo "✅ PR #$N merged" || {
    echo "❌ PR #$N merge failed. STOP. Do not continue with downstream PRs."
    exit 1
  }
done
```

**Why retarget works:** After the previous PR is merged into develop, its commits are already part of develop. Retargeting (`--base develop`) makes GitHub recalculate the merge-base, so the diff shrinks to only the PR's own commits. No `git rebase` or manual merge is needed.

**No `--squash`**: Use `--merge` to keep individual commits. Squash merges collapse the PR into a single commit, losing granularity and complicating stacked chains.

---

## Step 11 — Cleanup

Remove temporary branches:

```bash
for BRANCH in $(git branch | grep 'review/pr-'); do
  git branch -D "$BRANCH"
done
```

---

## Edge Cases

| Situation | Handling |
|-----------|----------|
| No open PRs | STOP. Inform user there are no PRs to review. |
| `gh` not authenticated | STOP. Run `gh auth status` and guide user to login. |
| PR diff is empty | Mark as FAIL on Gate 5 (nothing to test). Flag as suspicious. |
| `flutter pub get` fails locally | Log the error. Mark Gate 5 as FAIL. Continue to next PR. |
| PR has no CI checks (statusCheckRollup empty) | Gate 6 → WARN. Still run local tests (Gate 5) for coverage. |
| Merge conflict detected | Gate 6 → FAIL. Do not attempt local checkout. |
| Network error during fetch | Retry once. If still fails → skip PR, mark Gate 5 as FAIL. |
| Single PR matching filters | Process normally — still run through all 6 gates. |
| Only docs/MD PRs | Skip heavy `flutter test` if no Dart files changed. Gate 5 → PASS automatically. |
| PR modifies generated files without source | Flag as suspicious (Gate 2 → FAIL). |
| Parallel merge attempt | NEVER use parallel bash calls for merges in a stacked chain. Always use a single sequential `for` loop per Step 10.2. |
| Stacked PRs detected (base != develop) | Report stacking info to user. Merge sequentially per Step 10.2. |
| Retarget conflict (`gh pr edit` fails) | STOP. The previous PR was not fully merged. Notify user. |
| Diff after retarget seems too large | Before merging, verify: `gh pr diff <N> | wc -l` should show only the PR's own changes. |
| Merge conflict after retarget | STOP. PR has conflicts with develop after retarget. Do NOT continue with downstream PRs. |
| Mixed stack (some PRs target develop, others target a PR branch) | Process the independent PRs first (those targeting develop/main), then the stacked chain. |
| User confirms a subset of PRs in a stack | If they skip a PR in the middle of a stack, the downstream PRs cannot be merged. Inform the user. |
| User says "approve only" without merge | Only run `gh pr review <N> --approve`. Do NOT merge any PR. |
