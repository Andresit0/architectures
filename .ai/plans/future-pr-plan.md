# Auth Feature — Multi-PR Execution Plan

## Overview

| PR ID | Capability | Title | Layers | Commits | Prod Files | Cohesion |
|---|---|---|---|---|---|---|
| PR001 | _shared | Build + Shared Models + Database (drift→sembast migration) | build, shared | 5 | ~15 | 6.5 |
| PR002 | _shared | Shared Foundation (configs, exceptions, jsons, interceptors, widgets) | shared:configs, shared | 4 | ~19 | 7.0 |
| PR003 | _shared | Shared Functions + Providers | shared:functions, shared:providers | 5 | ~16 | 7.5 |
| PR004 | auth | Auth Feature — Domain + Infrastructure | domain, infra | 6 | ~14 | 8.0 |
| PR005 | auth | Auth Feature — Presentation (notifier, screens, widgets) + main.dart | state, ui | 8 | ~12 | 8.5 |

---

## Dependency Graph

```yaml
dependency_graph:
  nodes:
    # ── Layer 0: Build ──
    - file: pubspec.yaml
      layer: build
      imports: []
      barrel_expansion: []

    # ── Layer 1: Shared Configs (no internal deps) ──
    - file: lib/shared/configs/_configs.lib.dart
      layer: shared:configs
      imports:
        - target: (packages) flutter, go_router
      barrel_expansion: [app_routes.dart, route_names.dart, colors.dart, uries.dart, vars.dart, theme.dart, _configs.dart]
    - file: lib/shared/jsons/_jsons.lib.dart
      layer: shared:configs
      imports: []
      barrel_expansion: [auth_json.dart]

    # ── Layer 2: Shared Exceptions (no internal deps) ──
    - file: lib/shared/exceptions/_exceptions.lib.dart
      layer: shared
      imports:
        - target: (package) fpdart
      barrel_expansion: [api_exception.dart, no_connection_*.dart, server_unreachable_*.dart, unexpected_*.dart, failure*.dart]

    # ── Layer 3: Shared Interceptors (no internal deps) ──
    - file: lib/shared/interceptors/_interceptors.lib.dart
      layer: shared
      imports: [(package) dio]
      barrel_expansion: [auth_interceptor.dart]

    # ── Layer 4: Shared Models (no internal deps) ──
    - file: lib/shared/models/_models.lib.dart
      layer: shared
      imports: []
      barrel_expansion: [patient_entity.dart, clinical_history_*.dart]

    # ── Layer 5: Shared Database (depends on models) ──
    - file: lib/shared/database/_database.lib.dart
      layer: shared
      imports:
        - target: lib/shared/models/_models.lib.dart
          via: [import '../models/_models.lib.dart']
          barrel_expansion: [patient_entity.dart, clinical_history_*.dart]
      barrel_expansion: [app_database.dart, tables/clinical_history.dart, tables/patient_info.dart]

    # ── Layer 6: Shared Widgets (depends on configs) ──
    - file: lib/shared/widgets/_widgets.lib.dart
      layer: shared
      imports:
        - target: lib/shared/configs/_configs.lib.dart
          via: [import '../configs/_configs.lib.dart']
      barrel_expansion: [loading_indicator.dart]

    # ── Layer 7: Shared Functions (HUB — imports all other shared) ──
    - file: lib/shared/functions/_function.lib.dart
      layer: shared:functions
      imports:
        - target: lib/shared/configs/_configs.lib.dart
          via: [import '../configs/_configs.lib.dart']
          barrel_expansion: [app_routes.dart, route_names.dart, vars.dart, uries.dart, colors.dart]
          symbols_used: [CustomConfigs.uries.*, CustomConfigs.vars.*, RouteNames.*]
          extractable: false
          reason: "Core API surface of configs — cannot extract without moving the entire config module"
        - target: lib/shared/exceptions/_exceptions.lib.dart
          via: [import '../exceptions/_exceptions.lib.dart']
          barrel_expansion: [api_failure.dart, no_connection_failure.dart, ...]
          symbols_used: [Failure, Either]
          extractable: false
          reason: "Type-level dependency — Either/Failure are structural"
        - target: lib/shared/interceptors/_interceptors.lib.dart
          via: [import '../interceptors/_interceptors.lib.dart']
          barrel_expansion: [auth_interceptor.dart]
          symbols_used: [CustomInterceptors.auth]
          extractable: false
          reason: "Factory method — structural dependency"
        - target: lib/shared/database/_database.lib.dart
          via: [import '../database/_database.lib.dart']
          barrel_expansion: [app_database.dart]
          symbols_used: [AppDatabase]
          extractable: false
          reason: "Full class dependency — needs AppDatabase type"
        - target: lib/shared/providers/go_router_notifier_provider.dart
          via: [import '../providers/go_router_notifier_provider.dart']
          barrel_expansion: []
          symbols_used: [GoRouterListenable]
          extractable: false
          reason: "Type dependency on GoRouterListenable class"
      barrel_expansion: [cp_dio.dart, cp_sembast.dart, cp_crypto.dart, cp_go_router.dart, ...]

    # ── Layer 8: Shared Providers (depends on functions) ──
    - file: lib/shared/providers/dio_provider.dart
      layer: shared:providers
      imports:
        - target: lib/shared/functions/_function.lib.dart
          via: [import '../functions/_function.lib.dart']
    - file: lib/shared/providers/token_provider.dart
      layer: shared:providers
      imports:
        - target: lib/shared/functions/_function.lib.dart
          via: [import '../functions/_function.lib.dart']

    # ── Layer 9: Auth Domain ──
    - file: lib/features/auth/domain/entities/login_response_entity.dart
      layer: domain
      imports:
        - target: lib/shared/models/patient/patient_entity.dart (via models barrel)
        - target: lib/shared/models/clinical_history/clinical_history_entity.dart (via models barrel)
    - file: lib/features/auth/domain/repositories/i_auth_repository.dart
      layer: domain
      imports:
        - target: lib/shared/exceptions/_exceptions.lib.dart
    - file: lib/features/auth/domain/usecases/*.dart
      layer: domain
      imports:
        - target: lib/shared/exceptions/_exceptions.lib.dart
        - target: (domain entities and interfaces)

    # ── Layer 10: Auth Infrastructure ──
    - file: lib/features/auth/infrastructure/datasources/auth_datasource_impl.dart
      layer: infra
      imports:
        - target: lib/shared/configs/_configs.lib.dart
        - target: lib/shared/functions/_function.lib.dart
        - target: lib/shared/jsons/_jsons.lib.dart
        - target: (domain datasources, entities, mapper)
    - file: lib/features/auth/infrastructure/repositories/auth_repository_impl.dart
      layer: infra
      imports:
        - target: lib/shared/exceptions/_exceptions.lib.dart
        - target: lib/shared/functions/_function.lib.dart
        - target: (domain datasources, entities, interfaces)

    # ── Layer 11: Auth Presentation ──
    - file: lib/features/auth/presentation/providers/auth_provider.dart
      layer: state
      imports:
        - target: lib/shared/providers/_providers.lib.dart
        - target: lib/shared/database/_database.lib.dart
        - target: lib/shared/functions/_function.lib.dart
        - target: (domain + infra)
    - file: lib/features/auth/presentation/notifiers/auth_notifier.dart
      layer: state
      imports:
        - target: lib/shared/functions/_function.lib.dart
        - target: lib/shared/providers/_providers.lib.dart
        - target: (auth provider, auth state)
    - file: lib/features/auth/presentation/screens/login_screen.dart
      layer: ui
      imports:
        - target: lib/shared/configs/_configs.lib.dart
        - target: lib/shared/widgets/_widgets.lib.dart
        - target: (auth notifier, auth state, auth widgets)

    # ── Entry Point ──
    - file: lib/main.dart
      layer: (entry)
      imports:
        - target: lib/shared/configs/_configs.lib.dart
        - target: lib/shared/functions/_function.lib.dart
        - target: lib/shared/providers/_providers.lib.dart
        - target: lib/shared/interceptors/_interceptors.lib.dart
        - target: lib/shared/widgets/_widgets.lib.dart
        - target: lib/features/auth/presentation/screens/login_screen.dart
        - target: lib/features/auth/presentation/screens/clinical_history_placeholder_screen.dart
        - target: lib/features/auth/presentation/notifiers/auth_notifier.dart

  edges:
    # Build → all others (pubspec deps)
    - from: pubspec.yaml
      to: "*"
      type: indirect
      severity: info
      status: OK

    # Shared hub: functions → all other shared
    - from: _function.lib.dart
      to: _configs.lib.dart
      type: barrel→barrel
      severity: coupling
      status: NOT_EXTRACTABLE
    - from: _function.lib.dart
      to: _exceptions.lib.dart
      type: barrel→barrel
      severity: coupling
      status: NOT_EXTRACTABLE
    - from: _function.lib.dart
      to: _interceptors.lib.dart
      type: barrel→barrel
      severity: coupling
      status: NOT_EXTRACTABLE
    - from: _function.lib.dart
      to: _database.lib.dart
      type: barrel→barrel
      severity: coupling
      status: NOT_EXTRACTABLE
    - from: _function.lib.dart
      to: go_router_notifier_provider.dart
      type: barrel→file
      severity: coupling
      status: NOT_EXTRACTABLE

    # Providers → functions
    - from: dio_provider.dart
      to: _function.lib.dart
      type: file→barrel
      severity: coupling
      status: NOT_EXTRACTABLE
    - from: token_provider.dart
      to: _function.lib.dart
      type: file→barrel
      status: NOT_EXTRACTABLE
    - from: sembast_provider.dart
      to: _function.lib.dart
      type: file→barrel
      status: NOT_EXTRACTABLE

    # Database → models
    - from: _database.lib.dart
      to: _models.lib.dart
      type: barrel→barrel
      status: IRREDUCIBLE

    # Widgets → configs
    - from: _widgets.lib.dart
      to: _configs.lib.dart
      type: barrel→barrel
      status: OK

    # Auth domain → shared exceptions + models
    - from: i_auth_repository.dart
      to: _exceptions.lib.dart
      type: file→barrel
      status: OK
    - from: login_response_entity.dart
      to: _models.lib.dart
      type: file→barrel
      status: OK

    # Auth infrastructure → shared
    - from: auth_datasource_impl.dart
      to: _configs.lib.dart
      type: file→barrel
      status: OK
    - from: auth_datasource_impl.dart
      to: _function.lib.dart
      type: file→barrel
      status: OK
    - from: auth_datasource_impl.dart
      to: _jsons.lib.dart
      type: file→barrel
      status: OK
    - from: auth_repository_impl.dart
      to: _exceptions.lib.dart
      type: file→barrel
      status: OK
    - from: auth_repository_impl.dart
      to: _function.lib.dart
      type: file→barrel
      status: OK

    # Auth presentation → shared + auth infra
    - from: auth_provider.dart
      to: _providers.lib.dart
      type: file→barrel
      status: OK
    - from: auth_provider.dart
      to: _database.lib.dart
      type: file→barrel
      status: OK
    - from: auth_provider.dart
      to: _function.lib.dart
      type: file→barrel
      status: OK
    - from: auth_provider.dart
      to: (domain + infra files)
      type: file→file
      status: SAME_PR

  clusters:
    - id: PR001
      files: [pubspec.yaml, pubspec.lock, lib/shared/models/**, lib/shared/database/**]
      reason: "Build deps + database migration — pubspec change with drift removal must ship same PR as sembast rewrite of database layer"
    - id: PR002
      files: [lib/shared/configs/**, lib/shared/exceptions/**, lib/shared/jsons/**, lib/shared/interceptors/**, lib/shared/widgets/**]
      reason: "Shared foundation — no internal dependency chain among these modules; all independently compilable"
    - id: PR003
      files: [lib/shared/functions/**, lib/shared/providers/**]
      reason: "IRREDUCIBLE — _function.lib.dart imports go_router_notifier_provider.dart AND all providers (dio, token, sembast) import _function.lib.dart back. Bidirectional dependency chain prevents splitting. functions barrel part declarations require all part files to ship together."
    - id: PR004
      files: [lib/features/auth/domain/**, lib/features/auth/infrastructure/**]
      reason: "Auth domain + infra — high affinity (9), domain interfaces needed by infrastructure implementations"
    - id: PR005
      files: [lib/features/auth/presentation/**, lib/main.dart, test/bdd/auth_bdd_test.dart, integration_test/auth_integration_test.dart]
      reason: "Auth presentation + entry point — must be last PR as it depends on all prior PRs"
```

