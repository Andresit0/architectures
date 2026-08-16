# Required Checks (source of truth)

Branch protection on `develop` and `main` requires these status checks. The
names below MUST match the job `name:` values in `.github/workflows/ci.yml`
exactly — a check with a different name, marked optional, or absent invalidates
the "protected PR" guarantee.

## `develop` and `main`

| Check | Job | Responsibility |
|---|---|---|
| `Analyze` | `analyze` | `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test integration_test`, `flutter analyze` (zero issues). |
| `Test` | `test` | Unit/widget/architecture/BDD no-golden (`flutter test --coverage --exclude-tags golden`) + Codecov upload. |
| `Test Goldens` | `test-goldens` | Goldens on Linux with `--tags golden` (deterministic). |
| `Build Android` | `build-android` | `flutter build apk --debug` (compilation gate). |
| `Build iOS` | `build-ios` | `flutter build ios --no-codesign` (compilation gate). |
| `Gitleaks` | `gitleaks` | Full-history secret scan (`fetch-depth: 0`), zero secrets. |

## `main` only

| Check | Job | Responsibility |
|---|---|---|
| `Branch Source Gate` | `branch-source-gate` | Rejects PR heads other than `release/*` or `hotfix/*`. |

## Device Integration (D6 — gated, not yet a required check)

`Integration` (`integration` job, `macos-latest`) runs every
`integration_test/*_test.dart` on a device and fails hard on any failure. It is
**gated behind the repository variable `RUN_DEVICE_INTEGRATION=true`** because
the app uses `flutter_secure_storage` keychain groups, which require Apple code
signing that GitHub-hosted macOS runners cannot provide.

- Until a signing-capable/controlled runner is provisioned, the job is skipped
  and is **NOT** a required check — this is the documented D6 exception for a
  personal account (GIT_FLOW.md §4.4, §10.2).
- Once the variable is set and the job is green on a controlled runner, add
  `Integration` to branch protection as a required check and update this file.

## Coverage

`codecov.yml` enforces project and patch coverage against the agreed
threshold (`target: auto`, `threshold: 1%`). `codecov/patch` is a required
status on every PR; a coverage regression blocks the merge. The Codecov upload
itself is tolerant to a service outage (`fail_ci_if_error: false`) so an
external failure never fails the job — the internal coverage status remains
the authoritative gate.

## Change management

- Any rename of a job `name:` MUST be applied to this file and to the branch
  protection settings in the same change (D7: required checks must match real
  CI).
- GitHub Actions are pinned to immutable SHAs (see `ci.yml`); Dependabot keeps
  them updated.
