---
description: |
  Review open GitHub PRs against 6 quality gates. Introspects the repository's
  branch protection (strict, required checks, approval count) and governance docs
  before evaluating. Fetches and tests each PR locally (analyzer, tests, dart
  format matching CI). Gates merges on the required-check matrix and never relies
  on self-approval (GitHub blocks it). Generates structured review report per PR.
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

> "Do you want to filter the PRs to review? You can specify (optional):
> - `--label <label>`: only PRs with a certain label
> - `--branch <pattern>`: only PRs whose branch matches the pattern (glob)
> - `--author <username>`: only PRs by a specific author
>
> Leave empty to review **all** open PRs."

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

## Step 3.5 — Detect repository configuration (mandatory preflight)

Before evaluating the gates, introspect the repository so NOTHING is hardcoded:

```bash
# 1. Who am I? (determines whether --approve is even possible)
gh api user --jq .login

# 2. Branch protection for the base branch (develop)
gh api repos/{owner}/{repo}/branches/{base}/protection \
  --jq '{strict: .required_status_checks.strict, contexts: .required_status_checks.contexts, approvals: .required_approving_review_count}'

# 3. Repository settings that shape the merge flow
gh api repos/{owner}/{repo} \
  --jq '{allow_update_branch: .allow_update_branch, delete_branch_on_merge: .delete_branch_on_merge, allow_auto_merge: .allow_auto_merge, squash_title: .squash_merge_commit_title, squash_body: .squash_merge_commit_message}'
```

Then read the local governance docs:

- `.github/REQUIRED_CHECKS.md` — source of truth for the required-check matrix.
- `.github/REPOSITORY_GOVERNANCE.md` — personal-account exception (this repo:
  0 approvals on develop; the gate is the required-check matrix + an explicit
  human merge after CI is green; GitHub blocks self-approval).

**Drift check (REQUIRED_CHECKS.md vs branch protection):** compare the contexts
listed in the doc against the introspected `required_status_checks.contexts`. If
they differ, report the drift in the final report and evaluate Gate 6 using the
INTROSPECTED contexts (the actual GitHub gate), flagging the doc as stale. Example
seen in this repo: `codecov/patch` is described in the doc's coverage section but
is NOT in branch protection — it never blocks a merge.

Record for later steps: `$MY_LOGIN`, `$REQUIRED_CONTEXTS`, `$STRICT`,
`$APPROVALS_REQUIRED`, `$ALLOW_UPDATE_BRANCH`, `$DELETE_BRANCH_ON_MERGE`.

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

Validate clean architecture rules (matrix per MD/APP_ARCHITECTURE.md, Rules 1-28):

```
shared              -> solo shared / Dart puro
core                -> shared y core; nunca features ni app
features/domain     -> shared y anotaciones permitidas
features/infra      -> own domain + shared + core
features/presentation -> own di + domain + shared + design_system + l10n
app                 -> composition root
```

- `lib/features/{f}/presentation/` must NOT import `infrastructure/` directly (it goes through `di/` and the shared seam)
- `lib/features/{f}/domain/` must NOT import `infrastructure/` or `presentation/`
- `lib/features/{f1}/` must NOT import from `lib/features/{f2}/` (feature isolation; auth/clinical_history coupling only via Shared Kernel contracts)
- `lib/shared/` must be pure Dart (no Flutter, no third-party types)
- `lib/core/` must NEVER import `features/` or `app/` (avoids `core <-> auth` cycles)

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

Check against the INTROSPECTED configuration (Step 3.5):

| Condition | Pass criteria |
|-----------|---------------|
| Mergeable | `mergeable == "MERGEABLE"` |
| No merge conflicts | `mergeable != "CONFLICTING"` |
| Required CI checks | Every context in `$REQUIRED_CONTEXTS` (branch protection) is green; a stacked PR pointed at an intermediate branch shows checks only after retarget → **WARN** |
| `statusCheckRollup` empty | **WARN** (no CI configured) |

**Evaluate ONLY the required contexts.** Jobs that appear as `skipping`
(`Branch Source Gate` on develop, `Integration` gated by `RUN_DEVICE_INTEGRATION`)
are OK. Non-required checks that fail (e.g. `codecov/patch` — not in branch
protection, upload is tolerant) are INFORMATIVE, never a FAIL.

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
dart format --output=none --set-exit-if-changed lib test integration_test
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

> *This PR requires manual review. Focus on: <specific areas>*

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

> "The following PRs passed all gates and are ready to approve and merge:
> - #<N1> — <title>
> - #<N2> — <title>
>
> Do you want me to run `gh pr review --approve` and then merge them in order?"

If stacked PRs were detected, also add:

