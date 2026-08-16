---
description: |
  Smart PR Split pipeline: analyze all changes vs base branch → classify files by
  category (feature-agnostic) → plan atomic PRs → execute stacked branches sequentially
  with per-PR validation+repair → re-validate ALL → publish stacked PRs on GitHub.
---

# Super Pull-Request — Smart PR Split Pipeline

Replaces the legacy orchestrator. This command is the single entry point for turning
any set of unstaged/staged changes into professional, reviewable, stacked PRs.

Whenever this command is loaded, **execute the full pipeline below without asking
"Yes? → No?" intermediate questions**. The split is the default.

---

## Step 0 — Load skills

Load the following skills for repair during execution:

- `.opencode/skills/app-agent-fix-analyzer-issues/SKILL.md`
- `.opencode/skills/app-agent-fix-tests/SKILL.md`

---

## Step 1 — Detect base branch

```bash
git branch -a | grep -i develop
```

If `develop` exists (local or remote `origin/develop`):
  Set `$BASE = develop`

If `develop` does NOT exist:
  **STOP.** Ask the user: "Branch develop was not found. Which branch should be used as base?"
  Wait for their answer and set `$BASE = <user_answer>`

Once confirmed, fetch the latest:

```bash
git fetch origin $BASE 2>/dev/null || true
```

---

## Step 2 — Analyze all changes

### 2.1 — Run git commands

```bash
git status --short
git diff $BASE..HEAD --stat
git diff $BASE..HEAD
git log --oneline -10
```

### 2.2 — Classify every changed file (dynamic, feature-agnostic)

For each file in the diff, detect the **group name** using these rules:

| Path pattern                                          | Group name              | Test merge policy                     |
|-------------------------------------------------------|-------------------------|---------------------------------------|
| `pubspec.yaml` / `pubspec.lock`                       | `deps`                  | —                                     |
| `linux/**` / `macos/**` / `windows/**` / `ios/**`     | `platform`              | —                                     |
| `integration_test/**`                                 | `integration-tests`     | —                                     |
| `test/bdd/**`                                         | `bdd-tests`             | —                                     |
| `MD/**` / `AGENTS.md`                                 | `docs`                  | —                                     |
| `lib/core/database/**`                                | `database`              | `test/core/database/**` → merge       |
| `lib/shared/models/**`                                | `models`                | `test/shared/models/**` → merge       |
| `lib/shared/exceptions/**`                            | `exceptions`            | `test/shared/exceptions/**` → merge   |
| `lib/design_system/theme/**`                           | `theme`                 | —                                     |
| `lib/core/services/**`                                | `services:{filename}`   | `test/core/services/**` → merge       |
| `lib/core/network/interceptors/**`                    | `interceptors`          | `test/core/network/interceptors/**` → merge |
| `lib/app/di/**`                                       | `app-di`                | `test/app/di/**` → merge              |
| `lib/features/{f}/spec/**`                            | `{f}-spec`              | —                                     |
| `lib/features/{f}/domain/**`                          | `{f}-domain`            | `test/features/{f}/domain/**` → merge |
| `lib/features/{f}/infrastructure/**`                  | `{f}-infra`             | `test/features/{f}/infrastructure/**` → merge |
| `lib/features/{f}/presentation/**`                    | `{f}-presentation`      | `test/features/{f}/presentation/**` → merge |
| `**/generated_plugin_registrant.*` / `**/generated_plugins.cmake` | `deps` (forced)     | Forced to `deps` — NEVER assigned to another PR |
| `**/*.g.dart` / `**/*.freezed.dart`                              | `generated`         | Merge with the group of the source .dart file |

**Feature detection**: Extract `{f}` from whatever directory name exists under
`lib/features/`. There may be multiple features; each gets its own `{f}-*` groups.

**Test merge rule**: Tests are ALWAYS merged into the same group as their
production code. Never create a separate PR for tests.

Output a table:

```
| File | Group |
|------|-------|
| lib/core/database/app_database.dart | database |
| lib/features/auth/domain/login_entity.dart | auth-domain |
| test/features/auth/domain/login_entity_test.dart | auth-domain (merged) |
```

