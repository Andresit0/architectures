### Barrel pattern

Every barrelled folder has **two files**:

| File | Role |
|---|---|
| `_[name].lib.dart` | Root library: centralises all `import`s; declares `part` for each public file |
| `_[name].dart` | Facade: `part of '_[name].lib.dart'`; exposes `Custom[Name]` with `static final` members |

**Example barrels:**
- `shared/configs/` → `CustomConfigs.appColors`, `CustomConfigs.uries`, `CustomConfigs.vars`, `CustomConfigs.theme`, `CustomConfigs.routes`
- `shared/functions/` → `CustomFunction.pathProvider`, `CustomFunction.sharePlus`, `CustomFunction.internetService`, `CustomFunction.tokenService`, `CustomFunction.dio`, `CustomFunction.logger`, `CustomFunction.fpdart`, `CustomFunction.failure`, `CustomFunction.drift`
- `shared/interceptors/` → `CustomInterceptors.auth(readToken)` (returns `AuthInterceptor`); also exposes `AuthInterceptor` class
- `shared/exceptions/` → `CustomExceptions` (typedefs + factory methods); re-exports `Either`, `Left`, `Right` from fpdart
- `shared/providers/` → `CustomProviders.dio`, `CustomProviders.token`, `CustomProviders.sharePlus`, `CustomProviders.user`, `CustomProviders.goRouter`
- `shared/jsons/` → `CustomJsons.userJson`

**Rules:**
- `*.g.dart` files are **never** added as `part` — they are owned by their source.
- Files starting with `_` are never added as `part` of another barrel.
- Never use `export` to re-export your own files from a barrel; always use `part of`. Exception: `_exceptions.lib.dart` uses `export 'package:fpdart/fpdart.dart' show Either, Left, Right;` to re-export external package types — this is the only allowed `export` in the project.
- `static const` inside part files must be converted to `final` (instance members) so the facade can hold `static final` instances.

**Exception — `shared/providers/` (and any folder with `@riverpod`-annotated files):**

Files annotated with `@riverpod` declare their own `part '....g.dart';` directive. A Dart `part` file cannot itself declare `part` directives, so these files **cannot** be made `part` of the lib barrel. Instead, `_providers.lib.dart` uses `import` for each provider file and only makes `_providers.dart` (the facade) a `part`:

```dart
// _providers.lib.dart — CORRECT
import 'token_provider.dart';
import 'dio_provider.dart';
// ...
part '_providers.dart';   // only the facade is a part
```

Do **not** use the standard `barrel_lib` / `barrel` skill flow (which converts public files to `part`) on folders whose public files contain `@riverpod` annotations. Use the pattern above instead (`import` each provider file; only the facade `_providers.dart` is `part`).

Use skills `barrel`, `barrel_lib`, `barrel_file` when creating or updating barrels.

> For the current `lib` file tree see **MD/APP_TREE.md**.