---

## Refactoring Analysis

### Extractable symbols detected

| Barrel import edge | Symbol | Extractable? | Action taken |
|---|---|---|---|
| `_function.lib.dart → _configs.lib.dart` | `RouteNames.login`, `RouteNames.clinicalHistory` | ✅ Yes — static const String | ✅ ALREADY EXTRACTED in commit 7050118 (`route_names.dart`). Committed to feature/auth. |
| `_function.lib.dart → _configs.lib.dart` | `CustomConfigs.uries.*`, `CustomConfigs.vars.*` | ❌ No — core configs API surface | Entire config module would need to be in functions; not meaningful |
| `_function.lib.dart → _exceptions.lib.dart` | `Failure`, `Either` | ❌ No — type-level structural dependency | Either/Failure types are the reason the module exists |
| `_function.lib.dart → _interceptors.lib.dart` | `CustomInterceptors.auth()` | ❌ No — factory method | AuthInterceptor type needed by CpDio |
| `_function.lib.dart → _database.lib.dart` | `AppDatabase` | ❌ No — full class dependency | AppDatabase type needed by CustomFunction |
| `dio_provider.dart → _function.lib.dart` | `CustomFunction.dio` | ❌ No — structural DI | Provider wraps the DI facade |

### Extractions Applied

Already extracted in commit `7050118` (pre-existing on `feature/auth` branch):