---

## Step 3 — Smart PR Split

### 3.1 — Detect file groups

After Step 2 classification, each file belongs to a group. These groups are the
building blocks (not the PRs themselves). Typical groups:

`deps`, `platform`, `models`, `database`, `exceptions`, `configs`, `jsons`,
`functions:{name}`, `interceptors`, `providers`, `shared-widgets`,
`{f}-spec`, `{f}-domain`, `{f}-infra`, `{f}-presentation`,
`bdd-tests`, `integration-tests`, `docs`, `ai`

### 3.2 — Merge file groups into functional capabilities

**Do NOT create one PR per file group.** Instead, merge related groups into
**functional capabilities** — each capability represents a single architectural
decision or feature concern that a reviewer can evaluate independently.

Apply these merge rules in order:

| # | Rule | Merge condition | Capability title template |
|---|------|----------------|---------------------------|
| R1 | Dependency setup | If `deps` + `platform` both exist | `build(deps): add dependencies and platform configuration` |
| R2 | Shared models | If `models` exists | `feat(models): add shared domain entities` |
| R3 | Database migration | If `database` exists | `feat(database): migrate to sembast schema` |
| R4 | Infrastructure cleanup | If `exceptions` + `configs` + `jsons` all exist and sum < 200 lines | `refactor: consolidate exceptions and configuration` |
| R5 | Network infrastructure | If `services:internet_service` + `services:reachability` both exist | `feat(network): add server reachability strategies` |
| R6 | Auth interceptor | If `interceptors` exists + `services:dio` | `feat(network): add auth interceptor with retry` |
| R7 | Routing + providers | If `providers` exists + `app:router` | `refactor: update routing and provider wiring` |
| R8 | AI tooling | If `ai` exists | `chore: update AI tooling configuration` |
| R9a | Feature spec | If `{f}-spec` exists | `docs({f}): add specification artifacts` |
| R9b | Feature domain | If `{f}-domain` exists | `feat({f}): add domain layer` |
| R10 | Feature infra | If `{f}-infra` exists | `feat({f}): implement infrastructure layer` |
| R11 | Feature presentation | If `{f}-presentation` + `shared-widgets` both exist | `feat({f}): implement presentation layer` |
| R12 | Finalization | If `bdd-tests` + `integration-tests` + `docs` all exist | `test: add BDD, integration tests and documentation` |
| R13 | Generated code | If `generated` exists | Merge with the PR that contains the source .dart file |

**Rules for capabilities without a merge rule**:
- If a file group does not match any R1-R13 condition → create its own capability.
- E.g., `docs` alone → `docs: update documentation`

**Quality checks for the merge**:
- One capability = one architectural decision. Do NOT merge unrelated concerns
  even if they have few lines. E.g., `deps` must never merge with `interceptors`.
- Feature layers (`{f}-domain`, `{f}-infra`, `{f}-presentation`) are NEVER merged
  with each other — each is a different reviewer concern.
- Tests ALWAYS stay in the same capability as their production code (enforced in Step 2).
- If a capability exceeds 400 lines → suggest sub-split in the plan output.

### 3.3 — Order capabilities topologically

Sort capabilities by dependency order (not by rule number):

```
 1. dependency-setup       (R1)   — deps + platform
 2. shared-models          (R2)   — models only
 3. database-migration     (R3)   — database + wrappers
 4. infrastructure-cleanup (R4)   — exceptions + configs + jsons
  5. network-infra          (R5)   — internet_service + server_reachability_strategy
  6. auth-interceptor       (R6)   — interceptors + dio
 7. routing-providers      (R7)   — providers + go_router
 8. ai-tooling             (R8)   — .ai/ tooling changes
 9. {f}-spec               (R9a)  — feature specification docs
10. {f}-domain             (R9b)  — domain entities + interfaces + usecases
11. {f}-infra              (R10)  — infrastructure layer
12. {f}-presentation       (R11)  — presentation + widgets
13. finalization           (R12)  — bdd + integration + docs
```

If a capability has no files (no matching file groups), skip it.

