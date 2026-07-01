---
name: app-lib-structure
description: Documents the complete lib/ directory structure of this project. Use when making or modifying code under lib/ to determine the correct file location and architecture layer (features, domain, infrastructure, presentation, shared).
---

Skill: app_lib_structure

## Description
Documents the complete structure of `lib/` and explains where to place files for each architecture layer. Consult this skill before creating or modifying any file under `lib/`.

## How to use
Include `app_lib_structure` in your request when working under `lib/`. The assistant uses this document to resolve the correct path and layer without scanning the repo.

---

## Project-specific conventions

- Layered by feature under `lib/features/<feature>` with subfolders: `domain`, `infrastructure`, `presentation`.
- Shared utilities under `lib/shared`: `configs`, `database`, `functions`, `exceptions`, `interceptors`, `providers`, `jsons`.
- Generated files (`*.g.dart`, `*.freezed.dart`) live next to their annotated source file; never edit them by hand. Re-generate with `dart run build_runner build --delete-conflicting-outputs` from the project root.
- All pub packages are wrapped in `lib/shared/functions/cp_<package>.dart`; code always uses `CustomFunction.xxx`, never imports packages directly (except `flutter_riverpod`, `riverpod_annotation`, and `freezed_annotation`).
- Barrelled folders have two files: `_[name].lib.dart` (root library, centralises imports, declares `part`) and `_[name].dart` (facade `Custom[Name]` with `static final` members). Use the `barrel`, `barrel_lib`, `barrel_file` skills when creating or updating barrels.

---

## Complete structure (current snapshot)

