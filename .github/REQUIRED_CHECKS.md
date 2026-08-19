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
| `Build Web` | `build-web` | `flutter build web --release --base-href /flutter-clean-architecture-sdd/` with the demo dart-defines (mirrors `deploy-web.yml`) — compilation gate for the GitHub Pages artifact. |
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
  personal account (see README.md → Git Flow).
- Once the variable is set and the job is green on a controlled runner, add
  `Integration` to branch protection as a required check and update this file.

## Coverage

`codecov.yml` enforces project and patch coverage against the agreed
threshold (`target: auto`, `threshold: 1%`). `codecov/patch` is currently an
INFORMATIVE status, not a required check: it is NOT present in the branch
protection `required_status_checks.contexts` for `develop` or `main`, and the
Codecov upload is tolerant to failure (`fail_ci_if_error: false`), so a
coverage regression or a service outage never blocks the merge. This is an
intentional bootstrap state to keep stacked-PR pipelines unblocked.

To make coverage an authoritative gate (recommended once the matrix is
stable), add `codecov/patch` to branch protection as a required check AND
update this file in the SAME change (D7: required checks must match real CI).

## Change management

- Any rename of a job `name:` MUST be applied to this file and to the branch
  protection settings in the same change (D7: required checks must match real
  CI).
- GitHub Actions are pinned to immutable SHAs (see `ci.yml`); Dependabot keeps
  them updated.

## Dependency management

The Flutter SDK pinned in CI (`3.44.0`) pins several transitive packages to
**exact** versions. They must NOT be force-bumped — a constraint that excludes
the SDK pin makes `flutter pub get` fail:

| Package | Pin (Flutter 3.44.0) | Owned by |
|---|---|---|
| `intl` | `0.20.2` (exact) | `flutter_localizations` |
| `test_api` | `0.7.11` (exact) | `flutter_test` |
| `matcher` | `0.12.19` (exact) | `flutter_test` |
| `meta` | `1.18.0` (exact) | `flutter_test` |
| `vector_math` | `2.2.0` (exact) | `flutter_test` |

Policies:

- Dependabot ignores `intl` and `test` (see `.github/dependabot.yml`); it also
  blocks `freezed` semver-major until freezed 4.0.0 stable ships (issue #62) —
  the analyzer-13 toolchain has no stable freezed.
- Dependabot reads `.github/dependabot.yml` from the **default branch**
  (`main`); config changes land on `develop` but only take effect after the
  next release promotes them to `main` (issue #63). Until then, regenerate
  dependabot PRs are closed manually.
- Any dependency PR must keep `flutter pub get` green on Flutter 3.44.0 and
  pass the full required-check matrix. Never edit `pubspec.lock` by hand —
  regenerate with `flutter pub get`.
- Android `compileSdk`/`minSdk` are set explicitly in
  `android/app/build.gradle.kts` when a plugin requires more than the Flutter
  default (e.g. `flutter_secure_storage 11` requires `compileSdk 37` vs the
  Flutter 3.44 default of 36).
