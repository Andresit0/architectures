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
- Infrastructure wrappers live in `lib/core/` organized by domain (`services/`, `network/`, `database/`, `error/`).
- Shared domain abstractions under `lib/shared/`: `interfaces`, `exceptions`, `models`, `validators`, `pagination`, `jsons`, `functions` (`offline_first_repository.dart`).
- Generated files (`*.g.dart`, `*.freezed.dart`) live next to their annotated source file; never edit them by hand. Re-generate with `dart run build_runner build --delete-conflicting-outputs` from the project root.
- All pub packages are wrapped in `lib/core/services/` or `lib/core/network/`; code always uses Riverpod providers, never imports packages directly (except `flutter_riverpod`, `freezed_annotation`, and `intl`).
- Some folders (under `shared/` and `core/`) have barrel files: `_[name].lib.dart` (root library, centralises imports via `export`). Libraries now use `export` directly or `part of`. Use the `barrel`, `barrel_lib`, `barrel_file` skills when creating or updating barrels.

---

## Complete structure (current snapshot)

```
lib/
├── main.dart
├── app/                              ← Composition root
│   ├── di/
│   │   ├── _providers.lib.dart
│   │   ├── _providers.lib.dart       ← composition root barrel (exports all providers)
│   │   ├── auth/
│   │   │   └── auth_provider.dart
│   │   ├── network/
│   │   │   ├── auth_interceptor_impl.dart
│   │   │   └── dio_provider.dart
│   │   ├── router/
│   │   │   └── router_provider.dart
│   │   └── services/
│   │       └── sembast_provider.dart
│   └── router/
│       ├── app_route.dart            ← AppRoute enum
│       ├── app_router.dart           ← GoRouter definitions
│       └── guards/
│           └── auth_guard.dart
├── core/                             ← Pure infrastructure
│   ├── config/
│   │   ├── app_environment.dart      ← sealed AppEnvironment (dev/staging/prod)
│   │   └── environment_provider.dart
│   ├── database/                     ← AppDatabase, providers
│   ├── network/                      ← Dio wrappers, interceptors, connectivity
│   ├── router/
│   ├── services/                     ← Wrappers by domain (auth, crypto, device, events, logging, storage)
│   └── utils/
├── design_system/
│   ├── _design.lib.dart
│   ├── components/
│   └── theme/
├── features/
│   └── auth/
│       ├── domain/
│       │   ├── datasources/
│       │   ├── entities/              ← @freezed entities
│       │   ├── interfaces/
│       │   ├── repositories/
│       │   ├── services/
│       │   ├── usecases/
│       │   └── value_objects/
│       ├── infrastructure/
│       │   ├── datasources/
│       │   ├── dtos/
│       │   ├── mappers/
│       │   ├── repositories/
│       │   └── services/
│       ├── presentation/
│       │   ├── notifiers/             ← Riverpod notifiers + states (providers moved to features/<f>/di/)
│       │   ├── screens/
│       │   └── widgets/               ← ✅ BARREL
│       └── spec/                      ← SDD artifacts
├── l10n/
└── shared/                            ← Pure domain abstractions
    ├── error/
    ├── exceptions/                    ← ✅ BARREL
    │   ├── _exceptions.lib.dart
    │   ├── api_exception.dart
    │   └── ...
    ├── functions/                     ← offline_first_repository
    │   └── offline_first_repository.dart
    ├── interfaces/
    │   ├── _interfaces.lib.dart
    │   ├── i_connectivity_checker.dart
    │   ├── i_token_store.dart
    │   └── ...
    ├── jsons/                         ← ✅ BARREL
    │   (jsons/ directory removed — mock data now lives in FakeDatasource files per feature)
    ├── models/
    │   ├── _models.lib.dart
    │   ├── patient/
    │   └── clinical_history/
    └── error/                         ← ✅ BARREL
        ├── _error.lib.dart
        ├── app_error.dart             ← sealed AppError hierarchy
        ├── error_localizer.dart       ← localizeError() pure function
        ├── result.dart                ← sealed Result<T>
        └── result_guard.dart
```

---

## Layer responsibilities

| Layer | Location | Rule |
|---|---|---|
| **Domain** | `features/<f>/domain/` | No Flutter imports. Pure Dart: interfaces (`i_*.dart`), entities, usecases, value_objects. Can import from `shared/` only. |
| **DI (feature)** | `features/<f>/di/` | Feature-specific Riverpod providers (auth_provider, remember_me_provider) — migrated from `presentation/providers/`. |
| **Infrastructure** | `features/<f>/infrastructure/` | Implements domain interfaces. HTTP calls use `IDioWrapper` via constructor injection. |
| **Presentation** | `features/<f>/presentation/` | Riverpod notifiers, screens, widgets. Providers are in `features/<f>/di/`. |
| **core/** | `core/` | Infrastructure wrappers, database, error types, network, api_endpoints. Domain must NEVER import from `core/`. |
| **shared/** | `shared/` | Domain abstractions (interfaces, exceptions, models, validators, events) + utilities (jsons, pagination, functions). Domain-safe; can be imported by any layer. |
| **app/** | `app/` | Composition root: `_providers.lib.dart` barrel. GoRouter setup (`goRouterProvider`). Orchestrates `core/` services. |
| **core/config/** | `core/config/` | `AppEnvironment` sealed class + `environmentProvider`. |
| **design_system/** | `design_system/` | Theme, colors, reusable UI components (AppColors, AppTheme — migrated from shared/configs/). |

---

## Active barrel facades

| Facade class | File | Exposes |
|---|---|---|
| `_providers.lib.dart` | `app/di/_providers.lib.dart` | Exports all shared providers (httpServiceProvider, tokenStoreProvider, appDatabaseProvider, etc.) |
| *(removed)* | *(jsons/ directory deleted)* | mock data now in per-feature FakeDatasource |
| — | `design_system/components/loading_indicator.dart` | `LoadingIndicator` widget |

---

## Where to add new code

- **New feature**: create `lib/features/<feature>/` mirroring `auth/` (include `di/` folder for feature providers).
- **New pub package**: create wrapper in `lib/core/services/<domain>/<package>_wrapper.dart`. Use the `app-cp-package` skill, then apply `class_to_solid_min` to add the abstract interface and Riverpod provider. Export the provider through `_providers.lib.dart` barrel.
- **New shared service in core/**: use the `class_to_solid_min` skill → interface → impl → Riverpod provider → export through `_providers.lib.dart` barrel.
- **New barrel**: use the `barrel` skill (orchestrates `barrel_lib` then `barrel_file`).

---

## Example request using this skill
> "Use skill: app_lib_structure — Add a usecase in `features/encounter` to mark an encounter as read and wire it through repository and datasource stubs."