```
lib/
├── main.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── datasources/
│   │   │   │   └── i_auth_datasource.dart
│   │   │   ├── entities/                         ← partial BARREL (lib only)
│   │   │   │   ├── _entities.lib.dart
│   │   │   │   ├── user_entity.dart
│   │   │   │   ├── user_entity.freezed.dart      ← generated
│   │   │   │   └── user_entity.g.dart            ← generated
│   │   │   ├── repositories/
│   │   │   │   └── i_auth_repository.dart
│   │   │   └── usecases/
│   │   │       └── auth_usecase.dart
│   │   ├── infrastructure/
│   │   │   ├── datasources/
│   │   │   │   └── auth_datasource_impl.dart
│   │   │   ├── mappers/
│   │   │   │   └── auth_mapper.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── notifiers/
│   │       │   ├── auth_state.dart
│   │       │   ├── auth_state.freezed.dart       ← generated
│   │       │   ├── auth_notifier.dart
│   │       │   └── auth_notifier.g.dart          ← generated
│   │       ├── providers/
│   │       │   ├── login_providers.dart
│   │       │   └── login_providers.g.dart         ← generated
│   │       ├── screens/
│   │       │   └── login_screen.dart
│   │       └── widgets/                           ← ✅ BARREL
│   │           ├── _widgets.lib.dart
│   │           ├── _widgets.dart                  ←   facade: CustomWidgets
│   │           ├── button_principal.dart
│   │           ├── id_form_field.dart
│   │           └── password_form_field.dart
│   └── encounter/
│       ├── domain/
│       │   ├── datasources/
│       │   │   └── i_encounter_datasource.dart
│       │   ├── entities/
│       │   │   ├── encounter_entity.dart
│       │   │   ├── encounter_entity.freezed.dart ← generated
│       │   │   └── encounter_entity.g.dart       ← generated
│       │   ├── repositories/
│       │   │   └── i_encounter_repository.dart
│       │   └── usecases/
│       │       └── download_pdf_usecase.dart
│       ├── infrastructure/
│       │   ├── datasources/
│       │   │   └── encounter_datasource_impl.dart
│       │   ├── mappers/
│       │   │   └── encounter_mapper.dart
│       │   └── repositories/
│       │       └── encounter_repository_impl.dart
│       └── presentation/
│           ├── notifiers/
│           │   ├── encounter_state.dart
│           │   ├── encounter_state.freezed.dart   ← generated
│           │   ├── encounter_notifier.dart
│           │   └── encounter_notifier.g.dart      ← generated
│           ├── providers/
│           │   ├── encounter_provider.dart
│           │   └── encounter_provider.g.dart      ← generated
│           ├── screens/
│           │   └── encounter_screen.dart
│           └── widgets/                           ← ✅ BARREL
│               ├── _widgets.lib.dart
│               ├── _widgets.dart                  ←   facade: CustomWidgets
│               ├── download_file.dart
│               └── expanded_card.dart
└── shared/
    ├── configs/                          ← ✅ BARREL
    │   ├── _configs.lib.dart             ←   root library (imports + part declarations)
    │   ├── _configs.dart                 ←   facade: CustomConfigs
    │   ├── app_routes.dart               ←   Routes (GoRoute definitions)
    │   ├── colors.dart                   ←   AppColors
    │   ├── theme.dart                    ←   AppTheme
    │   ├── uries.dart                    ←   AppUries
    │   └── vars.dart                     ←   Vars
    ├── database/                         ← Drift database (no barrel facade)
    │   ├── _database.lib.dart            ←   root library (exports AppDatabase)
    │   ├── app_database.dart             ←   AppDatabase (Drift @DriftDatabase)
    │   └── app_database.g.dart           ←   generated
    ├── functions/                        ← ✅ BARREL
    │   ├── _function.lib.dart            ←   root library (centralises all package imports)
    │   ├── _function.dart                ←   facade: CustomFunction
    │   ├── cp_dartz.dart                 ←   CpDartz implements ICpDartz (Either/guard)
    │   ├── cp_dio.dart                   ←   CpDio implements ICpDio (HTTP client)
    │   ├── cp_drift.dart                 ←   CpDrift implements ICpDrift (session persistence)
    │   ├── cp_go_router.dart             ←   CpGoRouter implements ICpGoRouter (navigation)
    │   ├── cp_logger.dart                ←   CpLogger implements ICpLogger (logging)
    │   ├── cp_path_provider.dart         ←   CpPathProvider implements ICpPathProvider
    │   ├── cp_share_plus.dart            ←   CpSharePlus implements ICpSharePlus (PDF share)
    │   ├── failure_propagation.dart      ←   FailurePropagation implements IFailurePropagation
    │   ├── internet_service.dart         ←   InternetService implements IInternetService
    │   └── token_service.dart            ←   TokenService implements ITokenService
    ├── exceptions/                       ← ✅ BARREL
    │   ├── _exceptions.lib.dart          ←   root library (re-exports Either/Left/Right from dartz)
    │   ├── _exceptions.dart              ←   facade: CustomExceptions (typedefs + factories)
    │   ├── failure.dart                  ←   abstract Failure base class
    │   ├── api_exception.dart
    │   ├── api_failure.dart
    │   ├── go_router_exception.dart
    │   ├── go_router_failure.dart
    │   ├── no_connection_exception.dart
    │   ├── no_connection_failure.dart
    │   ├── no_request_exception.dart
    │   ├── no_request_failure.dart
    │   ├── server_unreachable_exception.dart
    │   ├── server_unreachable_failure.dart
    │   ├── unexpected_failure.dart
    │   ├── unexpected_response_exception.dart
    │   └── unexpected_response_failure.dart
    ├── interceptors/                     ← ✅ BARREL
    │   ├── _interceptors.lib.dart        ←   root library
    │   ├── _interceptors.dart            ←   facade: CustomInterceptors
    │   └── auth_interceptor.dart         ←   AuthInterceptor (Dio interceptor)
    ├── providers/                        ← ✅ BARREL
    │   ├── _providers.lib.dart           ←   root library
    │   ├── _providers.dart               ←   facade: CustomProviders
    │   ├── dio_provider.dart             ←   httpServiceProvider → Provider<ICpDio>
    │   ├── dio_provider.g.dart                   ← generated
    │   ├── go_router_notifier_provider.dart ←   goRouterListenableProvider → Provider<GoRouterListenable>
    │   ├── share_plus_provider.dart      ←   sharePlusServiceProvider → Provider<ICpSharePlus>
    │   ├── share_plus_provider.g.dart            ← generated
    │   ├── token_provider.dart           ←   tokenServiceProvider → Provider<ITokenService>
    │   ├── token_provider.g.dart                 ← generated
    │   ├── user_entity_notifier.dart
    │   └── user_entity_notifier.g.dart           ← generated
    └── jsons/                            ← ✅ BARREL
        ├── _jsons.lib.dart
        ├── _jsons.dart                   ←   facade: CustomJsons
        └── user_json.dart                ←   mock/test data
```

---

## Layer responsibilities

