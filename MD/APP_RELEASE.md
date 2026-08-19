# APP_RELEASE — Release procedure (runbook)

How to ship a new release (`release/*` → `main` → tag → back-merge) in this
repository. Follows the Git Flow documented in `README.md` → Git Flow and the
branch-protection policy in `.github/REQUIRED_CHECKS.md`.

## Versioning

- The version lives in a single source of truth: `pubspec.yaml` (`version:`).
  Android (`flutter.versionName`/`flutter.versionCode` in
  `android/app/build.gradle.kts`) and iOS (`$(FLUTTER_BUILD_NAME)` /
  `$(FLUTTER_BUILD_NUMBER)` in `ios/Runner/Info.plist` and the Xcode project)
  read it from there — do NOT edit platform files.
- SemVer: MAJOR = breaking changes, MINOR = new compatible functionality,
  PATCH = compatible fixes. A release commit is `chore(release): bump version
  to X.Y.Z+N` and the tag is an annotated `vX.Y.Z`.

## Preflight

Verify, do not assume:

```bash
# Required checks on main (must match .github/REQUIRED_CHECKS.md)
gh api repos/<owner>/<repo>/branches/main/protection \
  --jq '{checks:.required_status_checks.contexts,strict:.required_status_checks.strict}'
gh pr list --state open          # expected: empty (freeze window)
gh run list --branch develop --limit 1   # expected: success at develop HEAD
```

Note: `main` requires 2 approving reviews in config with `enforce_admins: true`.
On a personal account GitHub blocks self-approval, so the operational gate is
the required-check matrix plus an explicit human merge after CI is green. If a
temporary bypass is needed, lower the required approvals to 0, merge, and
restore — and record it in the PR thread.

## Steps

1. **Cut point** — freeze `develop`:

   ```bash
   git checkout develop && git pull --ff-only origin develop
   git log --oneline main..develop   # these commits are the release content
   ```

2. **Verify the real version** in the working tree, `main` and `develop`.

3. **Create the release branch**:

   ```bash
   git checkout -b release/vX.Y.Z develop
   ```

4. **Release content** (one commit per concern):

   - Bump `version:` in `pubspec.yaml` and run `flutter pub get`. `git status`
     must show ONLY `pubspec.yaml`; if `pubspec.lock` changed, revert it
     (never edit it by hand). Commit: `chore(release): bump version to X.Y.Z+N`.
   - Update `CHANGELOG.md` (Keep a Changelog) with the release section and
     commit: `docs(changelog): add vX.Y.Z`.

5. **Local validation**:

   ```bash
   dart format --output=none --set-exit-if-changed lib test integration_test
   flutter analyze
   flutter test --exclude-tags golden
   flutter test --tags golden
   ```

   Push: `git push origin release/vX.Y.Z`.

6. **PR to `main`** — title `release: vX.Y.Z` (Conventional Commits `release`
   type; the PR body becomes the commit body on `main` because the repo
   squash-merges with `squash_merge_commit_title: PR_TITLE` /
   `squash_merge_commit_message: PR_BODY`). The `Branch Source Gate` passes
   (head matches `release/*`).

7. **Wait for the 7 checks**: Analyze, Test, Test Goldens, Build iOS,
   Build Android, Gitleaks, Branch Source Gate. The `Integration` job is
   gated by the repository variable `RUN_DEVICE_INTEGRATION` (documented D6
   exception) and is NOT a required check — do not treat it as missing.

8. **Merge (squash)** after the checks are green. `release/vX.Y.Z` is
   auto-deleted after the merge (`delete_branch_on_merge`).

9. **Validate `main` before tagging**:

   ```bash
   git checkout main && git pull --ff-only origin main
   git show --stat --oneline HEAD      # the squash commit of the release
   git show HEAD:pubspec.yaml | grep '^version:'   # X.Y.Z+N
   ```

   Wait for the post-merge CI run on `main` (push to `main` triggers CI; the
   tag push does NOT).

10. **Annotated tag**:

    ```bash
    git tag -a vX.Y.Z -m "Release vX.Y.Z" && git push origin vX.Y.Z
    git show vX.Y.Z:pubspec.yaml | grep '^version:'   # X.Y.Z+N
    ```

11. **Back-merge to `develop` immediately** (never leave `main` ahead of
    `develop`): create a fresh branch from `origin/develop`, merge `origin/main`
    (only the version bump + changelog arrive — the rest is already there),
    and open a PR to `develop` titled `chore(release): back-merge vX.Y.Z`.

    ```bash
    git checkout -b chore/back-merge-vX.Y.Z origin/develop
    git merge origin/main
    ```

12. **Verify `develop`**: `git show origin/develop:pubspec.yaml | grep '^version:'`.

13. **GitHub Release** — notes-only source release (no signing/artifacts
    configured): `gh release create vX.Y.Z --title "vX.Y.Z" --notes-file <file> --target main`.

14. **Post-release** — documentation updates (`MD/APP_RELEASE.md`, README,
    AGENTS.md) travel on a `docs/*` branch to `develop`; they reach `main` on
    the NEXT release. Unfreeze `develop` after the back-merge is merged.

15. **Web deployment (automatic)** — pushing `main` triggers
    `.github/workflows/deploy-web.yml`, which builds the Flutter Web demo and
    publishes it to GitHub Pages (`https://andresit0.github.io/flutter-clean-architecture-sdd/`).
    No manual step: the workflow runs on `push` to `main` and represents the
    last officially released version. Verify the demo after each release
    (login with any credentials → Clinical History → Lab Results → Chart).

## Rollback

If the release breaks on `main`: a revert is not enough (the tag is immutable);
ship a `hotfix/*` branch from `main`, bump the PATCH version, and follow the
same gate. See `docs/release-rollback-runbook.md`.