| Symbol | From barrel | Extracted to | Status |
|---|---|---|---|
| `RouteNames.login` | `_function.lib.dart` (via `_configs.lib.dart`) | `route_names.dart` | ✅ Already extracted (part of `_configs.lib.dart`) |
| `RouteNames.clinicalHistory` | `_function.lib.dart` (via `_configs.lib.dart`) | `route_names.dart` | ✅ Already extracted |

### Truly irreducible clusters

| PR ID | Layers | Commits | Prod Files | Reason not split |
|---|---|---|---|---|
| PR001 | build, shared | 5 | ~15 | Build deps (drift→sembast) must ship same PR as database rewrite. Database depends on models (part declarations). Irreducible. |
| PR003 | shared:functions, shared:providers | 5 | ~16 | **Hub**: `_function.lib.dart` barrel imports `go_router_notifier_provider.dart` AND all 3 providers (dio, token, sembast) import `_function.lib.dart`. Bidirectional dependency. All part files in functions barrel must ship together — `_function.lib.dart` has part declarations for all cp_* wrappers. |
| PR005 | state, ui | 8 | ~12 | Auth presentation depends on all prior PRs. main.dart must ship with auth presentation (injects auth screens via ScreenBuilder). integration/auth_integration_test depends on everything. |

---

## Migration Analysis

