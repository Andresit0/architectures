### Barrel pattern

Every barrelled folder has **two files**:

| File | Role |
|---|---|
| `_[name].lib.dart` | Root library: centralises all `import`s; declares `part` for each public file |
| `_[name].dart` | Facade: `part of '_[name].lib.dart'`; exposes `Custom[Name]` with `static final` members |

**Example barrels:**
- `shared/models/` → `_models.lib.dart` barrel
- `shared/functions/` → imports individually (`offline_first_repository.dart` directly)
- `shared/exceptions/` → Exception classes (ApiException, NoConnectionException, etc.)
- `features/auth/di/` → feature-specific providers migrated from `presentation/providers/` — uses `@riverpod` code-gen
- `app/di/` → `_providers.lib.dart` barrel exporting providers directly (composition root: `httpServiceProvider`, `tokenStoreProvider`, `appDatabaseProvider`, `internetServiceProvider`, `clinicalHistoryStoreProvider`, `patientInfoStoreProvider`, `passwordHasherProvider`, `connectivityCheckerProvider`, `tokenVerifierProvider`, `credentialStoreProvider`, `jwtWrapperProvider`, `environmentProvider`)
- `shared/` → mock data lives in per-feature FakeDatasource files (no CustomJsons barrel)
- `core/database/` → accessed via Riverpod providers (`ref.watch(appDatabaseProvider)`)
- `core/network/interceptors/` → used internally by `DioWrapper`; not accessed from features

**Rules:**
- `*.g.dart` files are **never** added as `part` — they are owned by their source.
- Files starting with `_` are never added as `part` of another barrel.
- Never use `export` to re-export your own files from a barrel; always use `part of`. Exception: `_exceptions.lib.dart` uses `export` for its standalone exception files (they are not `part of` the lib). If a barrel needs to re-export an external package type, `export` is also the correct choice.
- `static const` inside part files must be converted to `final` (instance members) so the facade can hold `static final` instances.

**Exception — folders with `@riverpod`-annotated files:**

Files annotated with `@riverpod` declare their own `part '....g.dart';` directive. A Dart `part` file cannot itself declare `part` directives, so these files **cannot** be made `part` of the lib barrel. Instead, use `import` for each provider file and only make the facade a `part`.

Do **not** use the standard `barrel_lib` / `barrel` skill flow (which converts public files to `part`) on folders whose public files contain `@riverpod` annotations.

Use skills `barrel`, `barrel_lib`, `barrel_file` when creating or updating barrels.

> For the current `lib` file tree see **MD/APP_TREE.md**.