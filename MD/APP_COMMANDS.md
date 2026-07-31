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

# 5. Unit / widget tests
flutter test

# 6. Run on macOS
flutter run -d mac --dart-define-from-file=.env
```

### Integration tests (need a connected device/emulator)

```bash
flutter test integration_test/[feature_name]_integration_test.dart -d <device-id> --dart-define-from-file=.env
```

Integration tests use fake repositories (`_FakeAuthRepository`, `_FakeTokenStore`, `_FakeCredentialStore`, `_FakeTokenVerifier`) — no live HTTP calls needed.