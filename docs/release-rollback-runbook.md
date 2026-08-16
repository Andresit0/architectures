# Release & Rollback Runbook

## Release process

1. All feature/fix/refactor PRs merged into `develop` (required checks green).
2. Run the full validation on the release candidate:
   ```bash
   flutter clean
   flutter pub get
   dart format --output=none --set-exit-if-changed lib test integration_test
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   flutter test --exclude-tags golden
   flutter test --tags golden
   flutter build apk --debug
   flutter build ios --no-codesign
   ```
   If a device/controlled runner is available (D6), also run
   `integration_test/*_test.dart` on the device.
3. Create `release/X.Y.Z` from `develop`.
4. Open a PR from `release/X.Y.Z` to `main` only. The Branch Source Gate
   (`branch-source-gate`) rejects any non-`release/*` / `hotfix/*` head.
5. Wait for CI + required approvals (2 reviewers incl. a Code Owner for
   sensitive changes).
6. Merge; the release pipeline tags `vX.Y.Z` and deploys from the merged
   commit (never from a local worktree).
7. Back-merge `release/X.Y.Z` to `develop`.

## Code rollback

- PR fails before merge → repair the branch, do not touch `develop`.
- Fails after merge to `develop` → open `fix/*` from `develop`, never rewrite
  history.
- Fails in production → open `hotfix/*` from `main`, or revert the squash
  commit with a `revert(...)` commit + PR. Document the affected SHA and
  whether a back-merge to `develop` is required.

## Local data migration / rollback

The local Sembast database is a server-derived cache. Policy (D3):
**invalidate and rehydrate** on codec/schema incompatibility:

1. Detect incompatibility (codec mismatch / unreadable format).
2. Delete only the incompatible cache (`resetDatabase()` removes the DB file
   AND the encryption key). Do NOT wipe a restorable session.
3. Rehydrate online via `RestoreSessionUseCase`; clinical history refills via
   the online-first load (remote → write-through cache).

Escalation criteria:

- If the cache ever carries data with clinical/regulatory value that cannot be
  re-fetched → switch to **data-preserving migration** (version schema/codec,
  prove upgrade from a fixture DB, provide rollback).
- If integrity cannot be guaranteed → **block the upgrade** and stop the
  deployment instead of silently wiping.

Downgrade:

- Reinstalling a previous binary over new-format data requires a **downgrade
  test over a fixture DB** before release; the new AES codec is not readable by
  the old binary.

## Operational rules

- `resetDatabase()` is NOT a generic session-recovery tool. Logout clears the
  session; reset-account is the only full-wipe flow.
- Never log tokens, credentials or clinical content.
- Squash merge policy is unified (`--squash`, `squash_merge_commit_title:
  PR_TITLE`); do not mix squash and merge commits.
- Required checks: Analyze, Test, Test Goldens, Build Android, Build iOS,
  Gitleaks (+ Branch Source Gate on `main`). `Integration` becomes required
  once the D6 controlled runner is provisioned.