### 3.4 — Compilation audit BEFORE accepting the automatic split (mandatory)

The generic split (R9b/R10/R11) separates domain/infra/presentation. That
mechanical split is WRONG when a capability's contracts are entangled across
layers. Before accepting the auto-split for any large change:

1. Apply each proposed capability onto a clean copy of the base branch.
2. Run `flutter analyze` + the affected test set.
3. Record errors per capability and per missing dependency.
4. If a capability fails because its contracts live in another capability,
   merge both into one ATOMIC capability and document the reason.
5. Repeat until every public PR is compilable and green.

**Documented exception (clean-architecture migration PR 7):** the atomic core
(refactor/clean-architecture-core) contains errors, database, network
contracts, auth, app seams, clinical history and their tests as a SINGLE
atomic PR. Its commits are internal review units ordered by dependency and
validated GREEN; it is NEVER subdivided by folder. The recommended 400-line
limit may be overridden for this PR only with the compilation audit report and
Architecture Board approval.

**Stack depth limit:** no active stack may exceed two levels. Public PRs must
receive CI against `develop` before review/merge; a PR pointing at an
intermediate branch is not protected by required checks until retargeted.

**No RED commits:** never publish a commit that leaves the project
non-compiling or with known-failing tests. RED is a local TDD artifact only;
it never reaches the shared branch.

### 3.5 — File Overlap Audit + Auto-correction

**Purpose**: Prevent the same file from appearing in multiple PRs (which causes
silent conflicts like `generated_plugin_registrant.cc` bouncing between PRs).

For each file across ALL planned PRs, check if it belongs to >1 PR:

```
For each PR, collect its file list into pr_{N}_files.txt
Concatenate all lists, sort, find duplicates (uniq -d)
```

If any file appears in multiple PRs:

1. **Identify owner**: the PR with the lowest topological level (the one that
   needs the file first in the dependency chain).
2. **Auto-correct**: remove the file from ALL other PRs. Since branches are
   stacked, downstream PRs inherit the file from their base branch — they
   don't need to include it in their diff.
3. **Recalculate** `~{N} lines` for affected PRs.
4. **Log the correction**:

```
⚠️ File Overlap Auto-corrected:
  generated_plugin_registrant.cc
    PR #1 (deps) ← owner (level 0)
    PR #4 (exceptions) ← removed (inherited from base)

  generated_plugins.cmake
    PR #1 (deps) ← owner (level 0)
    PR #4 (exceptions) ← removed (inherited from base)
```

If no overlaps:

```
✅ File Overlap Audit: 0 conflicts detected
```

### 3.6 — For each PR, generate a structured block

```
### PR {N} — `<type>(<scope>): <title>`
**Rationale**: <why this PR exists as a separate unit — one architectural decision>

```
<commit-message-1>
<commit-message-2>
<commit-message-3>
```

~{N} lines, estimated review: {N} min
```

Commit messages follow **Conventional Commits** (full table):

| Type      | When to use                                  | Example                                          |
|-----------|----------------------------------------------|--------------------------------------------------|
| `feat`    | New visible functionality                    | `feat(auth): add biometric login`               |
| `fix`     | Bug fix                                      | `fix(auth): prevent token refresh loop`          |
| `refactor`| Structure change without behavior change     | `refactor(storage): extract persistence service` |
| `perf`    | Performance optimization                     | `perf(list): reduce rebuild count`               |
| `test`    | Adding or modifying tests                    | `test(auth): add login notifier tests`           |
| `docs`    | Documentation                                | `docs(api): update auth flow`                    |
| `build`   | Dependencies or build system                 | `build(deps): update freezed`                    |
| `ci`      | CI/CD pipelines                              | `ci(github): add release workflow`               |
| `chore`   | Maintenance with no functional impact        | `chore(repo): cleanup scripts`                   |
| `style`   | Formatting only                              | `style(ui): apply formatter`                     |
| `revert`  | Revert a commit                              | `revert: feat(auth): add remember me`            |
| `release` | Version release                              | `release: v1.4.0`                                |