| Layer | Location | Rule |
|---|---|---|
| **Domain** | `features/<f>/domain/` | No Flutter imports. Pure Dart: interfaces (`i_*.dart`), entities, usecases. |
| **Infrastructure** | `features/<f>/infrastructure/` | Implements domain interfaces. HTTP calls use `ICpDio` injected via constructor. |
| **Presentation** | `features/<f>/presentation/` | Riverpod notifiers/providers, screens, widgets. All state via `@riverpod`. |
| **Shared configs** | `shared/configs/` | App-wide constants, theme, routes. Access via `CustomConfigs.xxx`. |
| **Shared database** | `shared/database/` | Drift `AppDatabase`. Used only via `CustomFunction.drift` (internal). |
| **Shared functions** | `shared/functions/` | Service classes + `cp_*` package wrappers. Access via `CustomFunction.xxx`. |
| **Shared interceptors** | `shared/interceptors/` | Dio interceptors. Access via `CustomInterceptors.xxx` (internal to `CpDio`). |
| **Shared providers** | `shared/providers/` | Riverpod `Provider<IInterface>` for shared services. Consumed via `ref.watch` (reactive) or `ref.read` (one-shot callbacks). See `MD/APP_PROVIDERS.md` for the full rules. |
| **Shared exceptions** | `shared/exceptions/` | Custom exception and Failure types. Re-exports `Either`, `Left`, `Right`. |

---

## Active barrel facades

| Facade class | File | Exposes |
|---|---|---|
| `CustomConfigs` | `shared/configs/_configs.dart` | `.appColors`, `.uries`, `.vars`, `.theme`, `.routes` |
| `CustomFunction` | `shared/functions/_function.dart` | `.pathProvider`, `.sharePlus`, `.internetService`, `.tokenService`, `.dio`, `.logger`, `.dartz`, `.failure`, `.drift` |
| `CustomInterceptors` | `shared/interceptors/_interceptors.dart` | `.auth(readToken)` → `AuthInterceptor` |
| `CustomExceptions` | `shared/exceptions/_exceptions.dart` | typedefs + factories for all exception/failure types |
| `CustomProviders` | `shared/providers/_providers.dart` | `.dio`, `.token`, `.sharePlus`, `.user`, `.goRouter` |
| `CustomJsons` | `shared/jsons/_jsons.dart` | mock/test JSON data |

---

## Package wrappers in `shared/functions/`

| File | Interface | Class | Purpose |
|---|---|---|---|
| `cp_dartz.dart` | `ICpDartz` | `CpDartz` | `guard()` — converts exceptions to `Either<Failure, T>` |
| `cp_dio.dart` | `ICpDio` | `CpDio` | HTTP client (get / post) with auth headers and typed exceptions |
| `cp_drift.dart` | `ICpDrift` | `CpDrift` | Session persistence (read / save / clear) via Drift `AppDatabase` |
| `cp_go_router.dart` | `ICpGoRouter` | `CpGoRouter` | Navigation wrapper; `CpGoRouter.create(routes:, refreshListenable:)` builds the `GoRouter` in `main.dart` |
| `cp_logger.dart` | `ICpLogger` | `CpLogger` | Logging utility (internal to other wrappers) |
| `cp_path_provider.dart` | `ICpPathProvider` | `CpPathProvider` | Filesystem path utilities (temp dir, documents dir) |
| `cp_share_plus.dart` | `ICpSharePlus` | `CpSharePlus` | `pdf()` — shares a PDF via the OS share sheet |
| `failure_propagation.dart` | `IFailurePropagation` | `FailurePropagation` | `launch()` — maps `Failure` to typed UI state without a `switch` |
| `internet_service.dart` | `IInternetService` | `InternetService` | Connectivity check (used internally by `CpDio` only) |
| `token_service.dart` | `ITokenService` | `TokenService` | Secure token storage (`save` / `read` / `delete` / `isTokenExpired` / `decodeJwtPayload` + refresh token variants) |

---

## Where to add new code

- **New feature**: create `lib/features/<feature>/` mirroring `auth/` or `encounter/`.
- **New pub package**: use the `cp_package` skill → creates `cp_<package>.dart` and registers it in `CustomFunction`; then **always** apply `class_to_solid_min` to add the abstract interface and update the `CustomFunction` field type to the interface. The Riverpod provider in `shared/providers/` is only needed when the service is injectable (category "Servicio inyectable" in `MD/APP_PACKAGE_WRAPPER.md`); skip it for pure utilities (`dartz`, `failure`, `logger`, `pathProvider`) and internal dependencies (`internetService`, `drift`).
- **New shared service**: use the `class_to_solid_min` skill → interface → impl → `CustomFunction` entry → Riverpod provider (if injectable).
- **New barrel**: use the `barrel` skill (orchestrates `barrel_lib` then `barrel_file`).

---

## Example request using this skill
> "Use skill: app_lib_structure — Add a usecase in `features/encounter` to mark an encounter as read and wire it through repository and datasource stubs."

