### Barrel pattern

A barrelled folder exposes a **single `_[name].lib.dart` root library** that centralises the folder's public files via **`export`** (pure-export barrel — **no `part`, no `library;`**):

| File | Role |
|---|---|
| `_[name].lib.dart` | Root library: one `export '<file>.dart';` per public file of the folder |

**Facades (`Custom[Name]`) are OPTIONAL and standalone.** When a folder benefits from a convenience class (e.g. `CustomInterceptors` in `core/network/interceptors/`), it is a **standalone file with its own imports**, exported by the barrel — it is NOT `part of` the barrel.

```dart
// lib/shared/exceptions/_exceptions.lib.dart — pure-export barrel
export 'api_exception.dart';
export 'app_timeout_exception.dart';
// ... one export per public file
```

**Example barrels:**
- `shared/models/` → `_models.lib.dart` barrel
- `shared/interfaces/` → `_interfaces.lib.dart` (exports `IAppNavigator`, `ITokenStore`, etc.) — **Rule 26**: solo se importa por el barrel, y ningún barrel externo re-exporta interfaces de esta carpeta
- `shared/error/` → `_error.lib.dart` barrel (Rule 22)
- `shared/exceptions/` → `_exceptions.lib.dart` barrel (Rule 23)
- `core/network/` → `_network.lib.dart` (re-exports the `contracts/` and `interceptors/` barrels)
- `core/network/contracts/` → `_contracts.lib.dart`
- `core/services/` → `_services.lib.dart`
- `shared/functions/` → imports individually (`online_first.dart` directly) — no barrel
- `shared/router/` → single file (`app_route.dart`), imported directly — no barrel (same as `shared/functions/`)
- `core/router/` → single file (`app_navigator_provider.dart`), imported directly — no barrel
- `features/auth/di/` → feature providers via `@riverpod` code-gen; navigation access via one-line `export` of `appNavigatorProvider` **only when the feature navigates imperatively** (on-demand — today no feature does, so none re-exports the seam yet)
- `app/di/` → app-level DI seams (`dio_overrides.dart`, `auth_observer_provider.dart`, `router_overrides.dart`) — NO provider barrel; providers live in `core/` source files (composition root: `httpServiceProvider`, `tokenStoreProvider`, `appDatabaseProvider`, `internetServiceProvider`, `clinicalHistoryStoreProvider`, `patientInfoStoreProvider`, `passwordHasherProvider`, `connectivityCheckerProvider`, `tokenVerifierProvider`, `credentialStoreProvider`, `jwtWrapperProvider`, `environmentProvider`, `appNavigatorProvider`)
- `shared/` → mock data lives in per-feature FakeDatasource files (no CustomJsons barrel)
- `core/database/` → accessed via Riverpod providers (`ref.watch(appDatabaseProvider)`); **no barrel** — production imports provider files directly and tests import the table impls directly (`tables/clinical_history.dart`, `tables/patient_info.dart`)
- `core/database/tables/` → impls en `clinical_history.dart` / `patient_info.dart`; providers en archivos dedicados `clinical_history_providers.dart` / `patient_info_providers.dart` (DI separado de la implementación — Rule 20)
- `core/network/interceptors/` → used internally by `DioWrapper`; not accessed from features

**Rules:**
- A `_[name].lib.dart` barrel **starts with `export`** and contains ONLY `export` directives — **no `library;`, no `part`** (enforced by CI in `test/architecture/dependency_rules_test.dart`).
- `*.g.dart` / `*.freezed.dart` files are owned by their source (they are `part of` their annotation file) — never add them to a barrel.
- Files starting with `_` are internal and are not exported by the barrel.
- An external package type can be re-exported through a barrel with `export` when needed.

**Exception — folders with `@riverpod`-annotated files:**

Provider files annotated with `@riverpod` (feature `di/`, `presentation/notifiers/`) live outside barrelled folders; their generated `.g.dart` stays `part of` its source. When a barrel does export a provider file (e.g. `_services.lib.dart` exports `token_providers.dart`), it does so with a normal `export` line.

**Exception — `presentation/widgets/` folders (NO barrel, NO facade):**

Widget files are **standalone** with explicit imports. There is NO `_widgets.lib.dart` barrel and NO `Custom[Name]Widgets` static facade. Each widget declares its own imports (`material`, `value_objects`, `l10n`, `design_system`, `shared/models`) and consumers import the widget file directly, using its constructor:

```dart
import 'package:clean_architecture_sdd_harness/features/<name>/presentation/widgets/<widget>.dart';
// ...
<WidgetName>(...)
```

> Use the `app-barrel` skill when creating or updating barrels.
> For the current `lib` file tree see **MD/APP_TREE.md**.
