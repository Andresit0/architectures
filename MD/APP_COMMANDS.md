### Required commands (in order after any change)

> All commands must be run from the project root

```bash
# 1. Install / sync dependencies
flutter pub get

# 2. Regenerate localization code (run whenever .arb files change)
flutter gen-l10n

# 3. Regenerate Riverpod code (run whenever @riverpod files change)
dart run build_runner build --delete-conflicting-outputs

# 4. Analyze
flutter analyze

# 5. Unit / widget tests (goldens excluded for a fast local loop; CI Test job uses the same flag)
flutter test --exclude-tags golden

# 5b. Golden tests (tagged @Tags(['golden']) — declared in dart_test.yaml, no "A tag was used" warning)
# CI runs them on Linux with `flutter test --tags golden`. Regenerate fixtures with --update-goldens.
flutter test --tags golden
flutter test --tags golden --update-goldens

# 6. Run on macOS
flutter run -d mac --dart-define-from-file=.env
```

### Integration tests (need a connected device/emulator)

```bash
flutter test integration_test/[feature_name]_integration_test.dart -d <device-id> --dart-define-from-file=.env
```

Integration tests use fake repositories (`_FakeAuthRepository`, `_FakeTokenStore` and failure-variant repositories like `_FakeNetworkErrorRepository`, `_FakeOfflineWithCachedDataRepository`) — no live HTTP calls needed.

---

### Environment variables

All variables are passed via `--dart-define` (or `--dart-define-from-file=.env`) at run/build time. Never hardcode them in code — use `String.fromEnvironment` with a safe default.

| Variable | Default | Purpose |
|---|---|---|
| `ENVIRONMENT` | `dev` | Selects `AppEnvironment` variant: `dev` / `staging` / `production` |
| `API_HOST` | `localhost` | Overrides the API host (used by `DevEnvironment`). Android emulator: `10.0.2.2` |
| `PINNED_CERT_1`, `PINNED_CERT_2` | — (unset) | SHA-256 hashes for certificate pinning (staging/production) |