### 3.6.5 — PR Title Rules (mandatory)

This repository squash-merges with `squash_merge_commit_title: PR_TITLE` and
`squash_merge_commit_message: PR_BODY` (see `LEARN.md` → Merge strategy). **The
PR title becomes the commit on `develop`/`main`.** Therefore every PR title:

- MUST follow Conventional Commits: `<type>(<scope>): <subject>`
- MUST be in English and imperative mood
- MUST be ≤ 72 characters (truncate the subject; move detail to the body)
- MUST NOT have a `PR {N}:` prefix or any stack numbering
- The scope derives from the capability group (`deps`, `models`, `database`,
  `network`, `{f}-domain`, `{f}-infra`, `{f}-presentation`, etc.)

Example: `feat(database): migrate to sembast schema` (not `PR 1: feat: migrate database`).

### 3.7 — Output the full plan

```
## PR Strategy ({N} PRs, ordered by dependencies)

### PR 1 — `build(deps): add dependencies and platform configuration`
**Rationale**: A single atomic project configuration change.
```
chore(deps): replace drift with sembast (+ encrypt, crypto)
chore(platform): remove sqlite3_flutter_libs from linux/macos/windows
```
~{N} lines, estimated review: {N} min

### PR 2 — `feat(models): add shared domain entities`
**Rationale**: Shared models required by the database and feature layers.
```
feat(models): add PatientEntity (@freezed, @JsonSerializable)
feat(models): add ClinicalHistoryEntity + 6 sub-entities
test(models): add serialization tests
```
~{N} lines, estimated review: {N} min
...
```

Also include a visual dependency graph:

```
develop ──── PR1 ── PR2 ── PR3 ── ... ── PR{N}
             (tag)  (tag)  (tag)        (tag)
```

---

## Step 4 — Execute PRs sequentially

For each PR **in dependency order** (level ascending):

### 4.1 — Determine base branch
- PR 1 base = `$BASE`
- PR {N} base = branch of PR {N-1}

### 4.2 — Create branch

```bash
git checkout $BASE_BRANCH
git checkout -b <type>/<short-kebab-name>
```

Branch naming is **type-prefixed** (git-flow compatible), derived from the PR
type, **without stack numbers**:

| PR type | Branch prefix | Example |
|---------|---------------|---------|
| `feat`    | `feature`  | `feature/shared-models` |
| `fix`     | `fix`      | `fix/auth-token-refresh` |
| `chore`   | `chore`    | `chore/ai-tooling` |
| `docs`    | `docs`     | `docs/feature-spec` |
| `ci`      | `ci`       | `ci/workflow-gates` |
| `test`    | `test`     | `test/goldens-cross-platform` |
| `build`   | `build`    | `build/deps-platform` |
| `refactor`| `refactor` | `refactor/database-layer` |

The kebab name derives from the PR subject (e.g. `feat(database): migrate to
sembast schema` → `feature/sembast-schema`). If two PRs would produce the same
branch name, append a short discriminator suffix (e.g. `feature/sembast-schema-2`).
Track every created branch in `$PR_BRANCHES` (in dependency order) — the stack
order is preserved by this array, not by the branch names.

### 4.3 — Clean build artifacts

Before applying any commits, remove generated/build artifacts that should not
be part of the PR diff:

```bash
flutter clean
```

This removes `build/`, `.dart_tool/`, and other artifacts that may have been
generated by previous work or by `flutter pub get` during development.
The next step will re-run `flutter pub get` during validation — no need to
worry about missing dependencies.

### 4.4 — Apply commits atomically (one per planned commit)

**DO NOT** stage all files at once. Apply the commits **one by one** matching
the commit list generated in Step 3.6.

For EACH commit listed in the PR's plan:

1. Identify which files from the PR belong to this specific commit
2. Stage ONLY those files — never use `git add .` or `git add -A`:
   ```bash
   git add <file1> <file2> ...
   ```
3. Verify no unintended files are staged:
   ```bash
   git diff --cached --stat
   ```
4. If the commit includes test + production code, commit them together
   (TDD rule: tests ship with their code).
