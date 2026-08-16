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
- Shared domain abstractions under `lib/shared/`: `interfaces`, `exceptions`, `models`, `router`, `functions` (`online_first.dart` — online-first: remote first, cache fallback only on connectivity failure; the helper owns all boundary guarding).
- Generated files (`*.g.dart`, `*.freezed.dart`) live next to their annotated source file; never edit them by hand. Re-generate with `dart run build_runner build --delete-conflicting-outputs` from the project root.
- All pub packages are wrapped in `lib/core/services/` or `lib/core/network/`; code always uses Riverpod providers, never imports packages directly (except `flutter_riverpod`, `freezed_annotation`, and `intl`).
- Some folders (under `shared/` and `core/`) have barrel files: `_[name].lib.dart` (root library, centralises imports via `export`). Barrels are **pure-export** (no `part`, no `library;`) — use the `app-barrel` skill when creating or updating them.

---

## Complete structure (current snapshot)

```
lib/
├── main.dart
├── app/                              ← Composition root
│   ├── di/                           ← app-level DI seams (NO provider barrel)
│   │   ├── auth/
│   │   │   └── auth_observer_provider.dart  ← authenticationObserverProvider (app-level)
│   │   ├── network/
│   │   │   ├── auth_interceptor_impl.dart
│   │   │   └── dio_overrides.dart           ← dioOverrides(): binds authInterceptorProvider seam
│   │   └── router/
│   │       ├── go_router_navigator.dart     ← GoRouterNavigator (única impl de IAppNavigator)
│   │       ├── router_overrides.dart        ← routerOverrides(): binds appNavigatorProvider seam
│   │       └── router_provider.dart         ← goRouterProvider
│   └── router/
│       ├── app_router.dart           ← GoRouter definitions
│       └── guards/
│           └── auth_guard.dart       ← deep-link ?from= redirect
├── core/                             ← Pure infrastructure
│   ├── config/
│   │   ├── app_environment.dart      ← sealed AppEnvironment (dev/staging/prod)
│   │   └── environment_provider.dart
│   ├── database/                     ← AppDatabase, providers
│   ├── network/                      ← Dio wrappers, interceptors, connectivity
│   ├── router/
│   │   └── app_navigator_provider.dart  ← appNavigatorProvider (seam IAppNavigator)
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
    │   └── ... (app_timeout, device_security, no_connection, server_unreachable, unexpected_response)
    ├── functions/                     ← online_first
    │   └── online_first.dart
    ├── interfaces/
    │   ├── _interfaces.lib.dart
    │   ├── i_app_navigator.dart       ← IAppNavigator (seam tipado, sin go_router)
    │   ├── i_connectivity_checker.dart
    │   ├── i_token_store.dart
    │   └── ...
    ├── jsons/                         ← ✅ BARREL
    │   (jsons/ directory removed — mock data now lives in FakeDatasource files per feature)
    ├── models/
    │   ├── _models.lib.dart
    │   ├── patient/
    │   └── clinical_history/
    ├── router/
    │   └── app_route.dart             ← AppRoute (registro tipado de rutas, pure Dart)
    └── error/                         ← ✅ BARREL
        ├── _error.lib.dart
        ├── app_error.dart             ← sealed AppError hierarchy
        ├── error_localizer.dart       ← localizeError() (UI layer, lives in l10n/)
        ├── result.dart                ← sealed Result<T>
        └── result_guard.dart
```

---

## Layer responsibilities

| Layer | Location | Rule |
|---|---|---|
| **Domain** | `features/<f>/domain/` | No Flutter imports. Pure Dart: interfaces (`i_*.dart`), entities, usecases, value_objects. Can import from `shared/` only. |
| **DI (feature)** | `features/<f>/di/` | Feature-specific Riverpod providers (auth_provider) — migrated from `presentation/providers/`. UI-state providers (p. ej. `remember_me_provider`) viven en `presentation/notifiers/`. |
| **Infrastructure** | `features/<f>/infrastructure/` | Implements domain interfaces. HTTP calls use `IDioWrapper` via constructor injection. |
| **Presentation** | `features/<f>/presentation/` | Riverpod notifiers, screens, widgets. Providers are in `features/<f>/di/`. |
| **core/** | `core/` | Infrastructure wrappers, database, error types, network, api_endpoints. Domain must NEVER import from `core/`. |
| **shared/** | `shared/` | Domain abstractions (interfaces, exceptions, models) + utilities (router, functions). Domain-safe; can be imported by any layer. |
| **app/** | `app/` | Composition root: GoRouter setup (`goRouterProvider`), `routerOverrides()` (IAppNavigator seam), `dioOverrides()`. Orchestrates `core/` services. |
| **core/config/** | `core/config/` | `AppEnvironment` sealed class + `environmentProvider`. |
| **design_system/** | `design_system/` | Theme, colors, reusable UI components (AppColors, AppTheme — migrated from shared/configs/). |

---

## Active barrel facades

| Facade class | File | Exposes |
|---|---|---|
| *(sin barrel)* | `app/di/` | App-level DI seams (`dio_overrides.dart`, `router_overrides.dart`, `auth_observer_provider.dart`) — NO provider barrel. Los providers viven en `core/` source files; feature DI imports providers DIRECTLY from `core/` (e.g. `core/network/dio/dio_providers.dart`) — never from `app/` (Rule 11) |
| *(removed)* | *(jsons/ directory deleted)* | mock data now in per-feature FakeDatasource |
| — | `design_system/components/loading_indicator.dart` | `LoadingIndicator` widget |

---

## Where to add new code

- **New feature**: create `lib/features/<feature>/` mirroring `auth/` (include `di/` folder for feature providers).
- **New pub package**: create wrapper in `lib/core/services/<domain>/<package>_wrapper.dart`. Use the `app-cp-package` skill, then apply `class_to_solid_min` to add the abstract interface and Riverpod provider. The provider lives in its `core/` source file (features import it directly).
- **New shared service in core/**: use the `class_to_solid_min` skill → interface → impl → Riverpod provider in un archivo `*_providers.dart` dedicado (p. ej. `token_providers.dart`), nunca embebido en la clase de servicio (Rule 20). En `core/database/tables/` los providers viven en `*_providers.dart` separados de las impl.
- **New barrel**: use the `app-barrel` skill.

---

## Example request using this skill
> "Use skill: app_lib_structure — Add a usecase in `features/encounter` to mark an encounter as read and wire it through repository and datasource stubs."