> "⚠️ A stack of PRs was detected. They will be merged sequentially: all will be approved, then the base PR will be merged, the next one will be retargeted to develop, merged, and so on until the last one."

Valid affirmative answers: `yes`, `approve`, `approve all`, `execute`, `merge`, `merge all`, `si`, `sí`, `adelante`

If the user says no or provides a subset → only process the ones they confirm.

If the user says nothing affirmative → STOP. Do not approve or merge any PR.

---

## Step 9 — Execute approvals

Approval policy is driven by the introspected `$APPROVALS_REQUIRED` and `$MY_LOGIN`
(Step 3.5):

- `$APPROVALS_REQUIRED == 0` (this repo, personal-account exception) → approvals
  are unnecessary. Do NOT call `--approve`. The gate is the required-check matrix +
  the explicit human merge below. Optionally record the verification without
  approval:
  `gh pr review <N> --comment --body "Verified locally: analyzer, tests, dart format, required CI checks green."`
- `$APPROVALS_REQUIRED > 0` and `$MY_LOGIN != PR author` → `gh pr review <N> --approve`.
- `$APPROVALS_REQUIRED > 0` and `$MY_LOGIN == PR author` → **BLOCKED**: GitHub
  rejects self-approval (HTTP 422 "Can not approve your own pull request"). Notify
  the user that a second reviewer account is required; do NOT attempt `--approve`.

When approval IS applicable:

```bash
for N in <PR_NUMBER_1> <PR_NUMBER_2> ...; do
  gh pr review $N --approve && echo "✅ PR #$N: Approved via CLI" || {
    echo "❌ PR #$N: approval failed" >&2
    exit 1
  }
done
```

NEVER ignore a failed approval: capture stderr and STOP. A PR that was not
approved must not be merged as if it were.

---

## Step 10 — Merge execution

### ⚠️ GOLDEN RULE — SEQUENTIAL MERGE ONLY

In a stacked chain, each PR's branch is based on the previous PR's branch. Merging out of order or in parallel will cause "Base branch was modified" errors and potential conflicts.

**Policy**: this repository squash-merges with `squash_merge_commit_title: PR_TITLE` (see README.md → Git Flow). ALWAYS use `--squash`. NEVER use `--merge`, which would leave merge commits and contradict the documented branch protection policy.

**NEVER** use parallel tool calls (`bash` invocations in the same message) for merge operations. Always use a **single sequential `for` loop** in one `bash` call.

### 10.0 — Preconditions (driven by Step 3.5 introspection)

- `develop` is protected with `strict: true` → every PR must be **up-to-date** with its base before merge. `gh pr update-branch` is available because `$ALLOW_UPDATE_BRANCH == true`. If it is NOT available, merge locally instead (fetch the PR head, merge the base, push) — but first check the repo settings, they may have changed.
- The repo auto-deletes merged branches (`$DELETE_BRANCH_ON_MERGE == true`) → do NOT pass `--delete-branch=false`; never depend on a merged branch still existing.
- A draft PR blocks the merge → always `gh pr ready <N>` first, WITHOUT `2>/dev/null` (show errors).

### 10.1 — Single merge procedure (independent AND stacked)

This flow is idempotent/resumable: it skips PRs already MERGED, so it can be
re-run safely after a partial failure.

```bash
for N in <PR_NUMBER_1> <PR_NUMBER_2> ...; do
  if [ "$(gh pr view $N --json state -q .state)" = "MERGED" ]; then
    echo "✅ PR #$N already merged. Skipping."
    continue
  fi

  echo "🔀 Processing PR #$N..."
  gh pr ready $N || { echo "❌ PR #$N: failed to make ready" >&2; exit 1; }

  # Retarget stacked PRs to develop once the previous PR is merged.
  BASE=$(gh pr view $N --json baseRefName -q .baseRefName)
  if [ "$BASE" != "develop" ]; then
    gh pr edit $N --base develop || { echo "❌ PR #$N: retarget failed" >&2; exit 1; }
  fi

  # strict: true → bring the branch up to date BEFORE merging.
  gh pr update-branch $N || { echo "❌ PR #$N: update-branch failed" >&2; exit 1; }

  # Wait until every REQUIRED context is green. `gh pr checks --required` exits 0
  # only when all branch-protection-required checks have passed; it ignores
  # non-required checks (e.g. codecov/patch) and "skipping" jobs.
  attempts=0
  while ! gh pr checks $N --required >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ $attempts -gt 60 ]; then
      echo "❌ PR #$N: required checks not green after ~15 min" >&2
      exit 1
    fi
    gh pr checks $N --required | grep -q "fail" && {
      echo "❌ PR #$N: a required check failed" >&2
      exit 1
    }
    sleep 15
  done

  # Wait for mergeStateStatus == CLEAN (not BEHIND / BLOCKED / DIRTY).
  while [ "$(gh pr view $N --json mergeStateStatus -q .mergeStateStatus)" != "CLEAN" ]; do
    MS=$(gh pr view $N --json mergeStateStatus -q .mergeStateStatus)
    case "$MS" in
      BLOCKED) echo "❌ PR #$N: merge blocked ($MS)" >&2; exit 1 ;;
      BEHIND)  gh pr update-branch $N ;;
    esac
    sleep 15
  done

  gh pr merge $N --squash || { echo "❌ PR #$N: merge failed" >&2; exit 1; }
  echo "✅ PR #$N merged"
done
```

