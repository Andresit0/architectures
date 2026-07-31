# 1. Launch the app

## 1.1 Prerequisites

[Opencode:](https://opencode.ai/) is a popular, open-source AI-powered coding assistant and agent built specifically for software developers. It lets you interact with advanced AI models directly from your terminal, desktop app, or code editor to write, refactor, debug, and plan code in your actual repositories.

```bash
$ brew install anomalyco/tap/opencode
```

[Engram:](https://github.com/Gentleman-Programming/engram) It gives Pi persistent project memory, compaction recovery, and shared memory with other MCP agents through the same local-or-cloud Engram brain

```bash
$ brew install gentleman-programming/tap/engram
$ engram setup opencode
```

[Dart MCP:](https://docs.flutter.dev/ai/mcp-server)

```
{
  "mcpServers": {
    "dart-mcp-server": {
      "command": "dart",
      "args": [
        "mcp-server"
      ],
      "env": {}
    }
  }
}
```

[/super-commit`:](.opencode/commands/super-commit.md)

This command was used throughout the project, but it is not automatically executed by the `orchestrator`. Therefore, it is recommended to run this command after implementing a feature to ensure that all related changes are properly documented in Git.

Note: tested on macOS with:

```bash
Flutter 3.44.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 559ffa3f75 (4 weeks ago) • 2026-05-15 14:13:13 -0700
Engine • hash fcf463a2242790d1fdcd9d044f533080f5022e18 (revision 4c525dac5e) (26 days ago) •
2026-05-15 19:00:04.000Z
Tools • Dart 3.12.0 • DevTools 2.57.0
```

## 1.2 Install dependencies and generate code

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

> `flutter gen-l10n` regenerates the `.dart` localization files from `.arb` sources.
> It is required after modifying `app_en.arb` or `app_es.arb`, or after cloning the project.
> `dart run build_runner` regenerates the `.g.dart` files required by Riverpod.
> It is only needed after modifying providers or notifiers annotated with `@riverpod`.

## 1.3 Run the app

```bash
flutter run -d mac --dart-define-from-file=.env
```

## 1.4 Unit tests (`test/`)

The project includes **unit tests** covering:
- Entities, use cases, mappers, repositories, datasources
- Providers, notifiers, states
- Functions, interceptors, exceptions, configs, jsons

### Run all tests

```bash
flutter test
```

### Run tests with coverage report

```bash
flutter test --coverage
```

### Run a specific test file

```bash
flutter test test/core/database/app_database_test.dart
```

### Run tests by pattern

```bash
# Run all auth-related tests
flutter test --name "auth"

# Run all encounter-related tests
flutter test --name "encounter"
```

### Verify code quality

```bash
# Run dart analyze (required before any PR)
dart analyze

# Fix automatically fixable issues
dart fix --apply
```

> **Note:** Tests use `mocktail` for mocking. No real HTTP calls are made — dependencies are mocked via Riverpod overrides or direct injection.

---

## 1.5 Integration tests (`integration_test/`)

Integration tests require a connected device (physical, emulator, or simulator).

> **Important:** Due to macOS test runner state, run integration tests **individually**, not together:

```bash
# List available devices
flutter devices

# Run auth integration tests
flutter test integration_test/auth_integration_test.dart -d macos
```

> Note: Running all integration tests together (`flutter test integration_test/`) may cause a "Unable to start the app on the device" error. Execute them separately as shown above.
> Integration tests use fake repositories (`_FakeAuthRepository`, `_FakeTokenStore`, `_FakeCredentialStore`, `_FakeTokenVerifier`) injected via Riverpod overrides — **no real HTTP calls are made** to the backend.

---

# 2. Mandatory team rules

## 2.1 Code rules (non-negotiable)

1. **Every new external package requires its `<name>_wrapper.dart`** with `I<Name>` interface + concrete implementation in `lib/core/services/<domain>/`. Never import an external package directly in a feature.

2. **Access to shared services from features:** always via `ref.watch/read(ProviderName)` from `_providers.lib.dart`. Never via static functions directly.

3. **`_providers.lib.dart`** is the composition root barrel in `app/di/`. Do not add business logic in providers.

4. **Every new feature follows exactly the same structure:**
   ```
   features/<name>/domain/datasources/i_<name>_datasource.dart
   features/<name>/domain/entities/<name>_entity.dart   (@freezed)
   features/<name>/domain/repositories/i_<name>_repository.dart
   features/<name>/domain/usecases/<action>_usecase.dart
   features/<name>/infrastructure/datasources/<name>_datasource_impl.dart
   features/<name>/infrastructure/mappers/<name>_mapper.dart
   features/<name>/infrastructure/repositories/<name>_repository_impl.dart
   features/<name>/presentation/notifiers/<name>_notifier.dart + _state.dart (@freezed)
   features/<name>/di/<name>_provider.dart (@riverpod)
   features/<name>/presentation/screens/<name>_screen.dart
   features/<name>/presentation/widgets/...
   ```

5. **Repositories never throw exceptions.** All exceptions caught in `guard()` in `shared/error/` → `Result<T>` (Success / Failure). If a new exception type is needed, add in `shared/exceptions/`.

6. **`.g.dart` and `.freezed.dart` files are never edited manually.** Always regenerate with `dart run build_runner build --delete-conflicting-outputs`.

7. **`GoRouter` is accessed via `goRouterProvider` from `app/di/router/router_provider.dart`.** In `main.dart`, use `ref.watch(goRouterProvider)` to get the instance. In features, use `ref.read(goRouterProvider).go(...)`.

8. **New routes** are added in `app_router.dart` (`appRoutes()`) with the route name added to `AppRoute` enum in `app_route.dart`.

9. **Use `@freezed` for all entities and states.** Do not create mutable data classes in the domain.

10. **Apply the `class_to_solid`** skill (in features) or **`class_to_solid_min`** (in `core/services/`) when creating any new class. The skills document the mandatory correct pattern.

## 2.2 Configuration and environment rules

11. **Never hardcode URLs or credentials** in code. Use `String.fromEnvironment` with a safe default value. Document each variable in `MD/APP_COMMANDS.md`.

12. **For Android emulator development:** use `--dart-define=API_HOST=10.0.2.2` to override the API host. Endpoints are defined in `lib/core/network/api_endpoints.dart`.

13. **Testing with mock data:** Use Riverpod provider overrides in tests to replace the real implementation with a `FakeDatasource` class. The provider always returns `DatasourceImpl` directly — no `useMock` environment flag. Mock data uses typed entity constructors, not raw JSON maps.

14. **Logger removed:** `LoggerWrapper` and `loggerProvider` have been removed from the project. Use `debugPrint` directly for temporary debug output (remove before PR). No structured logging provider is currently wired.

## 2.3 Barrel and organization rules

15. **When adding a file to a folder with barrel** (`_xxx.lib.dart` / `_xxx.dart`):
    - Add `part '<new_file>.dart';` in `_xxx.lib.dart`.
    - Add `part of '_xxx.lib.dart';` at the start of the new file.
    - If the file exposes a public class, add the corresponding `static` in `_xxx.dart`.

16. **Files inside a barrel are `part` of the library hub** (`_xxx.lib.dart`). They must not have their own `import`s; all imports go in `_xxx.lib.dart`.

17. **Do not create cross imports between features.** If `feature_A` needs a type from `feature_B`, that type must move to `shared/` (domain abstractions) or `core/` (infrastructure).

## 2.4 Git rules

18. **Before any git command**, write the exact command and ask for confirmation from user/tech lead. (See `AGENTS.md`.)

19. **Do not commit `.g.dart` files if they don't match source code.** Always regenerate before commit with `build_runner`.

20. **`.env` or configuration files with secrets never go to the repository.** Use `.gitignore` and CI/CD server variables.

## 2.5 Quality rules

21. **`dart analyze` must pass without warnings** before any PR. Configure in CI.

22. **Every new use case must have a unit test** covering the happy path and at least one Failure case.

23. **Notifiers do not contain business logic.** They only call use cases and update state. Logic goes in use cases and repositories.

24. **Screens do not contain logic.** They only call notifier methods and read state. Complex presentation logic goes in separate widgets or in the notifier.

25. **Use `const` on all widgets that do not depend on state.** Mandatory for performance in lists and frequent rebuilds.

---

# 3. Git Flow

## Objective

This project uses a Git Flow–based strategy to maintain stability, traceability, and controlled deployments.

```txt
                                   PRODUCTION
                                        │
                                        ▼
main ─────────────────────────────────────●─────────── TAG v1.0.0
                                          ▲
                                          │
                               merge release/1.0.0
                                          │

develop ─────●────────────────────●────────●──────────
             ▲                    ▲

feature/auth ├────●────●────●─────┘

feature/clinical-history
                  ├────●────●────●────────┘

feature/* → develop → release/* → main
```

## 1. `main` Branch

### Purpose

Contains only production-ready code.

### Rules

* No direct pushes
* Merges allowed only from `release/*` and `hotfix/*`
* Pull Request required
* Branch protection enabled
* Versioning managed through tags

---

## 2. `develop` Branch

### Purpose

Continuous integration branch for the next release.

### Rules

* No direct commits
* All features must be merged through Pull Requests

---

## 3. `feature/*` Branches

Examples:

```txt
feature/auth
feature/dashboard
feature/profile
feature/invoice-generation
```

Rules:

* Create from `develop`
* Merge back into `develop`
* Delete after merge

---

## 4. `release/*` Branches

Example:

```txt
release/1.0.0
```

Usage:

* QA testing
* Final bug fixes
* Pre-deployment adjustments

Flow:

```txt
release → main
release → develop
```

---

## 5. `hotfix/*` Branches

Example:

```txt
hotfix/login-crash
```

Flow:

```txt
main
↓
hotfix/*
↓
main
↓
develop
```
---