5. Commit with the exact message from the plan:
   ```bash
   git commit -m "<type>(<scope>): <description>"
   ```

For renames/deletes:

```bash
git add <new_path>
git rm <old_path>
git commit -m "refactor(scope): <description>"
```

**Rules**:
- One `git commit` per planned commit message. Never squash different concerns.
- Never use `git add .` or `git add -A` — only explicit file paths.
- After the last commit of the PR, verify with `git log --oneline -{N}` that
  the commits match the plan.

### 4.5 — Validate

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

> `build_runner` errors MUST NOT be hidden. Do NOT append `|| true` — a failed
> generation produces stale `.g.dart`/`.freezed.dart` and a false-green PR.

**Expected**: 0 analyzer issues, 0 test failures.

### 4.6 — If validation fails → repair loop

| Failure type | Repair agent | Action |
|---|---|---|
| Flutter analyze issues | `app-agent-fix-analyzer-issues` | Load skill, fix every issue file-by-file |
| Test failures | `app-agent-fix-tests` | Load skill, fix each failing test |
| Build runner errors | Manual fix | Fix generated files mismatches |

Steps:
1. Load the corresponding skill
2. Let it fix the issues
3. Commit only the files that the repair agent changed (not `git add -A`):
   ```bash
   git diff --name-only  # see what changed
   git add <changed-file-1> <changed-file-2> ...
   git commit -m "fix(scope): resolve validation issues"
   ```
4. Re-validate (goto 4.4)
5. Max 5 repair iterations per PR. If still failing after 5 → STOP. Escalate to user.

### 4.7 — Mark PR as GREEN

Record that PR {N} passed. Continue to PR {N+1}.

### 4.8 — After ALL PRs executed → Re-validate every branch

```bash
for BRANCH in "${PR_BRANCHES[@]}"; do
  git checkout $BRANCH
  flutter analyze
  flutter test
  echo "=== $BRANCH: $([ $? -eq 0 ] && echo 'PASS' || echo 'FAIL')"
done
```

- Checkout back to the original branch after validation.

### 4.9 — If any branch FAILS in re-validation

1. Identify failing branch(es)
2. For each failing branch:
   a. Checkout that branch
   b. Load repair skill → fix
   c. Commit fix: `git commit -m "fix(scope): post-validation repair"`
   d. Re-validate this branch until GREEN
3. After all failing branches repaired → goto 4.7 (re-validate ALL again)
4. Max **3 global iterations** of this loop. If still failing → STOP. Escalate.

### 4.10 — Show final validation summary