**Why retarget + update-branch works:** After the previous PR is merged into develop, its commits are already part of develop. Retargeting (`--base develop`) makes GitHub recalculate the merge-base, so the diff shrinks to only the PR's own commits. With `strict: true` the merge ALSO requires the branch to be up-to-date — `gh pr update-branch` satisfies that, so no `git rebase` or manual merge is needed in the normal case.

**Post-merge CI (why a post-merge run may look cancelled):** `ci.yml` also
triggers on `push` to `develop`/`main`, so every squash merge starts a fresh full
run on the new develop commit — in addition to the PR-head gate above. Because
`concurrency: cancel-in-progress: true` groups runs by ref (`ci-${{ github.ref }}`),
the next merge in a rapid stack CANCELS the previous post-merge run (e.g. a
`Build Android: cancelled` on an earlier squash commit is expected and benign).
The AUTHORITATIVE merge gate is the PR-head required checks, which this loop
already waits for; the post-merge run is a safety net, not a gate.

**Recovering from an `add/add` conflict in update-branch** (e.g. a formatting fix
was pushed to an upstream PR but not propagated downstream): GitHub cannot
auto-update. Resolve locally taking develop's version of the conflicting file:

```bash
git fetch origin pull/<N>/head:review/pr-<N>
git checkout review/pr-<N>
git merge origin/develop        # conflict expected on the shared file
git checkout origin/develop -- <conflicted-file>   # take develop's version
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
git commit -m "fix(scope): resolve update-branch conflict from develop"
git push origin review/pr-<N>:refs/heads/<pr-branch>
```

STOP only if the conflict is a REAL semantic conflict (not formatting/no-op);
notify the user otherwise.

**Squash policy**: Always `--squash`. The internal atomic commits remain mandatory for review and rollback before the merge; the squash commit preserves reviewability on develop (README.md → Git Flow). Do NOT use `--merge`.

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
| Parallel merge attempt | NEVER use parallel bash calls for merges in a stacked chain. Always use a single sequential `for` loop per Step 10.1. |
| Stacked PRs detected (base != develop) | Report stacking info to user. Merge sequentially per Step 10.1. |
| Retarget conflict (`gh pr edit` fails) | STOP. The previous PR was not fully merged. Notify user. |
| Diff after retarget seems too large | Before merging, verify: `gh pr diff <N> | wc -l` should show only the PR's own changes. |
| Merge conflict after retarget | STOP. PR has conflicts with develop after retarget. Do NOT continue with downstream PRs. |
| Mixed stack (some PRs target develop, others target a PR branch) | Process the independent PRs first (those targeting develop/main), then the stacked chain. |
| User confirms a subset of PRs in a stack | If they skip a PR in the middle of a stack, the downstream PRs cannot be merged. Inform the user. |
| User says "approve only" without merge | Only run `gh pr review <N> --approve` (if applicable per Step 9). Do NOT merge any PR. |
| Self-approval would be required (`$MY_LOGIN` == author and `$APPROVALS_REQUIRED > 0`) | GitHub rejects self-approval (HTTP 422). Never call `--approve`; gate on the required-check matrix + human merge. Notify the user a second reviewer account is needed. |
| `codecov/patch` fails but is not required | Informative only (not in branch protection; upload tolerant). NOT a Gate 6 failure. |
| PR is a draft at merge time | Run `gh pr ready <N>` before merge (Step 10.1). |
| `gh pr update-branch` conflicts (`add/add`) | Resolve locally taking develop's version (Step 10.1 recovery). STOP only on real semantic conflicts. |
| `mergeStateStatus` stays `BEHIND` | Re-run `gh pr update-branch <N>` and re-wait for CLEAN. |
| PR already MERGED when re-running the merge loop | Skip it (idempotent/resumable loop). |
| REQUIRED_CHECKS.md drifts from branch-protection contexts | Report the drift in the final report; evaluate Gate 6 with the introspected contexts (the real gate). |
