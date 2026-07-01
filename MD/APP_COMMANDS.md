### Required commands (in order after any change)

> All commands must be run from the project root

```bash
# 1. Install / sync dependencies
flutter pub get

# 2. Regenerate Riverpod code (run whenever @riverpod files change)
dart run build_runner build --delete-conflicting-outputs

# 3. Analyze
flutter analyze

# 4. Unit / widget tests
flutter test

# 5. Run on macOS
flutter run -d mac --dart-define-from-file=.env
```

### Integration tests (need a connected device/emulator)

```bash
flutter test integration_test/[feature_name]_integration_test.dart -d <device-id> --dart-define-from-file=.env
```

Integration tests use `_FakeUserRepository` — no live HTTP calls needed.