```
╔══════════════════════════════════════════════════════════════════╗
║  PR Pipeline — Validation Summary                               ║
╠══════════════════════════════════════════════════════════════════╣
║  PR 1  feat(database): migrate to sembast schema      ✅  PASS   ║
║        ├─ chore(deps): replace drift with sembast               ║
║        ├─ feat(database): implement sembast...                  ║
║        └─ test(database): add sembast store tests               ║
║                                                                ║
║  PR 2  feat(models): add shared domain entities        ✅  PASS   ║
║        ├─ feat(models): add PatientEntity                       ║
║        └─ test(models): add serialization tests                 ║
║                                                                ║
║  ...                                                             ║
║                                                                ║
║  Result: ALL {N} PRs PASSED ✅                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

The user must see this table clearly before proceeding.

> **Note**: This repository has CI configured in `.github/workflows/ci.yml`
> (Analyze, Test, Test Goldens, Build iOS, Build Android, Gitleaks, Branch
> Source Gate) and `.github/workflows/auto-merge.yml` (dependabot patch/minor).
> PRs to `main` are gated to `release/*` and `hotfix/*` heads only
> (`branch-source-gate`); the branches created by this pipeline target
> `develop`, so their type-prefixed names satisfy the gate.

---

## Step 5 — Publish (always ask first)

### 5.1 — Ask for confirmation

**STOP.** Present the summary table from 4.9 to the user and ask:

> "All branches passed validation. Do you want to push the {N} branches and create the Pull Requests on GitHub?"

Valid affirmative answers: `yes`, `approve`, `publish`, `execute`, `si`, `sí`

If the user says anything else → STOP. The branches exist locally for manual review.

### 5.2 — Push all branches

```bash
for BRANCH in "${PR_BRANCHES[@]}"; do
  git push origin $BRANCH
done
```

### 5.3 — Create GitHub PRs (stacked)

For each branch in `$PR_BRANCHES` (dependency order), create a PR targeting the
previous branch's branch. The PR title MUST follow the PR Title Rules from
Step 3.6.5 (`type(scope): subject`, English, no `PR {N}:` prefix) — it becomes
the squash commit on merge. Add a label mapped from the PR type (labels already
exist in the repo):

| PR type | Label |
|---------|-------|
| `feat`    | `enhancement` |
| `fix`     | `bug` |
| `docs`    | `documentation` |
| `build`   | `dependencies` |
| `ci`      | `github_actions` |
| other     | no label |

**PR 1** (base = `$BASE`):
```bash
gh pr create \
  --base $BASE \
  --head "${PR_BRANCHES[0]}" \
  --title "<type>(<scope>): <subject>" \
  --label "<label>" \
  --body "## Summary
<what this PR does>

## Why
<context / motivation / ticket reference>

## Changes
- <file/area>: <description>

## Testing
- [ ] flutter analyze
- [ ] flutter test
- [ ] <integration/BDD specifics>

## Stack
| PR | Branch | Title |
|----|--------|-------|
| 1 | ${PR_BRANCHES[0]} | <type>(<scope>): <subject> |
| 2 | ${PR_BRANCHES[1]} | <type>(<scope>): <subject> |
| ... | ... | ... |"
```

**PR {N}** (base = branch of PR {N-1} = `"${PR_BRANCHES[N-1]}"`):
```bash
gh pr create \
  --base "${PR_BRANCHES[N-1]}" \
  --head "${PR_BRANCHES[N]}" \
  --title "<type>(<scope>): <subject>" \
  --label "<label>" \
  --draft \
  --body "## Summary
<what this PR does>

## Why
<context / motivation / ticket reference>

## Changes
- <file/area>: <description>

## Testing
- [ ] flutter analyze
- [ ] flutter test
- [ ] <integration/BDD specifics>

## Stack
| PR | Branch | Title |
|----|--------|-------|
| 1 | ${PR_BRANCHES[0]} | <type>(<scope>): <subject> |
| 2 | ${PR_BRANCHES[1]} | <type>(<scope>): <subject> |
| ... | ... | ... |"
```

Use `--draft` for all PRs except PR 1 (since they depend on the previous PR being merged).

### 5.4 — Return PR URLs table

```
| PR | Branch | URL | Status |
|----|--------|-----|--------|
| 1  | feature/sembast-schema     | https://... | Open |
| 2  | feature/shared-models      | https://... | Draft |
| 3  | build/deps-platform        | https://... | Draft |
| ... | ... | ... | ... |
```

---

## Edge Cases

| Situation | Handling |
|-----------|----------|
| No changes between HEAD and $BASE | STOP. Inform user there are no changes to PR. |
| Only 1 group detected | Create a single PR, no split needed. Still run validation. |
| Only docs/MD changes | Single `docs:` PR. Skip heavy build_runner / test steps. |
| Feature has no `lib/features/{f}/` but has test changes | Classify as `tests` group, create standalone PR. |
| pubspec.lock changed without pubspec.yaml | Include with closest `deps` group. |
| Binary/generated files (.g.dart, .freezed.dart) | Include in same PR as their source files. Never separate. |
| Merge conflicts during branch creation | STOP. Inform user. Ask them to resolve manually. |
| PR title longer than 72 chars | Truncate the subject to ≤72 chars; move the detail into the body (PR Title Rules, Step 3.6.5). |
| PR targets `main` instead of `develop` | Remember `branch-source-gate`: only `release/*` and `hotfix/*` heads may merge to `main`. Re-target the PR to `develop`. |
| Two capabilities produce the same branch name | Append a discriminator suffix to the later branch (e.g. `feature/sembast-schema-2`). |