### Drift → Sembast Migration

| Dependency | Action | PR |
|---|---|---|
| `pubspec.yaml` | Remove drift, drift_flutter, drift_dev; Add sembast, sembast_web, crypto, pointycastle | PR001 (C001) |
| `lib/shared/database/app_database.dart` | Rewrite from drift to sembast | PR001 (C005) |
| `lib/shared/database/_database.lib.dart` | Update imports and part declarations | PR001 (C005) |
| `lib/shared/functions/cp_drift.dart` | DELETE — no longer needed | PR003 (C012) |
| `lib/shared/functions/cp_sembast.dart` | NEW — sembast wrapper | PR003 (C011) |
| `lib/shared/functions/_function.lib.dart` | Update part declarations (remove cp_drift, add cp_sembast, cp_crypto) | PR003 (C012) |
| `lib/shared/providers/sembast_provider.dart` | NEW — Riverpod bridge for sembast | PR003 (C014) |

**Status**: ✅ MIGRATION IS ATOMIC within PR001 (pubspec + database rewrite). Consumer cleanup in PR003.

---

## Reviewability Standards Compliance

| Threshold | PR001 | PR002 | PR003 | PR004 | PR005 |
|---|---|---|---|---|---|
| Layers ≤ 2 | ✅ 2 (build, shared) | ✅ 2 (shared:configs, shared) | ✅ 2 (shared:functions, shared:providers) | ✅ 2 (domain, infra) | ✅ 2 (state, ui) |
| Commits ≤ 8 | ✅ 5 | ✅ 4 | ✅ 5 | ✅ 6 | ✅ 8 |
| Prod files ≤ 20 | ✅ ~15 | ✅ ~19 | ✅ ~16 | ✅ ~14 | ✅ ~12 |
| Cross-capability | ✅ all _shared | ✅ all _shared | ✅ all _shared | ✅ all auth | ✅ all auth |

