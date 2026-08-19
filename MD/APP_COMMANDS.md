### Required commands (in order after any change)

> All commands must be run from the project root

```bash
# 1. Install / sync dependencies
flutter pub get

# 2. Regenerate localization code (run whenever .arb files change)
flutter gen-l10n

# 3. Regenerate Riverpod code (run whenever @riverpod files change)
dart run build_runner build --delete-conflicting-outputs

# 4. Check formatting (CI "Enforce Dart formatting" runs the same scope — analyze does NOT catch it)
dart format --output=none --set-exit-if-changed lib test integration_test

# 5. Analyze
flutter analyze

# 6. Unit / widget tests (goldens excluded for a fast local loop; CI Test job uses the same flag)
flutter test --exclude-tags golden

# 6b. Golden tests (tagged @Tags(['golden']) — declared in dart_test.yaml, no "A tag was used" warning)
# CI runs them on Linux with `flutter test --tags golden`. Regenerate fixtures with --update-goldens.
flutter test --tags golden
flutter test --tags golden --update-goldens

# 7. Run on macOS
flutter run -d mac --dart-define-from-file=.env

# 8. Build the web demo (GitHub Pages). Mirrors ci.yml `build-web` and deploy-web.yml.
flutter build web --release --base-href /flutter-clean-architecture-sdd/ \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=API_HOST=tudesarrollador.com \
  --dart-define=API_USE_HTTPS=true
```

### Dependency upgrade procedure

Use this sequence for any dependency bump (dependabot or manual PR):

```bash
# 1. Edit pubspec.yaml constraint(s) (never the lock by hand)
# 2. Regenerate the lock — this fixes spurious SDK-pinned bumps (intl/test):
flutter pub get
# 3. If codegen toolchain changed (freezed/json_serializable/@riverpod):
dart run build_runner build --delete-conflicting-outputs
# 4. Regenerate localization if .arb changed:
flutter gen-l10n
# 5. Full battery (see below): format, analyze, tests, goldens, integration, builds
```

Caveats:

- **Never force-bump SDK-pinned packages.** Flutter 3.44.0 pins `intl` (0.20.2),
  `test_api` (0.7.11), `matcher`, `meta`, `vector_math` to exact versions. If
  `flutter pub get` fails on `intl`/`test`, revert those constraints — do not
  resolve by hand.
- **Never adopt prerelease-major codegen** (`freezed 4.0.0-dev.x`) in
  production — deferred until stable (issue #62). The analyzer-13 toolchain has
  no stable freezed.
- **Android platform**: if a plugin requires a higher SDK than the Flutter
  default, set `compileSdk`/`minSdk` explicitly in
  `android/app/build.gradle.kts` (e.g. `flutter_secure_storage 11` →
  `compileSdk 37`).
- Dependabot reads `.github/dependabot.yml` from the **default branch (`main`)**;
  its ignore rules (intl/test/freezed) are active since release v1.1.0 (issue #63 resolved).
- Regenerated `.g.dart`/`.freezed.dart` files must be committed with their
  source (Rule 29).

### Integration tests (need a connected device/emulator)

```bash
flutter test integration_test/[feature_name]_integration_test.dart -d <device-id> --dart-define-from-file=.env
```

Integration tests use fake repositories (`_FakeAuthRepository`, `_FakeTokenStore`, `_FakeLabResultsRepository` and failure-variant repositories like `_FakeNetworkErrorRepository`, `_FakeOfflineWithCachedDataRepository`) — no live HTTP calls needed. lab_results integration tests (`integration_test/lab_results_integration_test.dart`) inject the fake repository via Riverpod overrides in `app.main(overrides: [...])`.

---

### Environment variables

All variables are passed via `--dart-define` (or `--dart-define-from-file=.env`) at run/build time. Never hardcode them in code — use `String.fromEnvironment` with a safe default.

| Variable | Default | Purpose |
|---|---|---|
| `ENVIRONMENT` | `dev` | Selects `AppEnvironment` variant: `dev` / `staging` / `production` |
| `API_HOST` | `localhost` | Overrides the API host (used by `DevEnvironment`). Android emulator: `10.0.2.2` |
| `API_USE_HTTPS` | `false` | Force HTTPS for the API base URI even on a non-443 port (e.g. the web demo at `https://tudesarrollador.com:5111`). Used by `AppEnvironment.useHttps` → `AppUris` and `connectivity_providers` |
| `PINNED_CERT_1`, `PINNED_CERT_2` | — (unset) | SHA-256 hashes for certificate pinning (staging/production) |