All PRs satisfy Company Reviewability Standards (HARD thresholds).

---

## Test Coverage Verification

| PR | Production Files | Test Files | Coverage |
|---|---|---|---|
| PR001 | models (8), database (5), build (2) | models_test (2), database_test (4) | ✅ Consolidated exceptions OK |
| PR002 | configs (6), exceptions (8), jsons (1), interceptors (2), widgets (2) | route_names_test, vars_test, exceptions_test, auth_interceptor_test, loading_indicator_test | ✅ |
| PR003 | functions (12), providers (4) | cp_crypto_test, cp_sembast_test, cp_go_router_test, offline_first_test, reachability tests, provider tests | ✅ |
| PR004 | domain (10), infra (4) | auth_entity_test, usecase tests (4), datasource tests (2), repo test | ✅ |
| PR005 | presentation (10), main.dart (1) | auth_notifier_test, login_screen_test, auth_widget_test, bdd_test, integration_test | ✅ |

All production files have tests in the same PR. No deferred tests.

---

## Warnings Summary

```yaml
warnings:
  - type: barrel-integrity
    severity: low
    detail: "database_encrypt.dart and secure_storage_key_service.dart in lib/shared/database/ are imported via `import` in _database.lib.dart but do NOT have `part of` directives. They are standalone libraries, not part files. This is architecturally valid (avoids circular dependency) but unconventional for the barrel pattern."
  - type: inter-pr-dependency
    severity: low
    detail: "PR003 (shared:functions) has a bidirectional import: _function.lib.dart → go_router_notifier_provider.dart (providers), AND dio_provider.dart/token_provider.dart/sembast_provider.dart → _function.lib.dart (functions). These two modules are IRREDUCIBLE and must ship in the same PR cluster. Documented in Truly irreducible clusters."
  - type: cross-layer-block
    severity: info
    detail: "CROSS-LAYER BLOCK WAS RESOLVED in commit 7050118: lib/shared/configs/_configs.lib.dart no longer imports feature screens. ScreenBuilder typedef + initRoutes() injection from main.dart resolved the block. Multi-PR splitting IS possible."
  - type: migration
    severity: info
    detail: "Drift→sembast migration detected. pubspec changes (PR001 C001) and database rewrite (PR001 C005) are in the SAME PR. Consumer cleanup (function wrappers) is in PR003. Migration is atomic."
  - type: pr-boundary
    severity: info
    detail: "PR005 has 8 commits (at limit). All 8 are required for the auth presentation layer. No further split possible without breaking compile independence."
```
