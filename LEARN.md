# FILE TO LEARN ABOUT ARCHITECTURE SELECTED

## Clean Architecture — Core Concepts

### What is Clean Architecture?

Clean Architecture is a design pattern that organizes code into **concentric layers** where the inner layers contain business rules (pure, with no external dependencies) and the outer layers contain infrastructure details (frameworks, databases, UI).

```
Clean Architecture layers (from the inside out):

1. Enterprise Business Rules   → Global business rules (entities, value objects)
2. Application Business Rules  → Use-case-specific business rules
3. Interface Adapters         → Concrete implementations (datasources, repositories)
4. Frameworks & Drivers       → Flutter, UI, database, Composition Root
```

### The Dependency Rule

**The source code of inner layers must NEVER import code from outer layers.**

```
Inner layer:  domain/   →  imports shared/ + freezed_annotation + own domain  ✅
Middle layer: core/     →  imports shared/ but NEVER features/               ✅
Outer layer:  app/      →  may import ALL layers (core/ NO features/app — R14) ✅
```

Dependencies always point inward:

```
shared/  ←  core/  ←  features/*/infrastructure/  ←  features/*/di/  ←  features/*/presentation/  ←  app/ (composition root)
(most inner)                                                               (most outer)
```
`features/*/domain/` importa solo `shared/` + `freezed_annotation` (Rule 1) — no depende de `core/`. Las features importan providers de `core/` desde su `di/`.

### What is a Composition Root?

It is the app's **entry point** where the dependency graph is built. In this Flutter project, the composition root lives in `lib/app/di/`. Feature `di/` folders wire domain interfaces to infrastructure implementations, importing providers directly from `core/` (one-way dependency).

In any system with Dependency Injection, **someone** must know all the dependencies to build them. That someone is the Composition Root. It is intentionally "dirty" — it knows all layers so it can join them together.

### Why does this NOT violate Clean Architecture?

Clean Architecture says: **the direction of the dependencies** must go from the outside in. The source code of inner layers must not mention outer layers.

```
Inner layer (domain/)  →  does NOT mention outer layers  ✅
Outer layer (app/)  →  DOES mention inner layers  ✅ (core/ NO importa features/app — Rule 14)
```

`app/` is the **most outer layer** — it may mention anything because there is nothing further out that could depend on it incorrectly. `core/` is **shared infrastructure**: it imports only `shared/` and must NEVER import `features/` or `app/` (Rule 14).

The rule is: **what cannot happen** is `domain/` importing `app/` or `core/`. That does break Clean Architecture. But outer layers importing `domain/` is the natural flow: the outer knows the inner.

### Definition of the key concepts

#### `shared/` — Enterprise Business Rules (most inner layer)

Contains the business rules **shared by the whole app**. It does not depend on Flutter, databases, or any specific feature.

| What goes here | Concrete example |
|-------------|-----------------|
| Abstract interfaces | `ITokenStore`, `IConnectivityChecker`, `ICredentialStore`, `ITokenVerifier`, `IPasswordHasher`, `IPatientInfoStore`, `IClinicalHistoryReader/Writer/Store`, `IUseCase<Input, Output>` |
| Error types | `AppError`, `Result<T>`, `guard()` (localization happens in `l10n/error_localizer.dart`) |
| Shared models | `PatientEntity`, `ClinicalHistoryEntity` + 6 sub-entities |
| Online-first helper | `online_first.dart` |

**Rule:** `shared/` must NOT import `core/`, `features/`, `app/`, `l10n/`, or `package:flutter/`. It may import the Dart SDK and pure annotation packages (e.g. `freezed_annotation`) only.

#### `core/` — Interface Adapters (shared infrastructure)

Concrete service implementations that **several features can use**. It knows `shared/` but NOT `features/` or `app/`.

| What goes here | Concrete example |
|-------------|-----------------|
| HTTP client | `DioWrapper`, `IDioWrapper`, `HttpResponse` in `core/network/dio/` |
| Database | `AppDatabase`, `IAppDatabase`, `ISembastDb` in `core/database/` |
| Auth services | `SecureTokenStore`, `JwtWrapper`, `JwtTokenExpiryChecker`, `AuthObserver` in `core/services/auth/` |
| Connectivity | `InternetService`, `IInternetService` in `core/network/connectivity/` |
| Security | `CertificatePinner` in `core/network/security/` |
| Storage | `SecureStorageWrapper` in `core/services/storage/` |
| Device | `PathProviderWrapper`, `JailbreakDetectionWrapper` in `core/services/device/` |
| Crypto | `BcryptWrapper` in `core/services/crypto/` |

**Rule:** `core/` may import `shared/`, but NEVER `features/` or `app/`.

#### `features/` — Application Business Rules + Interface Adapters + UI

Each feature is an **autonomous module** with its own sub-layers:

| Sub-layer | Role | Imports from |
|---------|-----|-----------|
| `features/*/domain/` | Feature business rules (use cases, entities, interfaces, value objects) | `shared/`, `freezed_annotation`, own domain |
| `features/*/infrastructure/` | Implementations of the domain interfaces | `domain/`, `core/`, `shared/` |
| `features/*/di/` | Feature wiring (Riverpod providers) | `core/`, `shared/`, own `domain/` + `infrastructure/` (never `presentation/`) |
| `features/*/presentation/` | Feature UI (screens, widgets, notifiers) | `../di/`, `../domain/`, `shared/`, `design_system/`, `l10n/` |
| `features/*/spec/` | SDD artifacts (`spec.md`, `domain.md`, `contracts.md`, `bdd.feature`, `tests.md`, `tasks.md`; features built with spec-dev also have `generated_api_contract.md`) | — |

**Rule:** A feature NEVER imports from another feature. Each feature is independent.

#### `app/` — Composition Root (most outer layer)

`lib/app/` is the application composition root. It knows ALL layers because it wires them together:

| What goes here | Concrete example |
|-------------|-----------------|
| Composition root | `app/di/network/dio_overrides.dart` + feature `di/` wiring (imports from `core/` directly) |
| Dio providers | `core/network/dio/dio_providers.dart` → `authDioProvider` + `httpServiceProvider` |
| Auth interceptor wiring | `app/di/network/auth_interceptor_impl.dart` → `AuthInterceptorImpl` |
| Router provider | `app/di/router/router_provider.dart` → `goRouterProvider` |
| Auth observer | `app/di/auth/auth_observer_provider.dart` → `authenticationObserverProvider` |
| Routing definitions | `shared/router/app_route.dart`, `app/router/app_router.dart`, `app/router/guards/auth_guard.dart` |
| Initialization | `app/app_initializer.dart` → platform config + jailbreak check |

**Rule:** `app/` may import any `lib/` folder. No lower layer imports `app/` — features import the providers they need directly from their `core/` source files, and define their own wiring in `features/*/di/` (Rule 11).

**Global provider access from features:** features import the shared providers they need directly from their `core/` source files (e.g. `core/network/dio/dio_providers.dart`, `core/services/auth/token_providers.dart`), and define their own wiring in `features/*/di/`.

```dart
// Global providers come from core/ source files (never from app/):
// core/network/dio/dio_providers.dart                   → authDioProvider, httpServiceProvider
// core/network/connectivity/connectivity_providers.dart → internetServiceProvider, connectivityCheckerProvider
// core/services/auth/token_providers.dart               → tokenStoreProvider, tokenVerifierProvider,
//                                                         credentialStoreProvider, jwtWrapperProvider, secureStorageProvider
// core/services/crypto/password_hasher_provider.dart     → passwordHasherProvider
// core/config/environment_provider.dart                  → environmentProvider
// core/database/app_database_provider.dart               → appDatabaseProvider
// core/database/tables/*_providers.dart                  → clinicalHistoryStoreProvider, patientInfoStoreProvider
// core/services/logging/logging_providers.dart           → loggerProvider
// core/services/device/                                  → pathProviderProvider, flutterJailbreakDetectionProvider
// (goRouterProvider vive en app/ — las features nunca lo importan; usan el seam IAppNavigator)
```

| Provider | Type | Provider location |
|---|---|---|
| `authDioProvider` | `IDioWrapper` | `core/network/dio/dio_providers.dart` |
| `httpServiceProvider` | `IDioWrapper` | `core/network/dio/dio_providers.dart` |
| `goRouterProvider` | `GoRouter` | `app/di/router/router_provider.dart` |
| `authenticationObserverProvider` | `IAuthenticationObserver` | `app/di/auth/auth_observer_provider.dart` |
| `tokenStoreProvider` | `ITokenStore` | `core/services/auth/token_providers.dart` |
| `tokenVerifierProvider` | `ITokenVerifier` | `core/services/auth/token_providers.dart` |
| `credentialStoreProvider` | `ICredentialStore` | `core/services/auth/token_providers.dart` |
| `jwtWrapperProvider` | `IJwtWrapper` | `core/services/auth/token_providers.dart` |
| `secureStorageProvider` | `ISecureStorageWrapper` | `core/services/auth/token_providers.dart` |
| `appDatabaseProvider` | `IAppDatabase` | `core/database/app_database_provider.dart` |
| `clinicalHistoryStoreProvider` | `IClinicalHistoryStore` | `core/database/tables/clinical_history_providers.dart` |
| `patientInfoStoreProvider` | `IPatientInfoStore` | `core/database/tables/patient_info_providers.dart` |
| `passwordHasherProvider` | `IPasswordHasher` | `core/services/crypto/password_hasher_provider.dart` |
| `connectivityCheckerProvider` | `IConnectivityChecker` | `core/network/connectivity/connectivity_providers.dart` |
| `internetServiceProvider` | `IInternetService` | `core/network/connectivity/connectivity_providers.dart` |
| `environmentProvider` | `AppEnvironment` | `core/config/environment_provider.dart` |
| `pathProviderProvider` | `IPathProviderWrapper` | `core/services/device/path_provider_provider.dart` |
| `flutterJailbreakDetectionProvider` | `IJailbreakDetectionWrapper` | `core/services/device/jailbreak_provider.dart` |

Feature providers live in the feature itself:

| Provider | Type | Provider location |
|---|---|---|
| `authProvider` | `AuthState` (Notifier) | `features/auth/presentation/notifiers/auth_notifier.dart` |
| `authRemoteDatasourceProvider` | `IAuthRemoteDatasource` | `features/auth/di/auth_provider.dart` |
| `localAuthDatasourceProvider` | `ILocalAuthDatasource` | `features/auth/di/auth_provider.dart` |
| `authRepositoryProvider` | `IAuthRepository` | `features/auth/di/auth_provider.dart` |
| `localAuthRepositoryProvider` | `ILocalAuthRepository` | `features/auth/di/auth_provider.dart` |
| `loginUseCaseProvider` | `LoginUseCase` | `features/auth/di/auth_provider.dart` |
| `clearSessionUseCaseProvider` | `ClearSessionUseCase` | `features/auth/di/auth_provider.dart` |
| `restoreSessionUseCaseProvider` | `RestoreSessionUseCase` | `features/auth/di/auth_provider.dart` |
| `resetAccountUseCaseProvider` | `ResetAccountUseCase` | `features/auth/di/auth_provider.dart` |
| `handle401UseCaseProvider` | `Handle401UseCase` | `features/auth/di/auth_provider.dart` |
| `_refreshTokenUseCaseProvider` / `_credentialLoginUseCaseProvider` (private) | `RefreshTokenUseCase` / `CredentialLoginUseCase` | `features/auth/di/auth_provider.dart` |
| `rememberMeProvider` | `bool` (Notifier) | `features/auth/presentation/notifiers/remember_me_provider.dart` |
| `_clinicalHistoryRemoteDatasourceProvider` (private) | `IClinicalHistoryRemoteDatasource` | `features/clinical_history/di/clinical_history_provider.dart` |
| `_clinicalHistoryLocalDatasourceProvider` (private) | `IClinicalHistoryLocalDatasource` | `features/clinical_history/di/clinical_history_provider.dart` |
| `clinicalHistoryRepositoryProvider` | `IClinicalHistoryRepository` | `features/clinical_history/di/clinical_history_provider.dart` |
| `loadClinicalHistoriesUseCaseProvider` | `LoadClinicalHistoriesUseCase` | `features/clinical_history/di/clinical_history_provider.dart` |
| `refreshClinicalHistoriesUseCaseProvider` | `RefreshClinicalHistoriesUseCase` | `features/clinical_history/di/clinical_history_provider.dart` |
| `clinicalHistoryNotifierProvider` | `ClinicalHistoryState` (Notifier) | `features/clinical_history/presentation/notifiers/clinical_history_notifier.dart` |
| `clinicalHistoryRefreshErrorProvider` | `AppError?` (Notifier, UI-state) | `features/clinical_history/presentation/notifiers/clinical_history_refresh_error_provider.dart` |

#### `design_system/` — UI primitives

Reusable visual components with no business logic.

| What goes here | Concrete example |
|-------------|-----------------|
| Theme | `AppColors` (incl. semantic `success`/`warning`), `AppTheme` |
| Components | `LoadingIndicator`, `EmptyState`, `ErrorState`, `InfoChip`, `SkeletonList` |
| UI formatters | `utils/app_formatters.dart` (`formatClinicalDate`, `formatBytes`) |

**Rule:** Only imports Flutter (plus `intl` for locale-aware date/byte formatting). Does not import `core/`, `shared/`, or `features/`.

#### `l10n/` — Internationalization

Translated text keys (EN/ES) used by the whole app.

The `.arb` files are the source of truth:
- `app_en.arb` — English keys
- `app_es.arb` — Spanish keys

The `.dart` files (`app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_es.dart`) are generated automatically with `flutter gen-l10n`.

**Flow for adding or modifying text:**
1. Edit `app_en.arb` and `app_es.arb`
2. Run `flutter gen-l10n`
3. Use `AppLocalizations.of(context)!.key` in the screens

**Rule:** Only imports Flutter. Screens access it via `AppLocalizations.of(context)!`.

---

## Clean architecture feature first

This project follows a Feature-First Clean Architecture pattern for medium-to-large apps. Instead of grouping files strictly by their technical layer at the root level, the codebase is highly modularized around business capabilities (Features). This ensures high maintainability, scalability, and clear boundaries for development, testing, and specification-driven development.

### 1. The `features/` Directory

Each feature operates as an autonomous module containing its own lifecycle and architectural layers:

- `domain/` (Core Business Logic): The completely isolated layer that defines the business rules. It contains enterprise Entities, value objects, abstract contracts for data sources and repositories, and specific business orchestrators (Use Cases). It remains independent of Flutter and of any feature outer layer — it imports only `shared/` (+ `freezed_annotation`) and its own domain files.

- `infrastructure/` (Data & External Integrations): Implements the contracts defined in the Domain layer. It handles raw data fetching via concrete Datasources (REST APIs, Local DBs), maps external data structures into Domain Entities using Mappers (DTO → Entity), and coordinates data flow through Repository implementations.

- `di/` (Dependency Injection — Wiring): Feature-specific Riverpod providers that wire domain interfaces to infrastructure implementations. This is a **peer** of the other layers, not a subfolder of `presentation/`, because it knows about **all** layers: imports `core/`, `domain/`, and `infrastructure/`, but **never** imports `presentation/`. The dependency direction is `presentation/ → di/ → domain/ + infrastructure/ + core/`.

- `presentation/` (UI & State Management): Manages how the feature is displayed and how users interact with it. It contains Screens (views), atomic Widgets, and State Notifiers (`Notifier` + `State`). The **only** import toward other feature layers is `presentation/notifiers/ → di/` (notifiers consume providers from `di/`). Feature *wiring* providers live in `di/`; `presentation/notifiers/` holds the state notifiers themselves (which are `@riverpod` classes, e.g. `ClinicalHistoryNotifier`) and UI-state notifiers (e.g. `rememberMeProvider`).

- `spec/` (Specification-Driven Development - SDD): The source of truth for the feature's requirements. It centralizes BDD Gherkin scenarios (`.feature`), functional contracts, API schemas, and task checklists, serving as the blueprint for both automated tests and implementation.

```bash
├── features
│ └── auth
│     ├── di/              ← Peer layer (WIRING): imports core/ + domain/ + infrastructure/
│     │   ├── auth_provider.dart        ← @riverpod providers (datasources, repository, use cases)
│     │   └── auth_provider.g.dart      ← generated by riverpod_generator
│     ├── domain/          ← Innermost layer (BUSINESS): 0 imports from outer layers
│     │   ├── datasources
│     │   │   ├── i_auth_remote_datasource.dart
│     │   │   └── i_local_auth_datasource.dart
│     │   ├── entities
│     │   │   ├── login_response_entity.dart   (@freezed)
│     │   │   ├── token_entity.dart            (@freezed)
│     │   │   └── *.freezed.dart               ← generated by freezed
│     │   ├── repositories
│     │   │   ├── i_auth_repository.dart
│     │   │   └── i_local_auth_repository.dart
│     │   ├── usecases
│     │   │   ├── clear_session_usecase.dart
│     │   │   ├── credential_login_usecase.dart
│     │   │   ├── handle_401_usecase.dart
│     │   │   ├── login_usecase.dart
│     │   │   ├── refresh_token_usecase.dart
│     │   │   └── restore_session_usecase.dart
│     │   └── value_objects
│     │       ├── email.dart
│     │       ├── password.dart
│     │       └── password_hash.dart
│     ├── infrastructure/  ← Outer layer (IMPLEMENTS): imports domain/ + core/ + shared/
│     │   ├── datasources
│     │   │   ├── auth_datasource_impl.dart
│     │   │   └── local_auth_datasource_impl.dart
│     │   ├── dtos
│     │   │   ├── *_dto.dart       ← @freezed + fromJson/toJson (@JsonSerializable)
│     │   │   ├── *_dto.freezed.dart
│     │   │   └── *_dto.g.dart
│     │   ├── mappers
│     │   │   └── auth_mapper.dart
│     │   └── repositories
│     │       ├── auth_local_repository_impl.dart
│     │       └── auth_remote_repository_impl.dart
│     ├── presentation/    ← Outer layer (UI): imports di/
│     │   ├── notifiers
│     │   │   ├── auth_notifier.dart   ← @Riverpod(keepAlive: true) Notifier
│     │   │   ├── auth_notifier.g.dart
│     │   │   ├── auth_state.dart      ← @freezed sealed class
│     │   │   ├── auth_state.freezed.dart
│     │   │   └── remember_me_provider.dart ← NotifierProvider<bool> (UI state)
│     │   ├── screens
│     │   │   └── login_screen.dart
│     │   └── widgets
│     │       ├── email_form_field.dart
│     │       ├── login_button.dart
│     │       └── password_form_field.dart
│     └── spec
│         ├── bdd.feature
│         ├── contracts.md
│         ├── domain.md
│         ├── spec.md
│         ├── tasks.md
│         └── tests.md
```

#### Why `di/` is at feature root, not inside `presentation/`

Many Clean Architecture tutorials place DI inside `presentation/`, but in enterprise Flutter projects `di/` is a **peer layer** alongside `domain/`, `infrastructure/`, and `presentation/`. Here is why:

**The import direction proves it.** Take the auth feature as example:

```
lib/features/auth/
│
├── di/
│   └── auth_provider.dart
│         │
│         ├──▶ core/ source files            (global providers: authDioProvider,
│         │                                      appUriesProvider, tokenStoreProvider, ...)
│         ├──▶ ../domain/datasources/i_auth_remote_datasource.dart
│         ├──▶ ../domain/datasources/i_local_auth_datasource.dart
│         ├──▶ ../domain/repositories/i_auth_repository.dart
│         ├──▶ ../domain/usecases/*.dart
│         ├──▶ ../infrastructure/datasources/*_impl.dart
│         └──▶ ../infrastructure/repositories/auth_remote_repository_impl.dart
│
│       (does NOT import presentation/ — 0 paths toward ../presentation/)
│
└── presentation/
    └── notifiers/
        └── auth_notifier.dart
              │
              └──▶ imports ../../di/auth_provider.dart   ← ÚNICA flecha hacia di/
```

`auth_provider.dart` in `di/` imports from `core/` source files (global providers), `../domain/` and `../infrastructure/`, but **never** from `../presentation/`. In contrast, `auth_notifier.dart` in `presentation/` imports from `../../di/auth_provider.dart` — the direction is `presentation → di`, not the other way around.

If `di/` were inside `presentation/`, the semantics would be misleading: it would suggest that wiring is a "kind of UI", when in reality it is the layer that orchestrates all the others. Placing it as a peer of `domain/`, `infrastructure/` and `presentation/` reflects its true architectural role.

| Layer | Imports from | What it contains |
|------|-----------|----------------|
| `domain/` | nothing external | Entities, interfaces, value objects, use cases |
| `infrastructure/` | `domain/` + `core/` + `shared/` | Concrete implementations, DTOs, mappers |
| `di/` | `core/` (global providers) + `domain/` + `infrastructure/` | Providers that WIRE (never UI) |
| `presentation/` | `di/` + widgets/screens | Notifiers, screens, widgets |

### 2. The app/, core/ and shared/ Directories

Cross-cutting concerns, global configurations, and reusable utilities that are shared across multiple features are centralized here to avoid duplication:

- `app/`: Application composition root — `di/network/` (Dio providers + auth interceptor impl + `dioOverrides` seam), `di/router/` (`goRouterProvider`), `di/auth/` (`authenticationObserverProvider`), `router/` (routes, guard), `widgets/connectivity_banner.dart`, `app_initializer.dart`.

- `core/`: Pure infrastructure — `database/` (AES-256-CBC encrypted sembast), `network/` (Dio wrapper, connectivity, interceptors, timeouts, retry, security, utils), `services/` (auth, crypto, device, storage), `config/` (AppEnvironment).

- `core/database/`: Centralized persistence layer configuration (AES-256-CBC encrypted sembast) accessible by any datasource via `appDatabaseProvider`. It exposes `app_database.dart`, `sembast_db_wrapper.dart` (`ISembastDb`), `tables/` (clinical_history, patient_info), `serializers/`.

- `shared/error/`: `AppError` sealed hierarchy (ApiError, NetworkError, ServerUnreachableError, TimeoutError, ValidationError, UnexpectedError, DeviceSecurityError), `Result<T>` with `guard()`. Localization happens in `l10n/error_localizer.dart`.

- `core/network/`: Network layer — Dio wrapper (`dio/`), connectivity checkers (`connectivity/`), interceptors (`interceptors/`), per-endpoint timeout configuration (`timeouts/`), retry logic (`retry/`), certificate pinning (`security/`).

- `core/services/`: Shared services organized by domain: `auth/` (token, JWT, credentials, observer), `crypto/` (bcrypt hashing), `device/` (path_provider, jailbreak detection), `logging/` (ILogger/DevLogger observability), `storage/` (secure_storage).

- `shared/`: Pure domain abstractions — `error/` (AppError incl. `TimeoutError`, Result, guard), `exceptions/` (exception classes), `interfaces/` (ICredentialStore, IConnectivityChecker, ITokenStore, ITokenVerifier, IPasswordHasher, IPatientInfoStore, IClinicalHistoryReader/Writer/Store, IAppNavigator, ILogger), `models/` (shared domain entities: PatientEntity, ClinicalHistoryEntity + sub-entities), `functions/` (online_first — online-first; the helper owns all boundary guarding and reports DataOrigin remote/cache).

```bash
lib/
├── main.dart
│
├── app/                                ← Composition root
│   ├── app_initializer.dart            ← Platform config + jailbreak check
│   ├── di/
│   │   ├── auth/
│   │   │   └── auth_observer_provider.dart  ← authenticationObserverProvider
│   │   ├── network/
│   │   │   ├── auth_interceptor_impl.dart
│   │   │   └── dio_overrides.dart           ← binds authInterceptorProvider seam (merged in main.dart)
│   │   └── router/
│   │       ├── go_router_navigator.dart ← GoRouterNavigator (única impl de IAppNavigator)
│   │       ├── router_overrides.dart    ← routerOverrides(): binds appNavigatorProvider seam
│   │       └── router_provider.dart     ← goRouterProvider
│   └── router/
│       ├── app_router.dart             ← appRoutes()
│       └── guards/
│           └── auth_guard.dart         ← AuthGuard (redirect logic)
│
├── core/                               ← Pure infrastructure
│   ├── config/                         ← app_environment.dart, environment_provider.dart
│   ├── database/                       ← AppDatabase (sembast, AES-256-CBC), tables/, serializers/
│   ├── network/                        ← dio/, connectivity/, contracts/, interceptors/, retry/, security/, timeouts/, utils/
│   └── services/                       ← auth/, crypto/, device/, logging/, storage/
│
├── design_system/                      ← Theme (AppColors, AppTheme), components (LoadingIndicator)
│
├── features/
│   ├── auth/                           ← di/, domain/, infrastructure/, presentation/, spec/
│   └── clinical_history/               ← di/, domain/, infrastructure/, presentation/, spec/
│
├── l10n/                               ← app_en.arb, app_es.arb, app_localizations*.dart
│
└── shared/                             ← Pure domain abstractions
    ├── error/                          ← AppError sealed hierarchy, Result<T>, guard() (localizeError lives in l10n/)
    ├── exceptions/                     ← ApiException, NoConnectionException, DeviceSecurityException, etc.
    ├── functions/                      ← online_first.dart
    ├── interfaces/                     ← IConnectivityChecker, ICredentialStore, ITokenStore, ITokenVerifier, IPasswordHasher, IPatientInfoStore, IClinicalHistoryReader/Writer/Store, IAppNavigator, ILogger, IUseCase
    ├── router/                         ← AppRoute enum (typed route registry, pure Dart)
    └── models/                         ← PatientEntity, ClinicalHistoryEntity + sub-entities
```

### 3. Startup — main.dart + AppInitializer

Platform configuration is handled in `lib/app/app_initializer.dart` and invoked from `main.dart`.

```dart
// main.dart
void main({List<Override> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  AppInitializer.configurePlatform();
  runApp(
    ProviderScope(
      overrides: [...dioOverrides(), ...routerOverrides(), ...overrides],
      child: const TudesarrolladorApp(),
    ),
  );
}
```

`TudesarrolladorApp` (`ConsumerStatefulWidget`) runs the startup sequence in `initState`:

```dart
Future<void> _init() async {
  _assertDiSeamsBound();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS)) {
    final result = await AppInitializer.checkJailbreak(
      detection: ref.read(flutterJailbreakDetectionProvider),
    );
    await result.fold<Future<void>>(
      onSuccess: (_) async {},
      onFailure: (error) async {
        ref.read(loggerProvider).error(
              '[app] security check failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        if (error is DeviceSecurityError && mounted) {
          setState(() => _securityBlocked = true);
        }
      },
    );
    if (_securityBlocked) return;
  }
  await ref.read(authProvider.notifier).restoreSession();
  if (mounted) setState(() => _initialized = true);
}

void _assertDiSeamsBound() {
  ref.read(authInterceptorProvider);
  ref.read(appNavigatorProvider);
}
```

A confirmed `DeviceSecurityError` at boot renders `DeviceSecurityBlockedScreen` (hard-stop). A global `ref.listen<AuthState>` shows a localized `SnackBar` for any `AuthFailure`. While `_initialized == false`, the app shows a `MaterialApp` with a `LoadingIndicator`. After initialization it builds `MaterialApp.router` with `ref.watch(goRouterProvider)`.

#### Jailbreak detection — implemented

The jailbreak check **is implemented** (in `lib/app/app_initializer.dart` + `lib/core/services/device/`):

```dart
// lib/app/app_initializer.dart
class AppInitializer {
  static Future<Result<void>> checkJailbreak({
    required IJailbreakDetectionWrapper detection,
  }) {
    return guard(() async {
      if (await detection.isJailbroken()) {
        throw const DeviceSecurityException();
      }
    });
  }

  static void configurePlatform() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
```

The detection is wrapped by `JailbreakDetectionWrapper` (`core/services/device/jailbreak_detection_wrapper.dart`, interface `IJailbreakDetectionWrapper`) over the `flutter_jailbreak_detection_plus` package and exposed via `flutterJailbreakDetectionProvider` (`core/services/device/jailbreak_provider.dart`).

| Scenario | `kIsWeb` | `defaultTargetPlatform` | Runs check? |
|-----------|----------|------------------------|-----------------|
| Real Android/iOS | `false` | `android` / `iOS` | ✅ Yes |
| macOS desktop (dev, integration) | `false` | `macOS` | ❌ No |
| Web | `true` | — (short-circuit) | ❌ No |
| Unit tests (mock) | `false` | `android` (default) | ✅ Yes (injected mock) |

**Enterprise rule:** The jailbreak check only runs on the platforms where it makes sense (Android/iOS). On the rest it is skipped silently. The plugin is never called on unsupported platforms, removing the need to catch `MissingPluginException`.

### 4. Clean Architecture Layer Mapping

This project follows a **4-layer Clean Architecture** (not 3). Each `lib/` directory maps to a specific architectural layer:

```
1. Enterprise Business Rules   → lib/shared/
2. Application Business Rules  → lib/features/*/domain/
3. Interface Adapters          → lib/features/*/infrastructure/ + lib/core/
4. Frameworks & Drivers        → lib/app/ + lib/design_system/ + lib/l10n/ + lib/features/*/presentation/
```

| `lib/` directory | Clean Architecture Layer | Role | Can import from |
|---|---|---|---|
| `shared/` | **Enterprise Business Rules** | Global business rules: `AppError`, `Result<T>`, `guard()`, shared interfaces (`ITokenStore`, `IConnectivityChecker`, `ICredentialStore`, ...), shared models (`PatientEntity`, `ClinicalHistoryEntity`), exceptions (`ApiException`, `DeviceSecurityException`), `online_first` | Only `shared/` |
| `features/*/domain/` | **Application Business Rules** | Feature-specific business rules: use cases (`LoginUseCase`, `RestoreSessionUseCase`), entities (`TokenEntity`), repository interfaces (`IAuthRepository`), value objects (`Email`, `Password`) | `shared/` |
| `features/*/infrastructure/` | **Interface Adapters** | Concrete implementations of the domain interfaces: datasources, repositories, mappers, DTOs | `features/*/domain/`, `core/`, `shared/` |
| `core/` | **Interface Adapters** (shared) | Infrastructure SHARED between features: HTTP client (`DioWrapper`), database (`AppDatabase`), services (`SecureTokenStore`, `JwtWrapper`, `SecureStorageWrapper`), connectivity (`InternetService`), security (`CertificatePinner`) | `shared/`, `core/` (NEVER `features/`, NEVER `app/`) |
| `features/*/di/` | **Wiring** | Riverpod providers that wire domain interfaces to infrastructure implementations | `core/` (global providers), own `domain/` + `infrastructure/`, `shared/` |
| `features/*/presentation/` | **Frameworks & Drivers** | Feature-specific UI: screens, widgets, notifiers (Riverpod). Notifiers are the layer that wires the use cases via `di/` | `features/*/di/`, own `domain/`, `shared/`, `design_system/`, `l10n/` |
| `app/` | **Frameworks & Drivers** (Composition Root) | Outer layer. Contains `di/` (DI seams: `dio_overrides.dart`, `router_overrides.dart`, `auth_observer_provider.dart`), `router/` (goRouter, guard, routes), `app_initializer.dart` | Any `lib/` |
| `design_system/` | **Frameworks & Drivers** | UI primitives with no business logic: theme (`AppColors`, `AppTheme`), reusable components (`LoadingIndicator`, `EmptyState`, `ErrorState`, `InfoChip`, `SkeletonList`), locale-aware formatters (`utils/app_formatters.dart`) | Only Flutter (+ `intl`) |
| `l10n/` | **Frameworks & Drivers** | Internationalization: `AppLocalizations` with EN/ES keys for labels and error messages | Only Flutter |

#### What can each layer import? (with real project paths)

```
┌──────────────────────────────────────────────────────────┐
│                      app/di/ (outer)                      │
│  lib/app/di/network/dio_overrides.dart                    │
│  lib/app/di/router/router_provider.dart                    │
│                                                           │
│  EACH FEATURE DI IMPORTS DIRECTLY:                        │
│  ✅ core/* source files  → all shared providers           │
│     (authDioProvider, appDatabaseProvider,                 │
│      clinicalHistoryStoreProvider, patientInfoStoreProvider│
│      tokenStoreProvider, credentialStoreProvider,          │
│      tokenVerifierProvider, passwordHasherProvider,        │
│      connectivityCheckerProvider, internetServiceProvider, │
│      loggerProvider)                                       │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼

┌──────────────────────────────────────────┐
│            features/auth/di/              │
│  lib/features/auth/di/auth_provider.dart  │
│                                           │
│  IMPORTS DIRECTLY:                        │
│  ✅ core/* source files  → all shared providers           │
│  ✅ ../domain/datasources/*               │
│  ✅ ../domain/repositories/*              │
│  ✅ ../domain/usecases/*                  │
│  ✅ ../infrastructure/datasources/*       │
│  ✅ ../infrastructure/repositories/*      │
│                                           │
│  ❌ features/X/ (another feature)         │
│     auth_provider.dart does NOT import    │
│     another feature's di/ because:        │
│     → features are autonomous modules     │
│     → If auth depended on clinical_hist,  │
│       auth could not be tested without    │
│       setting up clinical_history          │
│     → If clinical_history is removed,     │
│       auth breaks                         │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│              core/di/                     │
│  lib/core/services/auth/token_providers   │
│                                           │
│  IMPORTS:                                 │
│  ✅ shared/ → token_providers.dart        │
│               import '.../shared/interfaces'│
│               (ITokenStore, ITokenVerifier,│
│                ICredentialStore)           │
│                                           │
│  ❌ features/ → GRAVE VIOLATION           │
│     token_providers.dart NEVER imports    │
│     features/auth/ because:               │
│     → core/ is INFRASTRUCTURE             │
│     → If core imported features/auth/:    │
│       core/ breaks if the feature is      │
│       removed. core/ MUST be reusable     │
│       in any app, without knowing         │
│       the features of this app.           │
│                                           │
│  ✅ core/  → may import another core/     │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│            shared/interfaces/             │
│  lib/shared/interfaces/i_token_store.dart  │
│                                           │
│  ✅ shared/ → may import shared/          │
│               (only dart, no project      │
│                imports)                   │
│                                           │
│  ❌ core/     → FATAL VIOLATION           │
│     shared/ NEVER imports core/ because:  │
│     → shared/ is ENTERPRISE BUSINESS      │
│       RULES (most inner layer)            │
│     → core/ is Interface Adapters         │
│       (outer layer)                       │
│     If shared/ imported core/:            │
│     - You could not share shared/         │
│       between apps using different        │
│       storage (Hive, SQLite)              │
│     - The abstraction would depend        │
│       on the concrete implementation      │
│       (Dependency Inversion violation)    │
│                                           │
│  ❌ features/ → DOUBLE VIOLATION          │
│     shared/ NEVER imports features/       │
└──────────────────────────────────────────┘
```

#### Summary of violations with real paths

| Violation | Path | What would happen? |
|-----------|------|---------------|
| `core/ → features/` | `core/network/` trying to import `features/auth/...` | `core/` is shared infrastructure. If it imported a feature, removing that feature would break `core/`. |
| `shared/ → core/` | `shared/interfaces/i_token_store.dart` importing `core/services/storage/secure_storage_wrapper.dart` | `ITokenStore` is an abstraction. If it imported `SecureStorageWrapper` (a concrete implementation in core/), the abstraction would depend on the concretion. This violates the Dependency Inversion Principle: "abstractions should not depend on details". |
| `shared/ → features/` | `shared/interfaces/` importing `features/auth/domain/entities/token_entity.dart` | The Enterprise Business Rules (`shared/`) cannot know the Application Business Rules of a specific feature. `ITokenStore` must work for ANY token, not just those of the auth feature. |
| `features/X/ → features/Y/` | `features/auth/di/` importing `features/clinical_history/di/` | Features are autonomous modules. If auth depended on clinical_history, auth could not be tested in isolation, nor could clinical_history be removed without breaking auth. |

#### The practical consequence: two Dio providers

`authDioProvider` provides a `DioWrapper` **without** an auth interceptor — used exclusively by `AuthRemoteDatasource` for login/refresh, where no interception is needed. `httpServiceProvider` provides a `DioWrapper` **with** the auth interceptor (401 retry + force logout) — used by features that make authenticated HTTP calls.

Both are built by the same internal factory in `core/network/dio/dio_providers.dart` and receive `ConnectionProfile.standard` + `CertificatePinner`. The interceptor is added only to `httpServiceProvider` (via the `authInterceptorProvider` seam bound by `app/di/network/dio_overrides.dart`).

This separation avoids Riverpod dependency cycles and keeps Clean Architecture dependency rules intact: each layer imports only what it needs.

#### The complete chain: how the layers connect

```
presentation/ (notifier)
     │  ref.read(loginUseCaseProvider)  ← di/ exposes the use case
     ▼
features/*/di/
     │  LoginUseCase(repository: ...)  ← di/ wires use case + repository
     ▼
domain/usecases/login_usecase.dart
     │  _repository.login(...)  ← use case calls the REPOSITORY (interface)
     ▼
domain/repositories/i_auth_repository.dart
     ▲  (interface — the use case knows ONLY the interface)
     │
     │  AuthRemoteRepositoryImpl implements IAuthRepository  ← the implementation lives in infra
     ▼
infrastructure/repositories/auth_remote_repository_impl.dart
     │  _remoteDatasource.login(...)  ← implementation calls the DATASOURCE
     ▼
infrastructure/datasources/auth_datasource_impl.dart
     │  _dio.post(...)  ← datasource calls HTTP (core/)
     ▼
core/network/dio/dio_wrapper.dart
```

**It is always like this** and it cannot be any other way for two reasons:

| Rule | Why? |
|-------|-----------|
| The UI **never** calls a datasource directly | If the UI called `DioWrapper.post()` directly, any backend change would force a UI change. The use case protects it. |
| The use case **never** calls a datasource directly | The use case knows the repository interface (`IAuthRepository`), it does not know whether the implementation uses REST, GraphQL, SQLite, or a local file. |

**The only exception:**

`features/*/di/` does NOT call anything. Its only job is **wiring**:

```dart
// di/ does not call use cases, it only builds them
@riverpod
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(
  repository: ref.watch(authRepositoryProvider),
  sessionRepository: ref.watch(localAuthRepositoryProvider),
  passwordHasher: ref.watch(passwordHasherProvider),
  tokenStore: ref.watch(tokenStoreProvider),
);

// Nor does it call repositories, it only builds them
final authRepositoryProvider = Provider<IAuthRepository>((ref) =>
    AuthRemoteRepositoryImpl(
      remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    ));
```

**Whoever calls the use cases is the presentation.** `di/` only makes them available. That is the key difference between "wiring" and "executing".

#### The complete import graph (at a glance)

```
app/ (composition root) ◄── imports anything
   ├──▶ features/*  core/  shared/  l10n/  design_system/
   └──▶ go_router confinado aquí (Rule 21); seams: dioOverrides() + routerOverrides()

features/<f>/
   di/            ▶ core/ + shared/ + (own domain/ + infrastructure/)   [NO app/ — R11]
   infrastructure ▶ domain/ + shared/ + core/                            [NO app/ — R5]
   domain/        ▶ shared/                                              [NO core/flutter — R1]
   presentation/  ▶ di/ + domain/ + shared/ + design_system/ + l10n/     [NO infra/core/app — R15]
core/            ▶ shared/                                               [NO features/app — R14]
design_system/   ▶ flutter + intl
l10n/            ▶ flutter
shared/          ▶ — (pure Dart; NO flutter/l10n — R10; barriles R22/23/26)
```

#### Per-layer rules (who can import / who must NOT)

| Layer | Puede importar | Prohibido |
|---|---|---|
| `shared/` | solo `dart:` de la SDK | flutter, l10n, core, app, features (R10) |
| `core/` | `shared/` | features/, app/ (R14) |
| `features/*/domain/` | `shared/` | core, flutter, app (R1) |
| `features/*/infrastructure/` | domain/, `shared/`, `core/` | app/, otras features (R5) |
| `features/*/presentation/` | di/, domain/, `shared/`, `design_system/`, `l10n/` | infrastructure/, core/, app/ (R15) |
| `features/*/di/` | `core/` (providers), `shared/`, internos del feature | app/ (R11), otras features (R5) |
| `app/` | todo | — |
| `design_system/` | flutter, intl | — |
| `l10n/` | flutter | — |
| paquetes externos | solo vía wrappers en `core/` (R6) | directo desde features |

#### The seams that break the dependency cycles

- **`core/` ↔ `features/auth` (ciclo del interceptor):** `core/network/dio/dio_providers.dart` define `authInterceptorProvider` (seam `IAuthInterceptorProvider`, fail-fast) y `httpServiceProvider` lo aplica (`setupAuthInterceptor`). El binding real vive en la composition root: `app/di/network/dio_overrides.dart` → `dioOverrides()` ata el seam a `AuthInterceptorImpl` (que consume `handle401UseCaseProvider`, `authProvider`, `tokenStoreProvider`). Así `core/` nunca importa features (R14).

- **features → navegación (Rules 11/21):** las features nunca importan `go_router` ni `app/`. `IAppNavigator` (shared/interfaces) + `appNavigatorProvider` (core/router, fail-fast) son el seam; `app/di/router/router_overrides.dart` → `routerOverrides()` lo ata a `GoRouterNavigator` (única impl de go_router). Una feature que navega imperativamente re-exporta `appNavigatorProvider` desde su `di/` y usa `ref.read(appNavigatorProvider).go/push(AppRoute.x)`.

- **Boot validation:** ambos seams (`authInterceptorProvider`, `appNavigatorProvider`) se verifican en el boot de `main.dart` (`_assertDiSeamsBound`) — un binding faltante aborta el arranque (fail-fast).

#### What must NEVER happen

| Direction | Why is it wrong? |
|-----------|-------------------|
| `domain/ → core/` | The domain must not know about infrastructure. It breaks business independence. |
| `domain/ → presentation/` | The domain must not know about UI. It breaks domain testability. |
| `infrastructure/ → presentation/` | Infrastructure must not know about UI. |
| `core/ → features/*/domain/` | Core is shared infrastructure; it must not depend on feature-specific business rules. |
| `shared/ → features/*/` | Shared is enterprise rules; it must not depend on specific features. |
| `presentation/ → infrastructure/` | The UI must not import concrete implementations. It must go through `di/` + `domain/` interfaces. |

### 5. Project Architectural Patterns

#### 1. Synchronous Simple (Result\<T\>) — ✅ The main pattern

```bash
Presentation            Domain                Infrastructure          Externo
────────────            ──────                ──────────────          ───────
                  UseCase → IRepository → DatasourceImpl → HTTP/DB
                      ↕                         ↕
Notifier ←────── Result<T> (Success/Failure)  guard() → AppError
                      ↕
Widget ←─────── AuthState.loaded/failure
                      ↕
Navigation (GoRouter via AuthGuard + authenticationObserverProvider)
```

| Who | Representative file | Role |
|-------|----------------------|-----|
| Notifier | `auth_notifier.dart` | Calls the use case, does `fold()` on `Result<T>` |
| UseCase | `login_usecase.dart` | Orchestrates business logic, returns `Result<T>` |
| Repository | `auth_remote_repository_impl.dart` / `auth_local_repository_impl.dart` | Uses `guard()` to capture exceptions → `Result<T>` |
| Datasource | `auth_datasource_impl.dart` | Calls `DioWrapper`, lets exceptions flow |
| Result | `result.dart` | Sealed class `Success<T>` / `Failure<T>` (Either monad) |
| guard | `result_guard.dart` | Captures exception types → typed `AppError` |

**Valid for a big company?** Yes, for these reasons:

| Reason | Explanation |
|-------|-------------|
| **Compile-time safety** | The `Result<T>` type forces the compiler to remember that the operation can fail. No runtime surprises. |
| **Exhaustive sealed class** | Dart 3 `switch` forces covering all `AppError` subtypes. If you add a new error, the compiler tells you where the `case` is missing. |
| **Testability** | `guard()` can be mocked easily. Each layer is tested in isolation. |
| **Offline-first built-in** | `fetchOrFallback()` extends the pattern without breaking it. |

**Enterprise conclusion:** This pattern is exactly what a big company would expect to see. Do not change anything.

#### 2. Logging — observability seam

`loggerProvider` (`Provider<ILogger>` → `DevLogger` over `dart:developer log`) lives in `core/services/logging/logging_providers.dart`. Each feature `di/` re-exports it (e.g. `features/clinical_history/di/clinical_history_provider.dart`), so presentation notifiers can log `technicalMessage`/`stackTrace` without importing `core/` (Rule 15). It is overridable in tests (e.g. `FakeLogger`). For temporary debug output use `debugPrint` and remove before PR.

### Testing Strategy & Structure

The `test/` directory mirrors the application's production code (`lib/`) using a Feature-First Clean Architecture approach. This guarantees that every component has an isolated, predictable testing environment, supplemented by automated behavioral testing and centralized simulation utilities.

- `app/` — Composition root tests: `app_initializer_test.dart`, `di/` (dio provider wiring, keep-alive providers), `router/` (app_router, auth_guard, router_overrides, go_router_deep_link), `environment/`.

- `bdd/` (Acceptance & High-Level Integration): Centralizes executable behavioral tests driven by the Gherkin specifications defined in the feature's `spec/` folder (`auth_bdd_test.dart`, `clinical_history_bdd_test.dart`).

- `features/` (Layer-Isolated Testing): Verifies the implementation details of each decoupled business capability across three distinct scopes: domain, infrastructure and presentation.

- `core/` (Cross-Cutting & Service Testing): Validates common application-wide layers (database, network, services, timeouts, retry, security, connectivity).

- `shared/` (Cross-Cutting & Service Testing): Validates common application-wide layers (error pipeline, exceptions, models, functions).

- `helpers/` (Centralized Test Utilities): `mocks.dart` centralizes reusable test doubles.

- `l10n/`, `design_system/` — localizations and design system component tests.

```bash
.
├── app
│   ├── app_initializer_test.dart
│   ├── di
│   │   ├── dio_provider_auth_interceptor_wiring_test.dart
│   │   ├── keep_alive_providers_test.dart
│   │   ├── seams_boot_test.dart
│   │   └── network
│   │       └── dio_provider_test.dart
│   ├── environment
│   │   └── app_environment_test.dart
│   ├── main_security_gate_test.dart
│   ├── router
│   │   ├── app_router_test.dart
│   │   ├── auth_guard_test.dart
│   │   ├── go_router_deep_link_test.dart
│   │   └── router_overrides_test.dart
│   └── widgets
│       ├── app_error_screen_golden_test.dart
│       ├── app_error_screen_test.dart
│       ├── connectivity_banner_test.dart
│       ├── device_security_blocked_screen_golden_test.dart
│       └── device_security_blocked_screen_test.dart
├── architecture
│   ├── dependency_rules_test.dart
│   ├── error_mapping_consistency_test.dart
│   └── workflow_gates_test.dart
├── bdd
│   ├── auth_bdd_test.dart
│   └── clinical_history_bdd_test.dart
├── core
│   ├── database
│   │   ├── app_database_encrypted_test.dart
│   │   ├── app_database_provider_test.dart
│   │   ├── app_database_reset_test.dart
│   │   ├── app_database_test.dart
│   │   ├── clinical_history_provider_test.dart
│   │   ├── clinical_history_serializer_test.dart
│   │   ├── clinical_history_test.dart
│   │   ├── database_encrypt_test.dart
│   │   ├── patient_info_provider_test.dart
│   │   ├── patient_info_test.dart
│   │   ├── patient_serializer_test.dart
│   │   ├── secure_storage_key_service_test.dart
│   │   └── sembast_codec_test.dart
│   ├── network
│   │   ├── api_endpoints_provider_test.dart
│   │   ├── connectivity
│   │   │   ├── connectivity_providers_test.dart
│   │   │   ├── http_reachability_test.dart
│   │   │   ├── internet_service_test.dart
│   │   │   └── native_socket_reachability_test.dart
│   │   ├── contracts
│   │   │   └── clinical_history_mapper_test.dart
│   │   ├── dio
│   │   │   ├── dio_multipart_builder_test.dart
│   │   │   ├── dio_response_parser_test.dart
│   │   │   ├── dio_wrapper_test.dart
│   │   │   └── http_response_test.dart
│   │   ├── interceptors
│   │   │   └── auth_interceptor_test.dart
│   │   ├── retry
│   │   │   └── retry_policy_test.dart
│   │   ├── security
│   │   │   └── certificate_pinner_test.dart
│   │   ├── timeouts
│   │   │   ├── connection_profile_test.dart
│   │   │   └── endpoint_sla_test.dart
│   │   └── utils
│   │       └── uri_utils_test.dart
│   └── services
│       ├── auth
│       │   ├── auth_observer_test.dart
│       │   ├── jwt_token_expiry_checker_test.dart
│       │   ├── jwt_wrapper_test.dart
│       │   ├── secure_credential_store_test.dart
│       │   ├── secure_token_store_test.dart
│       │   └── token_providers_test.dart
│       ├── crypto
│       │   ├── bcrypt_wrapper_test.dart
│       │   └── password_hasher_provider_test.dart
│       ├── device
│       │   ├── jailbreak_detection_wrapper_test.dart
│       │   ├── jailbreak_provider_test.dart
│       │   ├── path_provider_provider_test.dart
│       │   └── path_provider_wrapper_test.dart
│       ├── logging
│       │   └── dev_logger_test.dart
│       └── storage
│           └── secure_storage_wrapper_test.dart
├── design_system
│   ├── components
│   │   ├── empty_state_test.dart
│   │   ├── error_state_test.dart
│   │   ├── info_chip_test.dart
│   │   ├── loading_indicator_test.dart
│   │   └── skeleton_list_test.dart
│   └── utils
│       └── app_formatters_test.dart
├── features
│   └── auth
│       ├── domain
│       │   ├── auth_entity_test.dart
│       │   ├── auth_usecase_test.dart
│       │   ├── clear_session_usecase_test.dart
│       │   ├── credential_login_usecase_test.dart
│       │   ├── handle_401_usecase_test.dart
│       │   ├── reset_account_usecase_test.dart
│       │   ├── restore_session_usecase_test.dart
│       │   └── value_objects
│       │       ├── email_test.dart
│       │       ├── password_hash_test.dart
│       │       └── password_test.dart
│       ├── infrastructure
│       │   ├── auth_datasource_impl_test.dart
│       │   ├── auth_dto_test.dart
│       │   ├── auth_local_repository_impl_test.dart
│       │   ├── auth_mapper_test.dart
│       │   ├── auth_remote_repository_impl_test.dart
│       │   └── local_auth_datasource_impl_test.dart
│       └── presentation
│           ├── notifiers
│           │   ├── auth_notifier_test.dart
│           │   └── auth_state_test.dart
│           ├── screens
│           │   ├── login_screen_golden_test.dart
│           │   └── login_screen_test.dart
│           └── widgets
│               └── auth_widget_test.dart
│   └── clinical_history
│       ├── domain
│       │   ├── clinical_history_entity_test.dart
│       │   └── clinical_history_usecase_test.dart
│       ├── infrastructure
│       │   ├── clinical_history_local_datasource_impl_test.dart
│       │   ├── clinical_history_remote_datasource_impl_test.dart
│       │   └── clinical_history_repository_impl_test.dart
│       └── presentation
│           ├── notifiers
│           │   ├── clinical_history_notifier_test.dart
│           │   └── clinical_history_state_test.dart
│           ├── screens
│           │   ├── clinical_history_screen_golden_test.dart
│           │   └── clinical_history_screen_test.dart
│           └── widgets
│               ├── clinical_history_card_golden_test.dart
│               └── clinical_history_card_test.dart
├── flutter_test_config.dart       ← loads Roboto font for golden tests
├── helpers
│   └── mocks.dart
├── l10n
│   ├── app_localizations_test.dart
│   └── error_localizer_test.dart
└── shared
    ├── error
    │   ├── app_error_test.dart
    │   ├── result_guard_test.dart
    │   ├── result_test.dart
    │   └── retry_result_test.dart
    ├── exceptions
    │   ├── exceptions_import_test.dart
    │   └── exceptions_test.dart
    ├── functions
    │   └── online_first_test.dart
    ├── router
    │   └── app_route_test.dart
    └── models
        ├── clinical_history
        │   ├── clinical_history_model_test.dart
        │   └── clinical_history_status_test.dart
        └── patient
            └── patient_model_test.dart
```

## Dependencies used

### Result\<T\> — Functional Error Handling Pattern

Now, we go to understand why we use the Functional Programming paradigm for error handling, how the `Result<T>` type is integrated into our **Clean Architecture**, and how you must implement it in your day-to-day development.

#### 1. Why `Result<T>`? (The Problem & The Solution)

In standard Dart, errors are handled using `try-catch` blocks and throwing `Exceptions`. This introduces two major problems in large codebases:
1. **Unpredictability:** A function's signature (e.g., `Future<Result<[EntityName]Entity>> login()`) hides the fact that it can crash. You don't know it throws an exception unless you read its source code or wait for a runtime crash.
2. **Layer Pollution:** `try-catch` blocks end up duplicated everywhere (Datasource, Repository, UseCase, Notifier), breaking Clean Architecture boundaries.

##### The Solution: `Result<T>`
We use `Result<T>` to enforce **Type-Safe Error Handling** via the `Result` type. A `Result` represents a value that can take one of two possible types:
* **`Success (T)`**: Contains the **Success Data** (by convention, the correct side).
* **`Failure`**: Contains the **`AppError`** (by convention, the error side).

By returning `Future<Result<[EntityName]Entity>>`, we force the compiler to remind us that the operation might fail, completely eliminating unexpected runtime crashes due to unhandled exceptions.

```dart
// lib/shared/error/result.dart
sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  });

  bool get isSuccess;
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
  ...
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;
  ...
}
```

#### 2. Core Rule per Layer (The Call-Chain)

To keep the architecture clean, each layer has a strict single responsibility regarding error propagation. **Never break these boundaries.**

| Layer | Architectural Responsibility | Rule |
| :--- | :--- | :--- |
| **`dio_wrapper.dart`** | Network / Core Clients | Throws typed infrastructure exceptions (`ApiException`, `NoConnectionException`, etc.). |
| **Datasource Impl** | External Data Ingestion | Raw call execution only. **No try/catch.** Let exceptions propagate upward. |
| **Repository Impl** | Boundary Adapter | **The Guard.** Captures exceptions and converts them into a `Result<T>`. |
| **Repository Domain** | Contract Definition | Declares strict `Future<Result<T>>` return types. |
| **UseCase** | Business Orchestrator | Passes repository `Result`s through unchanged. **Wraps shared ports** (`shared/interfaces/` returning raw values like `String?`, `bool`, `void`, records) with `guard()`. Zero UI error-handling logic. |
| **Notifier** | Presentation State | **The Consumer.** Calls `.fold()` to transform the `Result` into UI States. **No try/catch.** |

#### 3. How to Use It (Step-by-Step) with examples:

##### Step 1: Catching and Creating the `Result` (Boundary Layer)
`guard()` is the **only** place exceptions are caught. It wraps every fallible boundary: the **Repository** executes the datasource, and the **UseCase** wraps shared ports that return raw values (e.g. `ITokenStore`, `IConnectivityChecker`). If a datasource or port throws, `guard` automatically maps it to a domain `Failure`. For instance:

```dart
lib/features/auth/infrastructure/repositories/auth_remote_repository_impl.dart

@override
Future<Result<LoginResponseEntity>> login({
  required Email email,
  required PasswordHash passwordHash,
}) {
  return guard(() => _remoteDatasource.login(email: email, passwordHash: passwordHash));
}
```

Behind the scenes, `guard()` performs this automatic mapping:

- `ApiException` -> `Failure(ApiError(technicalMessage: 'HTTP <code>'))`
- `NoConnectionException` -> `Failure(NetworkError())`
- `ServerUnreachableException` -> `Failure(ServerUnreachableError())`
- `UnexpectedResponseException` -> `Failure(UnexpectedError(technicalMessage: details))`
- `DeviceSecurityException` -> `Failure(DeviceSecurityError(technicalMessage: message))`
- `AppTimeoutException` / `TimeoutException` (dart:async) -> `Failure(TimeoutError(technicalMessage: message))`
- `Exception` (generic) -> `Failure(UnexpectedError(technicalMessage: '$e'))` (safety net — note: `Error` (programming bugs) is NOT caught; it escapes the `Result` chain and must surface)

##### Step 2: Consuming the `Result` to Update UI (Notifier Layer)

In your Riverpod Notifiers, you consume the result using `.fold()`. `fold` requires two named callbacks: `onSuccess` (data) and `onFailure` (AppError).

```dart
lib/features/auth/presentation/notifiers/auth_notifier.dart

Future<void> login(String email, String password, {bool rememberMe = false}) async {
  state = const AuthState.loading();

  final result = await ref.read(loginUseCaseProvider)(
    LoginInput(email: email, password: password, rememberMe: rememberMe),
  );

  await result.fold<Future<void>>(
    onSuccess: (data) async {
      state = AuthState.loaded(
        patient: data.patient,
        token: data.token,
      );
    },
    onFailure: (error) async {
      state = AuthState.failure(error);
    },
  );
}
```

##### Step 3: Localized Errors via `localizeError()`

Notifier passes the `AppError` to state. The UI layer maps it to localized strings:

```dart
// Notifier — passes AppError to state
state = result.fold(
  onSuccess: (data) => AuthState.loaded(...),
  onFailure: (error) => AuthState.failure(error),
);

// UI Screen — localizes the error message
ref.listen<AuthState>(authProvider, (_, next) {
  if (next is AuthFailure) {
    final msg = localizeError(next.error, AppLocalizations.of(context)!);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
});
```

`localizeError()` lives in `lib/l10n/error_localizer.dart`:

```dart
String localizeError(AppError error, AppLocalizations l10n) => switch (error) {
  NetworkError() => l10n.errorNetwork,
  ApiError() => l10n.errorServer,
  ServerUnreachableError() => l10n.errorServer,
  TimeoutError() => l10n.errorTimeout,
  UnexpectedError() => l10n.errorUnknown,
  DeviceSecurityError() => l10n.errorDeviceSecurity,
  ValidationError(:final field) => switch (field) {
    'email' => l10n.errorInvalidEmail,
    'password' => l10n.errorPasswordTooShort,
    _ => l10n.errorInvalidCredentials,
  },
};
```

#### 4. Architectural Golden Rule

💡 `guard` creates, `fold` decides.

- `guard` lives in the Infrastructure Layer — it knows about network exceptions and translates them into domain terms.

- `fold` lives in the Presentation Layer — it knows about UI states, loading spinners, and error dialogs.

Neither layer must ever invade the other's territory.

#### 5. Important Developer Policies

🚫 Never Import `Result<T>` Directly
To keep our code unified and easily maintainable, never import the raw file. Instead, import the `shared/error` barrel:

```dart
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
```

This barrel exports `Result`, `Success`, `Failure`, `AppError`, all error subtypes, `guard()`, `RetryResult`, `RetrySuccess`, `RetryFailed`. (`localizeError()` lives in `lib/l10n/error_localizer.dart`, UI layer — see `MD/APP_EXCEPTION.md`.)

#### 6. How to Add a New Failure Type (Checklist)
Whenever a new backend or feature requirement introduces a unique exception, follow this strict checklist to add its corresponding `AppError` subtype:

##### 1. Create the exception file in `shared/exceptions/`:

```dart
lib/shared/exceptions/my_custom_exception.dart

/// One-line contract: what it represents, when it is thrown, and which
/// `AppError` `guard()` maps it to.
class MyCustomException implements Exception {
  const MyCustomException(this.message);
  final String message;
}
```

##### 2. Register the export inside `shared/exceptions/_exceptions.lib.dart`:

```dart
lib/shared/exceptions/_exceptions.lib.dart
export 'my_custom_exception.dart';
```

##### 3. Update the Guard Mapper: Add the matching `on MyCustomException catch` clause inside `guard()` located in `result_guard.dart` to ensure automatic mapping.

##### 4. (If it reaches the UI) Add a case in `localizeError()` in `l10n/error_localizer.dart`.

#### 7. Execution Architecture Summary
```bash
Notifier.someMethod()
├── state = Loading
├── result = await usecase.call(...) Returns: Result<T>
│   └── repository.someMethod(...)
│       └── guard(
│         () => datasource.someMethod() Raw execution (Can throw exceptions)
│       )
│         ├── Success Context 🟢 ──> Returns: Success(data)
│         └── Exception Catch 🔴 ──> Returns: Failure(MappedAppError)
│
└── state = result.fold(
  onSuccess: (data) ──> Transform into: AuthState.loaded(data),
  onFailure: (error) ──> Transform into: AuthState.failure(error),
)
```

#### 8. What About Composing Results in a UseCase?

Some UseCases need to chain multiple `Result`-returning operations conditionally — for example, restore a session from local storage, then check token expiry, then optionally refresh. The rule says "UseCase passes repository Results through unchanged and wraps shared ports with `guard()`" and "fold lives in Presentation", but the UseCase still needs to inspect intermediate `Result` values to decide what to do next.

**❌ Wrong — using `fold` in a UseCase:**

```dart
final result = await _repository.restoreSession();
return result.fold(
  (failure) => Failure(failure),
  (data) async {
    if (data == null) return const Success(null);
    if (await _tokenExpiryChecker.isExpired(data.token.key)) {
      if (await _connectivityChecker.isConnected()) {
        return _tryRefresh(data); // Another fold inside
      }
    }
    return Success(data);
  },
);
```

This violates the architecture because `fold` is reserved for Presentation (UI state mapping, `AuthState.error`/`AuthState.loaded`).

**✅ Correct — use `is Success` / `is Failure` or Dart 3 pattern matching instead:**

```dart
final localResult = await _repository.restoreSession();
if (localResult case Failure()) return localResult; // propagate Failure unchanged

final localData = (localResult as Success<LoginResponseEntity?>).data;
if (localData == null) return const Success(null); // no session

// Shared ports returning raw values are wrapped with guard()
final expiredResult = await guard(() => _tokenExpiryChecker.isExpired(localData.token.key));
final expired = switch (expiredResult) {
  Success(data: final value) => value,
  Failure() => false, // cannot verify → keep cache, no refresh
};
...
```

Dart 3 sealed classes with `is` checks (or `case` patterns) give you exhaustiveness and type safety. Always check the `Failure` branch first to propagate the error, then access the data.

This pattern keeps the architectural contract intact:
- `guard` creates the `Result` (Repository wraps datasources; UseCase wraps shared ports that return raw values — both are fallible boundaries)
- `fold` decides the UI outcome (in Notifier/Presentation)
- `is Success` / `is Failure` (or `case` patterns) composes business logic (in UseCase/Domain)

#### 9. Understanding `Success(null)` in `RestoreSessionUseCase`

`Success(null)` is a specific signal in the session restore flow. The return type `Result<LoginResponseEntity?>` has a **nullable** `Success`, enabling three distinct states:

| Value | Meaning |
| :--- | :--- |
| `Failure(failure)` | The operation **failed** (corrupted DB, unexpected error) |
| `Success(null)` | The operation **succeeded** but **there is no session** to restore |
| `Success(LoginResponseEntity(...))` | The operation **succeeded** and **here is the session data** |

##### Where `Success(null)` originates

**a) No local session** (`restore_session_usecase.dart`):
```dart
final localData = (localResult as Success<LoginResponseEntity?>).data;
if (localData == null) return const Success(null);
// The local datasource returned null — user has never logged in
```

**b) Expired token + refresh failed** (`restore_session_usecase.dart`):
```dart
// refresh failed → the cached session is KEPT (online-first: restore never force-logs-out)
return Success(localData);
// the stale token stays; a later request will hit a 401 and Handle401UseCase decides
```

##### The full traversal to the UI

```
RestoreSessionUseCase.call()
│
├── Success(null) ─────────────────────────────────────────────────┐
│ │
▼ ▼
AuthNotifier.restoreSession() (auth_notifier.dart)
│
├── result.fold(
│   onSuccess: (data) →
│     if (data == null) return;  ← Success(null): NO-OP
│     ^^^^^^^^^^^^^^^^
│     No state change → isAuthenticated stays false
│     state = AuthState.loaded(...);  ← Success(data): go to app
│   onFailure: (error) → state = AuthState.failure(error)
│ )
│
▼
authenticationObserverProvider watches authProvider:
AuthInitial → isAuthenticated = false
AuthLoaded  → isAuthenticated = true
│
▼
goRouterProvider (router_provider.dart) — AuthGuard.redirect:
├── !isAuthenticated && !isLoginRoute → redirect to AppRoute.login.path
├── isAuthenticated && isLoginRoute  → redirect to AppRoute.clinicalHistory.path
└── otherwise → null ("stay where you are")
│
▼
LoginScreen — the user sees the login form, no errors
```

##### The critical line: `if (data == null) return;`

```dart
// auth_notifier.dart — restoreSession()
onSuccess: (data) async {
  if (data == null) return;  // Success(null): silent exit
  state = AuthState.loaded(...);
},
```

When `data` is `null` (`Success(null)`):

- **`state` remains `AuthState.initial()`** — login screen is already showing
- **`authenticationObserverProvider` sees `AuthInitial`** — `isAuthenticated=false`, no navigation trigger
- **No error message** — the widget stays in `AuthInitial`, login form is visible
- **No loading state** — the restore already completed, loading indicator is gone

##### `Success(null)` vs `Failure(failure)` at the UI level

| Situation | UseCase returns | Notifier does | User sees |
| :--- | :--- | :--- | :--- |
| No local session | `Success(null)` | `if (data == null) return;` | Login screen, **no error** |
| Corrupted DB | `Failure(UnexpectedError(...))` | `state = AuthState.failure(error)` | Login screen, **error message** |
| Refresh failed (expired token) | `Success(data)` — cached session KEPT (restore never force-logs-out) | `state = AuthState.loaded(...)` | Clinical history (stale token; a later 401 is handled by `Handle401UseCase`) |

##### Why `Success(null)` and not plain `null`?

The contract is `Future<Result<LoginResponseEntity?>>`. The `Result` wrapper forces the consumer (Notifier) to handle both cases explicitly with `fold`:

- `Success(null)` = "all good, but no data" (expected case — no session exists)
- `Failure(failure)` = "something went wrong" (exceptional case — DB corruption, etc.)

Without `Result`, a plain `null` return would be ambiguous: is it "no session" or "error"? The `Result` makes the distinction explicit and compile-time enforced.

---

### dio — HTTP Client

#### 1. Why dio? (The Problem & The Solution)

Every feature that talks to the backend needs an HTTP client. Dart's built-in `http` package is simple but lacks interceptors, request cancellation, configurable timeouts, multipart file uploads, and response transformation. `dio` solves all of these with a rich, production-ready HTTP client.

In this project, `dio` is wrapped in `dio_wrapper.dart` (`IDioWrapper` / `DioWrapper`, `lib/core/network/dio/`). The wrapper adds:
- Automatic internet connectivity checks before every request.
- Automatic `Authorization` header injection via `AuthInterceptor` (only on `httpServiceProvider`).
- Typed exception mapping (`DioException` → `ApiException`, etc.).
- Support for `GET`, `POST`, `PATCH`, `DELETE`, `PUT`, and multipart file uploads.
- Configurable timeout per request (per-endpoint SLA).
- Certificate pinning via `CertificatePinner`.

The two Dio providers are built in `lib/core/network/dio/dio_providers.dart`:
- `authDioProvider` — Dio WITHOUT auth interceptor (used by `AuthRemoteDatasource` for login/refresh).
- `httpServiceProvider` — Dio WITH auth interceptor (401 retry + force logout; used by features making authenticated calls).

#### 2. Core Rule per Layer

| Layer | Responsibility | How it uses Dio |
| :--- | :--- | :--- |
| **`dio_wrapper.dart`** | Core HTTP Client | Throws typed infrastructure exceptions (`ApiException`, `NoConnectionException`). |
| **Datasource Impl** | External Data Ingestion | Calls `ref.watch(authDioProvider).get/post/...()` directly. **No error handling.** |
| **Repository Impl** | Boundary Adapter | Wraps datasource calls with `guard()`. |
| **Notifier** | Presentation State | Calls usecase → receives `Result<T>`. **Never touches Dio.** |

#### 3. How to Use It (Step-by-Step)

##### Step 1: Access the Dio wrapper in your Datasource

The datasource receives `IDioWrapper` via constructor injection from its Riverpod provider:

```dart
lib/features/auth/infrastructure/datasources/auth_datasource_impl.dart
class AuthRemoteDatasourceImpl implements IAuthRemoteDatasource {
  final IDioWrapper _dio;
  final IEndpointConfig _appUries;

  AuthRemoteDatasourceImpl({required this._dio, required this._appUries});

  @override
  Future<LoginResponseEntity> login({
    required String email,
    required String passwordHash,
  }) async {
    final httpResponse = await _dio.post(
      _appUries.login,
      sla: EndpointSla.login,
      body: <String, dynamic>{'email': email, 'passwordHash': passwordHash},
    );
    final response = _requireJsonMap(
      httpResponse.data,
      'login response must be a JSON object',
    );
    return AuthMapper.loginResponseFromDto(LoginResponseDto.fromJson(response));
  }
}
```

##### Step 2: Wire the provider

```dart
lib/features/auth/di/auth_provider.dart
@riverpod
IAuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasourceImpl(
      dio: ref.watch(authDioProvider),
      appUries: ref.watch(appUriesProvider),
    );
```

##### Available HTTP Methods

| Method | Use Case |
| :--- | :--- |
| `_dio.get(uri)` | Fetch data (GET) |
| `_dio.post(uri, body: ...)` | Create data (POST) |
| `_dio.patch(uri: ..., body: ...)` | Partial update (PATCH) |
| `_dio.put(uri: ..., body: ...)` | Full update (PUT) |
| `_dio.delete(uri: ...)` | Delete data (DELETE) |
| `_dio.multiFiles(uri: ..., fileList: ...)` | Multipart file upload |

All methods support optional `headers`, `sla` (with default `EndpointSla.unknown`), `pathParams`, `type` (for bytes/image responses), and `returnDioResponse`.

#### 4. Developer Policies

- 🚫 **Never import `dio` directly** in feature code. Always use `IDioWrapper` via `ref.watch(authDioProvider)` / `ref.watch(httpServiceProvider)`.
- 🚫 **Never catch `DioException` in datasources.** Let exceptions propagate to the Repository layer where `guard()` handles them.
- ✅ Use `api_endpoints.dart` for all endpoint URIs.

#### 5. Timeout System

The project has a **per-endpoint timeout system** that replaces hardcoded magic numbers with centralized, SLA-driven policies. **SLA** (Service Level Agreement) defines the maximum acceptable response time for each endpoint category — e.g., login has a 30s SLA because it depends on external auth, while a health check has a 5s SLA.

**Two layers of timeout enforcement:**

| Layer | What it controls | Location |
| :--- | :--- | :--- |
| **Dio-level** (`connectTimeout`, `receiveTimeout`) | Connection + response start timeout per host | `ConnectionProfile` → applied to `Dio` in `DioWrapper` constructor |
| **Future-level** (`.timeout(timeout)`) | Total request duration per endpoint; retries on timeout when `sla.retry.retryOnTimeout == true` | `EndpointSla` → resolved in `DioWrapper._request()` |

**`ConnectionProfile`** — configures the underlying `Dio` instance with sane defaults:

```dart
ConnectionProfile.standard     // connectTimeout: 10s, receiveTimeout: 15s, sendTimeout: 10s
```

The constructor is library-private to force centralized profile definitions.

**If you need a different profile** (e.g., for a slow network endpoint), add a new `static const` to `connection_profile.dart`:

```dart
// lib/core/network/timeouts/connection_profile.dart
static const slowNetwork = ConnectionProfile._(
  connectTimeout: Duration(seconds: 20),
  receiveTimeout: Duration(seconds: 60),
  sendTimeout: Duration(seconds: 10),
);
```

Then pass it when constructing `DioWrapper` in your provider.

**`EndpointSla`** — maps logical endpoint categories to timeouts + retry policy:

| Value | Timeout | Retry | When to use |
| :--- | :--- | :--- | :--- |
| `urgent` | 5s | none | Health checks, lightweight queries |
| `standard` | 15s | none | Default CRUD operations |
| `login` | 30s | 2 attempts, retry on timeout | Authentication, refresh token |
| `upload` | 120s | 2 attempts, retry on timeout | File uploads |
| `unknown` | 10s | none | Fallback when no SLA is explicitly declared |

When `sla` is omitted, `EndpointSla.unknown` (10s timeout, no retry) applies by default.

**`RetryPolicy`** — defines if and how to retry on timeout. `DioWrapper._request()` executes this policy automatically: on timeout, if `sla.retry.retryOnTimeout == true` and `attempt < maxRetries`, it delays by `baseDelay` (from `sla.retry.baseDelay`) and retries recursively.

| Policy | `maxRetries` | `retryOnTimeout` |
| :--- | :--- | :--- |
| `standard` | 0 | false |
| `idempotent` | 2 | true |

---

### flutter_riverpod — State Management & DI (v3 code-gen)

#### 1. Why Riverpod? (The Problem & The Solution)

Flutter's built-in `setState` + `InheritedWidget` pattern becomes unmanageable in medium-to-large apps. You end up with widget tree coupling, manual dependency passing, and no way to override dependencies in tests.

Riverpod solves this with:
- **Compile-safe providers** — no runtime errors for missing providers.
- **Code generation** — `@riverpod` functional providers and `@Riverpod` Notifiers with zero boilerplate.
- **Dependency override** — every provider can be replaced in `ProviderScope` for testing.
- **Fine-grained reactivity** — only rebuild widgets that depend on changed data.
- **`keepAlive`** — global singletons that never dispose (`@Riverpod(keepAlive: true)` or `Provider`).

#### 2. Integration Into the Architecture

| Provider type | Where | Purpose |
| :--- | :--- | :--- |
| **`@riverpod` functional provider** | `features/*/di/` | Wires datasources, repositories, use cases. |
| **`@Riverpod` Notifier** | `features/*/presentation/notifiers/` | Manages UI state with async actions. |
| **Plain `Provider` / `NotifierProvider`** | `core/` (defined, imported directly) | Shared singletons: dio, token, sembast (core/); goRouter (app/) |

Example of the code-gen provider (functional):

```dart
// lib/features/auth/di/auth_provider.dart
part 'auth_provider.g.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) =>
    AuthRemoteRepositoryImpl(
      remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    ));
```

Example of the code-gen Notifier:

```dart
// lib/features/auth/presentation/notifiers/auth_notifier.dart
part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    state = const AuthState.loading();
    final result = await ref.read(loginUseCaseProvider)(
      LoginInput(email: email, password: password, rememberMe: rememberMe),
    );
    await result.fold<Future<void>>(
      onSuccess: (data) async {
        state = AuthState.loaded(
          patient: data.patient,
          token: data.token,
        );
      },
      onFailure: (error) async {
        state = AuthState.failure(error);
      },
    );
  }

  Future<void> restoreSession() async { ... }
  Future<void> logout() async { ... }
  void reset() => state = const AuthState.initial();
}
```

> The generated file is `auth_provider.g.dart` / `auth_notifier.g.dart`. After adding/changing annotated providers, run `dart run build_runner build --delete-conflicting-outputs`.

#### 3. How to Use It (Step-by-Step)

##### Step 1: Declare a functional provider (for wiring dependencies)

```dart
lib/features/auth/di/auth_provider.dart
final authRepositoryProvider = Provider<IAuthRepository>((ref) =>
    AuthRemoteRepositoryImpl(
      remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    ));
```

##### Step 2: Watch in the UI

```dart
lib/features/auth/presentation/screens/login_screen.dart
final state = ref.watch(authProvider);
if (state is AuthLoading) {
  return const Scaffold(body: LoadingIndicator());
}
```

`AuthState` is a `@freezed` sealed class (`auth_state.dart`):

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.loaded({
    required PatientEntity patient,
    required TokenEntity token,
  }) = AuthLoaded;
  const factory AuthState.failure(AppError error) = AuthFailure;
}
```

#### 4. `ref.watch` vs `ref.read` vs `ref.listen`

| Method | Use when |
| :--- | :--- |
| `ref.watch(provider)` | Inside `build()` of widget/Notifier or functional provider — **reactivity** (rebuilds on change). |
| `ref.read(provider)` | Inside callbacks, `initState`, Notifier methods — **one-shot** action. |
| `ref.listen(provider, callback)` | Inside `build()` of a widget/Notifier — **react without rebuilding**. |

#### 5. Developer Policies

- ✅ Feature code accesses global providers by name (e.g. `ref.watch(authDioProvider)`), imported directly from the `core/` source file (never from `app/`).
- ✅ Use `@riverpod` annotation for functional providers and `@Riverpod` for Notifiers.
- ✅ Run `dart run build_runner build --delete-conflicting-outputs` after adding/changing annotated providers.
- 🚫 Never import provider files directly from another feature. Import from `core/` source files.
- 🚫 Never use `ref.watch` inside callbacks or async methods — use `ref.read`.

---

### Freezed + json_serializable — Immutable Data, Unions & JSON (code-gen)

#### 1. Why Freezed + code generation?

Model classes in Dart require: `==` operator, `hashCode`, `copyWith`, `toString`, union types, and JSON serialization. `freezed` generates all of this from a single immutable declaration, and `json_serializable` generates the `fromJson`/`toJson`.

- **Value equality** (`==` and `hashCode`) — generated by `freezed`.
- **`copyWith`** — generated by `freezed`.
- **Union types** — Dart 3 `sealed class` + `freezed` union syntax with pattern matching via `switch`.
- **JSON serialization** — delegated to dedicated **DTOs** in infrastructure (VGV-standard). Domain entities remain pure (no `fromJson`/`toJson`).

#### 2. Where It's Used

| File type | Location | Purpose |
| :--- | :--- | :--- |
| **DTO (Data Transfer Object)** | `features/*/infrastructure/dtos/` | API JSON contract — `@freezed` with `fromJson`/`toJson` (`json_serializable`). |
| **Domain Entity** | `features/*/domain/entities/` + `shared/models/` | Pure business object — `@freezed` ONLY, NO `fromJson`/`toJson`. |
| **Value Object** | `features/*/domain/value_objects/` | Validated value objects (`Email`, `Password`, `PasswordHash`) — `@freezed`; también enums de dominio puros con función derivada co-locada (`Period` + `filterByPeriod`, patrón `deriveLabResultStatus`). |
| **State Classes** | `features/*/presentation/notifiers/*_state.dart` | UI state as `@freezed sealed class`. |
| **Mapper** | `features/*/infrastructure/mappers/` | Converts DTO → Entity via constructors. |

#### 3. How to Use It

##### DTO (infrastructure — with JSON)

```dart
// lib/features/auth/infrastructure/dtos/token_dto.dart
@freezed
class TokenDto with _$TokenDto {
  const factory TokenDto({
    required String key,
    required String type,
  }) = _TokenDto;

  factory TokenDto.fromJson(Map<String, dynamic> json) => _$TokenDtoFromJson(json);
}
```

##### Domain Entity (pure — no JSON)

```dart
// lib/features/auth/domain/entities/token_entity.dart
@freezed
abstract class TokenEntity with _$TokenEntity {
  const factory TokenEntity({
    required String key,
  }) = _TokenEntity;
}
```

##### Mapper (infrastructure)

```dart
// lib/features/auth/infrastructure/mappers/auth_mapper.dart
class AuthMapper {
  static TokenEntity tokenFromDto(TokenDto dto) => TokenEntity(
    key: dto.key,
  );
}
```

##### Presentation State (sealed class)

```dart
lib/features/auth/presentation/notifiers/auth_state.dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.loaded({...}) = AuthLoaded;
  const factory AuthState.failure(AppError error) = AuthFailure;
}
```

Consume with `switch` pattern matching or `is` checks:

```dart
final state = ref.watch(authProvider);
switch (state) {
  AuthInitial() => ...,
  AuthLoading() => const CircularProgressIndicator(),
  AuthLoaded(:final patient) => ...,
  AuthFailure(:final error) => Text(localizeError(error, l10n)),
};
```

#### 4. Developer Policies

- ✅ Use `@freezed` for entities, value objects, DTOs and state classes.
- ✅ DTOs carry `fromJson`/`toJson` (via `json_serializable`); domain entities stay pure.
- ✅ Mappers use constructors named (e.g. `TokenEntity(key: dto.key)`), NEVER `Entity.fromJson`.
- ✅ Run `dart run build_runner build --delete-conflicting-outputs` after adding/changing `@freezed` files.

---

### abstract interface class — Pure Contracts (Dart 3)

#### 1. Why `abstract interface class` instead of `abstract class`?

Dart 3 introduced `abstract interface class` to define **pure contracts** that nobody can inherit from, only implement.

```dart
abstract interface class IConnectivityChecker {
  Future<bool> isConnected();
}

// ✅ Correct: implements the interface
class InternetService implements IConnectivityChecker { ... }

// ❌ Compile error: cannot extend an interface
class MyChecker extends IConnectivityChecker { ... }
```

| Feature | `abstract class` | `abstract interface class` |
|---------------|-----------------|---------------------------|
| Can `extends` | ✅ Yes | ❌ No |
| Can `implements` | ✅ Yes | ✅ Yes |
| Purpose | Base class with possible partial implementation | **Pure contract** (only methods without body) |

**Where is each used in the project?**

| Location | Uses | For |
|-----------|-----|------|
| `shared/interfaces/` | `abstract interface class` | `ITokenStore`, `IConnectivityChecker`, `ICredentialStore`, `ITokenVerifier`, `IPasswordHasher`, `IPatientInfoStore`, `IClinicalHistoryReader/Writer/Store`, `IUseCase` — business contracts that any layer can implement |
| `core/` | `abstract interface class` | `IInternetService`, `IDioWrapper`, `ISecureStorageWrapper`, `IPathProviderWrapper`, `IJailbreakDetectionWrapper` — infrastructure contracts |
| `core/network/connectivity/` | `abstract interface class` | `IInternetConnectionCheckerWrapper`, `IServerReachabilityStrategy` — internal abstractions |

**Enterprise rule:** Use `abstract interface class` for ALL new interfaces. Reserve `abstract class` only for cases where shared inheritance is needed (rare in this project).

#### 2. Cache pattern in infrastructure services

`lib/core/network/connectivity/internet_service.dart` uses a temporary cache to avoid repetitive reachability checks:

```dart
class InternetService implements IInternetService {
  static const _cacheDuration = Duration(seconds: 10);
  DateTime? _lastReachableCheck;
  bool? _lastReachableResult;

  @override
  Future<bool> isServerReachable() async {
    final now = DateTime.now();
    if (_lastReachableCheck != null &&
        _lastReachableResult != null &&
        now.difference(_lastReachableCheck!) < _cacheDuration) {
      return _lastReachableResult!;  // ← cache hit, does not call the network
    }
    final result = await _strategy.check();  // ← cache miss, real call
    _lastReachableCheck = now;
    _lastReachableResult = result;
    return result;
  }
}
```

**Why is it needed?** Without a cache, if `isServerReachable()` is called 5 times during a login, 5 socket connections are made in 2 seconds. With the 10-second cache, only the first call makes the real connection.

**When to use this pattern?**

| Scenario | Use temporary cache? |
|-----------|----------------------|
| Repetitive connectivity checks in a short time | ✅ Yes (like in `InternetService`) |
| Reads of slowly-changing data (config, feature flags) | ✅ Yes |
| Data that changes on every request (tokens, prices) | ❌ No |

**Enterprise rule:** Temporary caching in infrastructure services is valid when:
- The data source is external (network, disk, sensor) and expensive to query
- The data does not change within the cache window
- The cache is invalidated automatically by time (TTL), not manually

---

### JSON Serialization — via Freezed DTOs (VGV-standard)

This project follows the **Very Good Ventures (VGV) Layered Architecture** standard for serialization:
- **Data models (DTOs)** in `infrastructure/dtos/` handle ALL JSON serialization (`fromJson`/`toJson`) — generated by `freezed` + `json_serializable`.
- **Domain entities** in `domain/entities/` are PURE business objects — NO `fromJson`/`toJson`.
- **Mappers** in `infrastructure/mappers/` convert DTO → Entity via constructors.

#### 0. Why VGV-standard?

**Very Good Ventures (VGV)** is the Flutter consultancy that Google hires for its internal projects. Its Layered Architecture with DTOs separated from domain entities is the standard used by companies such as:

| Company | Industry | Why it uses Flutter + VGV architecture |
|---------|-----------|----------------------------------------|
| **Google** | Technology | Main Flutter partner. VGV built the Flutter News Toolkit and other official tools. |
| **BMW Group** | Automotive | Unified BMW and MINI apps into a single codebase, eliminating iOS/Android divergence. |
| **Toyota** | Automotive | VGV shipped production software for in-vehicle infotainment systems (IVI). |
| **Dow Jones / MarketWatch** | Finance / Media | New app launched in 3 months. ~50% reduction in development costs. |
| **Betterment** | Fintech (investments) | Adopted Flutter with VGV, established best practices, trained internal teams. |
| **NASCAR / Trackhouse** | Sports | Engagement systems for VIPs and sponsors with Flutter. |
| **Blade** | Luxury transport | Client app delivered in 8 weeks. |
| **Slickdeals** | E-commerce | Native app rebuilt in Flutter. Doubled release frequency. |
| **V1 Sports** | Sports / Fitness | Unified 6 native apps into a single cross-platform product. Doubled revenue. |

**Why these companies choose this architecture:**

1. **Scalability** — DTOs independent of domain entities allow the backend team to change the API without affecting the business model, and vice versa.
2. **Maintainability** — Layers with single responsibilities. A new developer understands where everything goes without guessing.
3. **Testability** — Domain entities are tested without JSON. DTOs are tested independently. Mappers are tested separately. Precise coverage.
4. **Parallelism** — Different teams can work on the API layer (DTOs) and the domain layer (entities) simultaneously without conflicts.
5. **VGV + Google standard** — It is not an arbitrary decision. It is the pattern that VGV (Google's official partner) applies in all its enterprise projects. Official Flutter docs recommend this separation.
6. **Production-proven** — BMW, Toyota, Google Pay, Nubank, Alibaba (50-100M+ users) use Flutter with this architecture in production.

#### 1. Why DTOs?

Domain entities must remain pure (no `fromJson`/`toJson`). JSON serialization is delegated to **DTOs** in `infrastructure/dtos/` using `@freezed` + `json_serializable` code generation. This decouples the API contract from the domain model.

#### 2. How to Use It

DTOs use `@freezed` with `fromJson`/`toJson` generated. Mappers in `infrastructure/mappers/` convert DTO → Entity via constructors.

#### 3. Developer Policies

- ✅ DTOs in `infrastructure/dtos/` use `@freezed` with `fromJson`/`toJson`.
- ✅ Domain entities use `@freezed` ONLY — NO `fromJson`/`toJson`.
- ✅ Mappers use constructors named (e.g. `TokenEntity(key: dto.key)`), NEVER `Entity.fromJson`.
- ✅ Code generation via `dart run build_runner build --delete-conflicting-outputs`.

---

### go_router — Declarative Navigation & Routing

#### 1. Why go_router? (The Problem & The Solution)

Flutter's built-in `Navigator` is imperative and doesn't support URL-based routing, deep linking, or declarative route definitions. As the app grows, managing navigation with `Navigator.push`/`pop` becomes messy.

`go_router` solves this with:
- **Declarative routing** — all routes defined in one place.
- **URL-based navigation** — `go('/clinical-history')`, `goNamed('login')`.
- **Redirect guards** — automatically redirect unauthenticated users to login.
- **Deep linking support** — routes map directly to URLs.

In this project, `go_router` is **not accessed directly from features**. It is exposed through the Riverpod provider `goRouterProvider` in `app/di/router/router_provider.dart`, created in `main.dart` (via `TudesarrolladorApp.build`), which receives an `AuthGuard` and `authenticationObserverProvider` as `refreshListenable`.

#### 2. Integration Into the Architecture

| Component | Responsibility |
| :--- | :--- |
| `goRouterProvider` | Builds the `GoRouter` instance with `AuthGuard`, `authenticationObserverProvider` as `refreshListenable` and `appRoutes()`. |
| `appRoutes()` | Defines routes in `app/router/app_router.dart` (login + clinical-history). |
| `AppRoute` | Enum of route paths/names in `shared/router/app_route.dart`. |
| `AuthGuard` | `redirect()` logic in `app/router/guards/auth_guard.dart` (login vs clinical-history). |
| `authenticationObserverProvider` | `ChangeNotifier` (`AuthObserver`) that mirrors auth state and notifies GoRouter when auth state changes. |

```dart
// lib/app/di/router/router_provider.dart
final goRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(authenticationObserverProvider);
  const guard = AuthGuard();
  return GoRouter(
    initialLocation: AppRoute.login.path,
    refreshListenable: observer,
    redirect: (context, state) => guard.redirect(
      location: state.matchedLocation,
      from: state.uri.queryParameters['from'],
      isAuthenticated: observer.isAuthenticated,
    ),
    errorBuilder: (context, state) => AppErrorScreen(error: state.error),
    routes: appRoutes(
      onLogout: () => ref.read(authProvider.notifier).logout(),
    ),
  );
});
```

```dart
// lib/shared/router/app_route.dart
enum AppRoute {
  login(path: '/', name: 'login'),
  clinicalHistory(path: '/clinical-history', name: 'clinical-history');
  ...
}
```

```dart
// lib/app/router/app_router.dart
List<RouteBase> appRoutes({Future<void> Function()? onLogout}) => [
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.clinicalHistory.path,
        name: AppRoute.clinicalHistory.name,
        builder: (_, _) => ClinicalHistoryScreen(onLogout: onLogout),
      ),
    ];
```

#### 3. How to Use It (Step-by-Step)

##### Step 1: Register a new route (in `shared/router/app_route.dart` + `app/router/app_router.dart`)

Add a value to the `AppRoute` enum, then a `GoRoute` inside `appRoutes()`.

##### Step 2: Navigate from anywhere

Navigation is mostly **reactive**: `authProvider` changes → `AuthObserver` notifies → `AuthGuard` redirects. For imperative navigation from a notifier or widget, use the `IAppNavigator` seam (re-exported by the feature's `di/`):

```dart
// From any notifier or widget — via the IAppNavigator seam, never import go_router or app/ directly
ref.read(appNavigatorProvider).go(AppRoute.clinicalHistory);
ref.read(appNavigatorProvider).push(AppRoute.someRoute);
```

#### 4. Developer Policies

- 🚫 **Never import `go_router` nor `app/` directly** in feature code. Use the `IAppNavigator` seam — `ref.read(appNavigatorProvider).go/push(AppRoute.x)` (one-line re-export in the feature's `di/`).
- 🚫 **Never instantiate `GoRouter` directly** in features. Use `goRouterProvider` in `app/di/router/router_provider.dart` (composition root only).
- ✅ Define routes in `shared/router/app_route.dart` (enum) + `app/router/app_router.dart` (`appRoutes()`).

---

### sembast — Local Database (NoSQL)

#### 1. Why sembast? (The Problem & The Solution)

Storing structured data locally requires a database. `sembast` is a lightweight NoSQL document database with built-in encryption support via `sembast_codec`.

In this project, sembast is used with AES-256-CBC encryption. The encryption chain is:

```
flutter_secure_storage → DatabaseKeyService (AES-256 key) → database_encrypt.dart (AES-256-CBC codec) → AppDatabase (sembast)
```

The entire database is encrypted at rest using `SembastCodec`.

#### 2. How It's Integrated

`AppDatabase` manages the sembast `Database` instance, encryption, and lifecycle using proper dependency injection. It receives `IPathProviderWrapper` via constructor (`app_database_provider.dart`) and is exposed via `appDatabaseProvider`. The low-level sembast database is exposed as `ISembastDb` through `core/database/sembast_db_wrapper.dart`.

```dart
// Access from a feature provider
final db = await ref.read(appDatabaseProvider).database;

// Full local wipe (account reset / GDPR) — through the auth usecase, NOT directly
await ref.read(resetAccountUseCaseProvider)(NoParams());
// → ResetAccountUseCase → ILocalAuthRepository.resetAccount()
//   → LocalAuthDatasourceImpl.resetAccount() = clearSession() + resetDatabase()
```

For session/token storage, use `SecureTokenStore` (which implements `ITokenStore`) via `tokenStoreProvider`:

```dart
// Save token (from use case after login)
await ref.read(tokenStoreProvider).save(token);

// Read token (from main.dart at startup)
final token = await ref.read(tokenStoreProvider).read();

// Delete token (on logout)
await ref.read(tokenStoreProvider).delete();
```

Sembast is also used internally by `ClinicalHistoryStore` and `PatientInfoStore` for offline-first storage of clinical data (`clinicalHistoryStoreProvider`, `patientInfoStoreProvider` in `core/database/tables/*_providers.dart`).

#### 3. Developer Policies

- 🚫 **Never access `AppDatabase` or sembast types directly** from features.
- ✅ Use `appDatabaseProvider` for database access.
- ✅ Use `tokenStoreProvider` for token persistence.
- 🚫 Never import `package:sembast/sembast.dart` in feature code.

---

### flutter_secure_storage — Secure Key-Value Storage

#### 1. Why flutter_secure_storage?

Storing auth tokens and encryption keys in plain text or `SharedPreferences` is a security risk. `flutter_secure_storage` uses the platform's native secure keystore (Keychain on iOS, EncryptedSharedPreferences on Android).

In this project, it is wrapped in `secure_storage_wrapper.dart` (`ISecureStorageWrapper` / `SecureStorageWrapper`) and consumed by:
- **`SecureTokenStore`** (implements `ITokenStore`) — stores the JWT auth token via `tokenStoreProvider`.
- **`SecureCredentialStore`** (implements `ICredentialStore`) — stores email + password hash for remember-me via `credentialStoreProvider`.
- **`DatabaseKeyService`** — stores the AES-256 encryption key used by `AppDatabase`.

#### 2. How to Use It

Never access `flutter_secure_storage` directly from features. Use these facades:

```dart
// From any notifier or use case — via tokenStoreProvider (injectable service)
await ref.read(tokenStoreProvider).save(token);
final token = await ref.read(tokenStoreProvider).read();
await ref.read(tokenStoreProvider).delete();

// lib/core/services/storage/secure_storage_wrapper.dart — internal only
// Handled by AppDatabase / token providers automatically — never call from features
```

#### 3. Developer Policies

- 🚫 **Never import `flutter_secure_storage` directly** in feature code.
- ✅ Use `tokenStoreProvider` for auth tokens (injectable, overridable in tests).
- ✅ `DatabaseKeyService` is an internal dependency — never called from features.

---

### path_provider — File System Paths

#### 1. Why path_provider?

When you need to write files locally (for sharing, caching, etc.), you need platform-appropriate directories. `path_provider` provides access to the device's temporary and documents directories.

In this project, it is wrapped in `path_provider_wrapper.dart` — a **pure utility** (`IPathProviderWrapper` / `PathProviderWrapper`) exposed via `pathProviderProvider` (`core/services/device/path_provider_provider.dart`).

#### 2. How to Use It

```dart
// Get temp directory (files can be deleted by OS)
final tempDir = await ref.read(pathProviderProvider).getTemporaryDirectory();

// Get documents directory (persistent storage)
final docsDir = await ref.read(pathProviderProvider).getApplicationDocumentsDirectory();
```

#### 3. Developer Policies

- ✅ Access via `ref.read(pathProviderProvider).xxx()` directly (pure utility).

---

### internet_connection_checker_plus — Network Connectivity

#### 1. Why internet_connection_checker_plus?

Before making HTTP requests, we need to verify that the device actually has internet access (not just WiFi with no connectivity). This package provides a reliable `InternetConnection().internetStatus` check.

In this project, it is wrapped in `internet_connection_checker_wrapper.dart` (`IInternetConnectionCheckerWrapper`) and consumed by `InternetService` (`core/network/connectivity/internet_service.dart`), which exposes `IInternetService`.

#### 2. How It's Used

`InternetService` has two responsibilities:
- `isConnected()` — delegates to `IInternetConnectionCheckerWrapper.checkConnectivity()` (internet_connection_checker_plus).
- `isServerReachable()` — checks if the server is reachable via a raw TCP socket (`NativeSocketReachability`) on native or an HTTP request (`HttpReachability`) on web, with a 10-second cache.

The `DioWrapper` calls connectivity checks automatically before every request:

```dart
// lib/core/network/dio/dio_wrapper.dart — called automatically inside _request()
if (!await _internetService.isConnected()) {
    throw const NoConnectionException();
}
```

The strategy is selected by `connectivity_providers.dart` based on `kIsWeb`:

```dart
final internetServiceProvider = Provider<IInternetService>((ref) {
  final env = ref.watch(environmentProvider);
  return InternetService(
    strategy: kIsWeb
        ? HttpReachability(dio: ..., baseUri: ...)
        : NativeSocketReachability(host: env.host, port: env.port),
  );
});
```

#### 3. Developer Policies

- 🚫 **Never access `InternetService` directly from features.** `DioWrapper` already handles connectivity checks internally.
- ✅ If you absolutely need connectivity outside HTTP, inject `IInternetService` through your provider — do not access `internetServiceProvider` directly from features; use `ref.read(authDioProvider)` for HTTP calls.

---

### encrypt — AES-256 Encryption

#### 1. Why encrypt?

Session data (auth token, user fullname) stored in the local sembast database must be encrypted at rest. The `encrypt` package provides AES-256-CBC encryption with secure random IV generation.

In this project, it is used inside `database_encrypt.dart` (`core/database/database_encrypt.dart`) — an **internal implementation detail** of `AppDatabase` that provides a `SembastCodec` for transparent AES-256-CBC encryption.

#### 2. How It's Used

Encryption is transparent: `AppDatabase` uses `database_encrypt.dart` to create a `SembastCodec` that automatically encrypts/decrypts all data written to/read from sembast. The AES key is generated via `DatabaseKeyService` and stored in `flutter_secure_storage`.

```dart
lib/core/database/sembast_codec.dart — getEncryptSembastCodec(password:) returns SembastCodec with AES-256-CBC
(database_encrypt.dart holds the AES-256-CBC Codec internals)
Encrypt: prepends base64-encoded IV, then AES-256-CBC ciphertext
Decrypt: extracts IV from first 24 base64 chars, then decrypts rest
```

#### 3. Developer Policies

- 🚫 **Never access `encrypt` or `database_encrypt.dart` directly from features.** `AppDatabase` handles encryption transparently.

---

### flutter_jailbreak_detection_plus — Jailbreak / Root Detection

#### 1. Why flutter_jailbreak_detection_plus?

The app must detect jailbroken/rooted devices to protect against tampering. The maintained fork `flutter_jailbreak_detection_plus` is used instead of the unmaintained `flutter_jailbreak_detection` because the original did not declare `namespace`/`compileSdk 34`/JVM 17, breaking Android builds on AGP 8+.

#### 2. How It's Used

Wrapped in `jailbreak_detection_wrapper.dart` (`IJailbreakDetectionWrapper` / `JailbreakDetectionWrapper`) and exposed via `flutterJailbreakDetectionProvider` (`core/services/device/jailbreak_provider.dart`). Run at startup in `AppInitializer.checkJailbreak()` for Android/iOS only. It follows the **guard/fold** rule: `checkJailbreak()` returns `Future<Result<void>>` — `guard()` wraps the raw `isJailbroken()` port and maps `DeviceSecurityException` → `DeviceSecurityError`; `main.dart` folds the result and renders a hard-stop `DeviceSecurityBlockedScreen` only on a confirmed jailbreak (detection failures are logged and do not block).

#### 3. Developer Policies

- 🚫 **Never access `flutter_jailbreak_detection_plus` directly from features.** Use `flutterJailbreakDetectionProvider`.
- ✅ The check runs only on Android/iOS (short-circuit on web/desktop).

---

### fl_chart — Charts & Graphs

`fl_chart` is used for lab-result line charts and is wrapped behind the `ITrendChart` seam (`lib/core/services/charts/fl_chart_wrapper.dart`, impl `FlChartTrendChart`) exposed via `trendChartProvider` (`core/services/charts/charts_providers.dart`). **Never import `package:fl_chart` in features or feature tests** — the wrapper rule applies (Rule 6); presentation consumes the seam via the `di/` re-export (`features/lab_results/di/`) and mocks `ITrendChart` in tests. Capacity contract types (`TrendPoint`, `TrendChartData`) live in `core/services/charts/models/trend_chart_data.dart`.

---

### logger — Structured Logging (observability seam)

#### 1. Current state

The `logger` pub package and the old `LoggerWrapper`/`ILoggerWrapper` classes were removed, but the project now ships its **own observability seam**: `ILogger` (`shared/interfaces/i_logger.dart`), `DevLogger` (over `dart:developer log`) and `loggerProvider` (`Provider<ILogger>`) in `core/services/logging/logging_providers.dart`. It is **re-exported by each feature `di/`** so presentation notifiers log `technicalMessage`/`stackTrace` without importing `core/` (Rule 15), and it is overridable in tests (e.g. `FakeLogger`). Use `debugPrint` only for temporary debug output — remove before PR.

---

## Dev Dependencies used

### Code Generation

This project uses code generation for:
- `freezed` — immutable classes, unions, sealed state (`@freezed`).
- `json_serializable` — JSON `fromJson`/`toJson` for DTOs (`@JsonSerializable` via freezed's `json_serializable: true`).
- `riverpod_generator` — Riverpod providers/notifiers (`@riverpod`, `@Riverpod`).

```bash
# Run after modifying any @freezed or @riverpod annotated file:
dart run build_runner build --delete-conflicting-outputs
```

`build.yaml` in the repo root configures the builders. All other code is written by hand.

### drift_dev — Drift Code Generator

Generates database access code from drift table definitions. Reads `@DataClass`, `@Table`, and `@UseRowClass` annotations and produces type-safe query methods.

Not used — the project uses sembast with hand-written stores.

### flutter_lints — Dart Lint Rules

The official lint rule set from the Flutter team. Enforces consistent code style, naming conventions, and best practices.

### mocktail — Test Mocks

#### 1. Why mocktail?

Unit tests need to isolate the unit under test from its dependencies. `mocktail` lets you create mock implementations of interfaces without manual boilerplate:

```dart
test/helpers/mocks.dart or inline in test files
class MockAuthRepository extends Mock implements IAuthRepository {}
```

With `mocktail`, you can:
- Stub return values: `when(() => repo.login(...)).thenAnswer(...)`.
- Verify interactions: `verify(() => repo.login(...)).called(1)`.
- Mock async methods, streams, and void methods.

#### 2. How to Use It

```dart
Used in any unit test file under test/features/*/, test/core/*/, test/shared/*/
// Register fallback values for complex parameter types
registerFallbackValue(Uri());

// Stub a method
when(() => mockDatasource.getData()).thenAnswer(
  (_) async => <Map<String, dynamic>>[...],
);

// Execute the test
final result = await repository.getData();

// Verify interaction
verify(() => mockDatasource.getData()).called(1);
```

#### 3. Developer Policies

- ✅ Use `mocktail` for all unit tests (domain, infrastructure, presentation).
- ✅ Create mocks that implement the **wrapper interfaces** (`IDioWrapper`, `ITokenStore`, `IConnectivityChecker`, etc.), not raw packages.
- ✅ Register fallback values for any complex parameter types used in mocked methods.

### gherkart — BDD / Gherkin Test Runner

#### 1. Why gherkart?

The project uses Behavior-Driven Development (BDD) with Gherkin syntax (given/when/then scenarios defined in `bdd.feature` files). `gherkart` parses `.feature` files and provides a Dart API to iterate through scenarios and steps.

#### 2. How to Use It

```dart
test/bdd/clinical_history_bdd_test.dart
import 'package:gherkart/gherkart.dart';

void main() {
  _testFunction(); // standalone top-level call
}

Future<void> _testFunction() async {
  final registry = StepRegistry<WidgetTester>.fromMap({
    'Given ...': (tester, context) async { /* arrange */ },
    'When ...': (tester, context) async { /* act */ },
    'Then ...': (tester, context) async { /* assert */ },
  });

  await runBddTests<WidgetTester>(
    source: FileSystemSource(),
    feature: 'lib/features/auth/spec/bdd.feature',
    registry: registry,
    structure: TestStructure.flat,
    testFunction: (scenario, tester) async {
      // one testWidgets per scenario is created by runBddTests
    },
  );
}
```

#### 3. Developer Policies

- ✅ Use `runBddTests<WidgetTester>` with a `StepRegistry` — the reference style is a top-level `_testFunction()` (as in `test/bdd/clinical_history_bdd_test.dart`); an inline `testFunction:` lambda inside `main()` (as in `test/bdd/auth_bdd_test.dart`) is also accepted.
- ✅ One `testWidgets` per scenario.
- ✅ Register all needed provider overrides before pumping the widget.

---

## Package Quick Reference

| Package | Description | How to Use | Where It's Used |
| :--- | :--- | :--- | :--- |
| **Result\<T\> (in-repo)** | Functional error handling with `Result<T>` | `guard(...)` in repositories; `.fold(...)` in notifiers | All repository impls (catch → `Result`), all notifiers (consume → state) |
| **dio** | HTTP client with interceptors | `ref.watch(authDioProvider).get/post/patch/delete/put/multiFiles(uri)` | All datasource impls for API communication |
| **flutter_riverpod** | State management & DI (v3 code-gen) | `@riverpod` functional providers for wiring; `@Riverpod` Notifiers for state; `ref.watch/read/listen` | Every provider, notifier, and screen |
| **freezed + json_serializable** | Immutable data classes, unions & JSON | `@freezed` entities/DTOs/state; `fromJson`/`toJson` on DTOs | All entities (`*_entity.dart`), DTOs (`*_dto.dart`), states (`*_state.dart`), value objects |
| **go_router** | Declarative routing with redirect guards | `goRouterProvider` in `app/di/router/router_provider.dart` (composition root only); features navigate via the `IAppNavigator` seam — `ref.read(appNavigatorProvider).go/push(AppRoute.x)` | `lib/app/router/` (routes, guard), `lib/shared/router/` (AppRoute), `lib/app/di/router/` (provider) |
| **sembast** | Lightweight NoSQL document DB with AES-256 encryption | `ref.read(appDatabaseProvider).database`; full wipe via `ResetAccountUseCase` (auth) → `resetDatabase()` | `core/database/app_database.dart` (encrypted sembast) |
| **flutter_secure_storage** | Platform-native secure keystore | `ref.read(tokenStoreProvider).save/read/delete()` for tokens; `DatabaseKeyService` (internal) for DB encryption key | `secure_token_store.dart` (auth tokens), `secure_credential_store.dart` (remember-me), `secure_storage_wrapper.dart` (DB encryption key) |
| **path_provider** | Platform temp & documents directories | `await ref.read(pathProviderProvider).getTemporaryDirectory()` or `.getApplicationDocumentsDirectory()` | Temp file storage for sharing, caching |
| **internet_connection_checker_plus** | Internet access detection | Wrapped by `InternetConnectionCheckerWrapper`; `InternetService.isConnected()` | Only inside `core/network/connectivity/` |
| **encrypt** | AES-256-CBC encryption | Used by `database_encrypt.dart` to create `SembastCodec` for transparent encryption | Only inside `core/database/` (internal to `AppDatabase`) |
| **flutter_jailbreak_detection_plus** | Jailbreak / root detection | `AppInitializer.checkJailbreak()` via `flutterJailbreakDetectionProvider` | `core/services/device/jailbreak_detection_wrapper.dart`, `app/app_initializer.dart` |
| **dart_jsonwebtoken** | JWT decode | `JwtWrapper.decodePayload` (`IJwtWrapper`) + `JwtTokenExpiryChecker` (`ITokenVerifier.isExpired`) | `core/services/auth/` |
| **bcrypt** | Password hashing | `BcryptWrapper` (`IPasswordHasher`) via `passwordHasherProvider` | `core/services/crypto/` |

### Dev Dependencies

| Package | Description | How to Use | Where It's Used |
| :--- | :--- | :--- | :--- |
| **build_runner** | Code generation runner | `dart run build_runner build --delete-conflicting-outputs` | Regenerates `.g.dart` / `.freezed.dart` files |
| **freezed** | Code-gen for immutable classes/unions | `@freezed` annotations | All entities, DTOs, states, value objects |
| **json_serializable** | Code-gen for JSON | `fromJson`/`toJson` on DTOs | DTOs in `infrastructure/dtos/` |
| **riverpod_generator** | Code-gen for Riverpod | `@riverpod` / `@Riverpod` annotations | All `features/*/di/` and notifiers |
| **flutter_lints** | Official Flutter lint rules | Added to `analysis_options.yaml` | Enforces code style & best practices |
| **mocktail** | Mock interfaces for unit tests | `class MockRepo extends Mock implements IRepo {}` + `when/verify` | All unit tests under `test/features/*/`, `test/core/*/`, `test/shared/*/` |
| **gherkart** | Parse and run Gherkin `.feature` files | `StepRegistry` + `runBddTests` → one `testWidgets` per scenario | BDD tests under `test/bdd/*_bdd_test.dart` |

---

## Interceptor

There is a single Dio infrastructure, but **two providers**:

- `authDioProvider` — a `DioWrapper` **without** the auth interceptor. Used by `AuthRemoteDatasource` for login/refresh (no token exists yet, no 401 retry needed).
- `httpServiceProvider` — a `DioWrapper` **with** the auth interceptor (401 retry + force logout). Used by every feature that makes authenticated HTTP calls.

Both are built by the same internal factory in `lib/core/network/dio/dio_providers.dart`.

The `AuthInterceptor` is added once to `httpServiceProvider` and from then on intercepts all authenticated HTTP requests from any feature.

```dart
// lib/core/network/dio/dio_providers.dart — el seam (core no conoce el feature auth)
final authInterceptorProvider = Provider<IAuthInterceptorProvider>(
  (ref) => throw UnimplementedError(
    'authInterceptorProvider must be overridden in the composition root '
    '(app/di/network/dio_overrides.dart)',
  ),
);

final httpServiceProvider = Provider<IDioWrapper>((ref) {
  final dio = _createDioWrapper(ref);
  ref.watch(authInterceptorProvider).setupAuthInterceptor(dio);
  return dio;
});
```
```
// lib/app/di/network/dio_overrides.dart — el binding concreto (composition root)
List<Override> dioOverrides() => [
      authInterceptorProvider.overrideWith(
        (ref) => AuthInterceptorImpl(
          handle401UseCase: ref.watch(handle401UseCaseProvider),
          onForceLogout: () => ref.read(authProvider.notifier).forceLogout(),
          getToken: () => ref.read(tokenStoreProvider).read(),
        ),
      ),
    ];
```

The interceptor implementation (`AuthInterceptorImpl`) implements `IAuthInterceptorProvider` and lives in `lib/app/di/network/auth_interceptor_impl.dart`:

```dart
// lib/app/di/network/auth_interceptor_impl.dart
class AuthInterceptorImpl implements IAuthInterceptorProvider {
  AuthInterceptorImpl({
    required this._handle401UseCase,
    required this._onForceLogout,
    required this._getToken,
  });

  final IUseCase<NoParams, RetryResult> _handle401UseCase;
  final VoidCallback _onForceLogout;
  final Future<String?> Function() _getToken;

  @override
  void setupAuthInterceptor(IDioWrapper dioWrapper) {
    dioWrapper.addAuthInterceptor(
      () async {
        final result = await _handle401UseCase(NoParams());
        return switch (result) {
          Success(data: final retryResult) => retryResult,
          Failure() => const RetryFailed(),
        };
      },
      onForceLogout: _onForceLogout,
      getToken: _getToken,
    );
  }
}
```

`Handle401UseCase` returns `Future<Result<RetryResult>>` (in `features/auth/domain/usecases/handle_401_usecase.dart`) and follows the standard pattern:

```
AuthInterceptor → Handle401UseCase → IAuthRepository → guard() → IAuthRemoteDatasource → HTTP
                                       ↑
                               returns Result<RetryResult>
```

When any feature receives a 401:

```bash
AuthRemoteDatasource of a feature
↓ uses ref.read(httpServiceProvider)   (authDioProvider for auth's own login/refresh)
Dio.get('/clinical-history/...')
↓
AuthInterceptor.onError() detects 401
↓ executes
Handle401UseCase.call() → returns Result<RetryResult>
│
├─ connectivityChecker.isConnected()?
│   └─ NO → Success(RetryNoConnection) (silent, no logout — the interceptor retries)
│
├─ tokenStore.read()? → token found
│   └─ RefreshTokenUseCase(token)
│       └─ IAuthRepository.refreshToken(token)
│         └─ IAuthRemoteDatasource.refreshToken(token)
│           └─ authDioProvider.post(/refreshtoken) → new token
│           ├─ success → save new token → RetrySuccess(newToken)
│           └─ fails → fallback: re-login with saved credentials
│               └─ also fails:
│                   ├─ last error isTransient → Success(RetryNoConnection) (silent, NO logout)
│                   └─ non-transient → Failure → interceptor maps to RetryFailed → onForceLogout
│
└─ Result<RetryResult> unwrapped by interceptor
↓ is Success(RetrySuccess(token)):
internalDio.fetch(original requestOptions with new Authorization header) → retry
↓ success
handler.resolve(response) → the feature receives its data
```

**Key distinction:**

- `Handle401UseCase` composes the `IUseCase` seams `RefreshTokenUseCase` + `CredentialLoginUseCase` (Rule 18 — it never holds `IAuthRepository` directly) — follows the standard `UseCase → Repository → guard() → Datasource` flow.
- `internalDio` is a separate, bare `Dio` instance created in `DioWrapper.addAuthInterceptor` and injected into `AuthInterceptor`. It is used **only** for retrying the original failed request after obtaining a new token.
- The auth datasource uses `authDioProvider` (Dio without auth interceptor) to avoid re-entering the interceptor chain for refresh and re-login calls.
- The `_isRefreshing` guard in `AuthInterceptor` prevents concurrent refresh attempts.

The same interceptor, a single configuration, works for the entire app.

---

## Use Case vs Service

The pattern: the Use Case tells the Service **what** to do (try refresh, try re-login) but not **how**. The Service implements **how** (POST to a specific URL, parse a specific JSON field). The Use Case lives in an abstract world of interfaces; the Service lives in the concrete world of Dio, HTTP, and JSON.

| Use Case (Domain) | ✅ / ❌ | Service (Infrastructure) | ✅ / ❌ |
| :---------------- | :---- | :-------------------------------------------------------------------------------------- | :---- |
| Makes decisions | ✅ | "Is there connection? → try refresh → if it fails, try re-login" | ❌ |
| Orchestrates | ✅ | "Coordinates multiple interfaces" | ❌ |
| Imports packages | ❌ | "Only domain interfaces" | ✅ |
| Contains logic | ✅ | "Business rules (what, in what order)" | ❌ |
| Implements | ❌ | "Nothing, it is pure" | ✅ |

**Note:** ✅ represents a correct description for that layer's role, and ❌ represents an incorrect description.

---

**Simplified Explanation:**

* **Domain (Use Cases):** Answer the **what** and **why** (business rules, decisions, orchestration). They must not know **how** it is done technically.
* **Infrastructure (Services):** Answer the **how** (technical execution, HTTP handling, databases). They must not know the business rules from the domain.

---

## RestoreSessionUseCase Scenario Analysis

| Session | Token | Connection | Behavior |
| :--- | :--- | :--- | :--- |
| Does not exist | - | - | Success(null) → login screen |
| Exists | Valid | - | Success(data) → goes directly to the app |
| Exists | Expired | No internet | Success(data) → preserves session (online-first). If the user makes a request, DioWrapper throws NoConnectionException → cache fallback |
| Exists | Expired | Internet, refresh succeeds | POST /refresh_token → saves new token → Success(data.copyWith(token: newToken)) → app starts without interruption |
| Exists | Expired | Internet, refresh fails | POST /refresh_token → Failure(failure) → keeps cached session → Success(data) (restore NEVER force-logs-out) |
| Exists | Any | restoreSession() fails | Failure(failure) → Notifier shows error and stays at login |

**Explanation of each scenario:**

| Scenario | Rationale |
| :--- | :--- |
| No local session | Nothing saved, nothing to restore. Login screen. |
| Valid token | JWT has not expired. AuthInterceptor handles any 401 at runtime if the server rejects it. |
| Expired token, no internet | Cannot refresh without a network. Preserving the session allows offline use. AuthInterceptor never fires because requests never reach the API. |
| Expired token, internet, refresh succeeds | Refresh endpoint accepts the old token and returns a new one. Seamless experience — the user never sees the login. |
| Expired token, internet, refresh fails | Refresh rejected → the **cached session is kept** (`Success(localData)`); a later request hits a 401 and `Handle401UseCase` decides (re-login / silent retry / force logout). Restore never force-logs-out. |
| restoreSession() fails | Infrastructure error (corrupted DB, etc.). Notifier shows the error message and stays at login. |

`RestoreSessionUseCase` and `AuthInterceptor` operate at different moments and do not overlap:

| Moment | Mechanism | What it checks |
| :--- | :--- | :--- |
| On app open | RestoreSessionUseCase | JWT exp claim (local) |
| During HTTP requests | AuthInterceptor | HTTP 401 from server |

`RestoreSessionUseCase` prevents the user from seeing the app only to be abruptly kicked out by a 401. By proactively refreshing at startup, the first request the app makes already has a valid token.

---

## Login Flow

```bash
main → AppInitializer (platform + jailbreak) → Notifier → UseCase → Repository → Local Datasource
↓
Sembast (patient, clinical history)
SecureStorage (token, credentials)
↓
Main ← Notifier ← UseCase ← Repository ← Datasource
↓
AuthState.loaded(...)
↓
authenticationObserverProvider → isAuthenticated = true
↓
AuthGuard redirects to /clinical-history
```

When the domain communicates with infrastructure, there is an extra decision. The infrastructure call is not a single one — it is potentially two:

1. **Remote re-login first** (if online + saved credentials exist): `CredentialLoginUseCase` (remember-me) — returns early on success.
2. **Local restore** (only if the remote path did not produce a fresh session): read patient + token + histories from Sembast/SecureStorage.
3. **Refresh** (only if the restored token is expired + online): POST /refreshtoken.

```bash
RestoreSessionUseCase.call()
↓
_connectivityChecker.isConnected()? + _credentialStore.readCredentials()?
├── online && credentials → attempt re-login (remember-me) → Success(data) on success
│
↓
_repository.restoreSession() → LocalDatasource → returns LoginResponseEntity?
↓
Token expired?
├── No → returns Success(data) ← keeps the local session
│
└── Yes → Has internet?
    ├── No → returns Success(data) ← online-first, preserves session (restore never force-logs-out)
    │
    └── Yes → **attempts refresh via API** ← SECOND infrastructure call
        ├── OK → saves new token → returns Success(data with new token)
        └── Fails → returns Success(data) ← cached session KEPT (restore never force-logs-out)
```

---

## Clean Architecture Flow

```bash
COMPILE TIME (imports)      RUNTIME (data flow)
──────────────────────      ─────────────────────
Presentation → Domain       Presentation → Domain → Infrastructure
Infrastructure → Domain     (the flow traverses all layers)
Domain → no one
```

At compile time, arrows point inward: Infrastructure imports Domain interfaces, and Domain imports nothing from outer layers.

At runtime, the data flow traverses all layers — Presentation starts, Domain orchestrates, Infrastructure executes. The result comes back the same way.

There are three distinct runtime patterns in this project:

### Sync Simple Pattern

```
Presentation     Domain             Infrastructure     External
────────────     ──────             ──────────────     ───────
UseCase → Repository → Datasource → HTTP/DB/SDK
↕                 ↕
Notifier ←────── Result<T>          Exception → guard()
↕
Widget ←─────── AuthState.loaded()
↕
Navigation (GoRouter via AuthGuard)
```

Used for: Login, Register, Restore session, Standard CRUD, typical GET/POST/PUT/DELETE.

**Key characteristic:** data always returns the way it came. A single causal thread: request → response.

### Outgoing Only Pattern

```
Presentation     Domain             Infrastructure     External
────────────     ──────             ──────────────     ───────
UseCase → DomainService → IPort.log() → LoggerImpl
```

Used for: Failure propagation, logging, analytics, push notifications.

**Key characteristic:** the UI never receives a response. Return type is `void` or `Future<void>`.

### Comparison

| Aspect | Sync Simple | Outgoing Only |
| :--- | :--- | :--- |
| Return value | Yes (Result\<T\>) | No (void) |
| Response time | Blocks until response | Does not block |
| Complexity | Low | Low |
| Testing | Easy (mocks) | Easy (mocks) |
| Focus | Getting data | Emitting signals |
| Example in project | LoginUseCase | localizeError (UI layer) |

---

## Complete login() Flow

```bash
main.dart
└── ProviderScope
└── TudesarrolladorApp (ConsumerStatefulWidget)
    ├── initState → AppInitializer.checkJailbreak() (Android/iOS only)
    ├── initState → ref.read(authProvider.notifier).restoreSession()
    └── build → MaterialApp.router(routerConfig: ref.watch(goRouterProvider))
│
LoginScreen (presentation/screens)
└── ref.read(authProvider.notifier).login(email, password, rememberMe: ref.read(rememberMeProvider))
│
AuthNotifier (presentation/notifiers)
├── state = AuthState.loading()
├── ref.read(loginUseCaseProvider)(LoginInput(email: email, password: password, rememberMe: rememberMe))
│   │
│   LoginUseCase (domain/usecases)
│   ├── Email.result(email) ← value object validation
│   ├── Password.result(password) ← value object validation
│   ├── _passwordHasher.hash(password) ← BcryptWrapper (via IPasswordHasher)
│   ├── _repository.login(email, passwordHash)
│   │   │
│   │   AuthRemoteRepositoryImpl (infrastructure/repositories)
│   │   └── guard(() => _remoteDatasource.login(...))
│   │       │
│   │       AuthRemoteDatasourceImpl
│   │       └── _dio.post(_appUries.login, sla: EndpointSla.login) → HTTP  ← /user/login
│   │       → Result<LoginResponseEntity>
│   │
│   ├── if (rememberMe) _sessionRepository.saveSession(data, email, passwordHash)
│   └── else _tokenStore.save(data.token.key) ← token persistence (only when rememberMe is OFF)
│
└── result.fold<Future<void>>(
  onSuccess: (data) → state = AuthState.loaded(patient, token)
  onFailure: (error) → state = AuthState.failure(error)   ← AppError passed to state; UI localizes via localizeError()
)
│
▼
authenticationObserverProvider → isAuthenticated = true
▼
AuthGuard.redirect → GoRouter redirects to /clinical-history
```

### restoreSession() Flow (for comparison)

```bash
AuthNotifier
└── ref.read(restoreSessionUseCaseProvider).call()
│
RestoreSessionUseCase (domain/usecases)
├── _connectivityChecker.isConnected()? + _credentialStore.readCredentials()?
│   └── online + creds found → _repository.login(email, passwordHash) ← remember-me re-login
│
├── _repository.restoreSession() ← LocalDatasource
├── _tokenVerifier.isExpired(token) ← JwtTokenExpiryChecker (implements ITokenVerifier)
├── _connectivityChecker.isConnected() ← InternetService (implements IConnectivityChecker) (checked again)
└── _tryRefresh(data)
    ├── _repository.refreshToken(token) ← AuthRemoteRepositoryImpl → RemoteDatasource
    ├── on success: _tokenStore.save(newToken.key)
    └── on failure: Success(localData) ← cached session KEPT (restore never force-logs-out)
```

---

## Eliminating Thin Service Adapters

### Problem

The auth feature had 5 service files that were all eliminated. Four were one-line delegations — adapters that existed solely to bridge domain interfaces with shared wrapper implementations. The fifth (`dio_token_retry_handler.dart`) had real logic but was later eliminated when `Handle401UseCase` was refactored to compose the `IUseCase` seams `RefreshTokenUseCase` + `CredentialLoginUseCase`, breaking the Riverpod cycle.

| Service | Lines | Actual logic | Status |
| :--- | :--- | :--- | :--- |
| `connectivity_checker.dart` | 11 | `_internetService.isConnected()` | Eliminated |
| `crypto_password_hasher.dart` | 11 | `_crypto.sha256(password)` | Eliminated |
| `token_expiry_checker.dart` | 11 | `_tokenService.isTokenExpired(token)` | Eliminated |
| `token_credential_store.dart` | 18 | `_tokenService.read()` / `.save()` / `.readCredentials()` | Eliminated |
| `dio_token_retry_handler.dart` | 45 | Real HTTP + JSON logic | **Eliminated** (moved to Handle401UseCase + IAuthRepository) |

### Solution

**Cross-cutting interfaces live in `shared/interfaces/`**, and wrappers in `core/` implement them directly:

```
shared/interfaces/
i_clinical_history_store.dart
i_connectivity_checker.dart
i_credential_store.dart
i_token_store.dart
i_token_verifier.dart
i_password_hasher.dart
i_patient_info_store.dart
i_usecase.dart
```

**Wrappers implement the interfaces directly:**

```dart
core/network/connectivity/internet_service.dart
class InternetService implements IInternetService, IConnectivityChecker { ... }

core/services/auth/secure_token_store.dart
class SecureTokenStore implements ITokenStore { ... }

core/services/auth/secure_credential_store.dart
class SecureCredentialStore implements ICredentialStore { ... }

core/services/auth/jwt_token_expiry_checker.dart
class JwtTokenExpiryChecker implements ITokenVerifier { ... }
```

**Providers expose the wrapper instances under the interface type:**

```dart
// core/services/auth/token_providers.dart
final tokenStoreProvider = Provider<ITokenStore>(
  (ref) => SecureTokenStore(storage: ref.watch(secureStorageProvider)),
);
```

### Eliminated services — `Handle401UseCase` now composes the `IUseCase` seams (`RefreshTokenUseCase` + `CredentialLoginUseCase`)

`Handle401UseCase` used to use a service created inline in `AuthInterceptorImpl` to avoid a Riverpod dependency cycle between `authDioProvider` and `authRemoteDatasourceProvider`.

The solution was to create a separate `authDioProvider` (Dio without an auth interceptor) for the auth datasource, breaking the cycle. Now `Handle401UseCase` composes the `IUseCase` seams (`RefreshTokenUseCase` + `CredentialLoginUseCase`, Rule 18) and reaches the repository only transitively, following the standard `UseCase → Repository → guard() → Datasource` flow.

This eliminated the intermediate services and the inline creation in `AuthInterceptorImpl`. `AuthInterceptorImpl` now receives its dependencies by constructor (3 parameters instead of 6: `handle401UseCase`, `onForceLogout` y `getToken`).

#### Unified with `Result<T>` — `Handle401UseCase` returns `Result<RetryResult>`

`Handle401UseCase` follows the standard pattern. It returns `Future<Result<RetryResult>>` — unified with all other use cases.

```
Datasource pattern:
Datasource → Repository.guard() → Result<T> → UseCase → Notifier.fold()

Handle401UseCase pattern (current):
AuthInterceptor → Handle401UseCase → IAuthRepository (+ RefreshTokenUseCase) → guard() → IAuthRemoteDatasource → HTTP
                                       └→ shared ports (tokenStore, connectivityChecker) wrapped with guard() → Result
```

### Datasource vs Service — when to use each

Both datasources and services live in `infrastructure/` and both can make HTTP calls. The difference is in their **contract** and **who consumes them**:

| Aspect | Datasource | Service |
| :--- | :--- | :--- |
| **Purpose** | Raw data ingestion (HTTP, DB) | Implements a domain interface with infrastructure logic |
| **Return type** | Raw data (`Map`, DTO) | Whatever the domain interface defines |
| **Error handling** | Throws typed exceptions | Self-contained (try/catch, null returns) |
| **Called by** | Repository (wrapped with `guard()`) | UseCase directly |
| **Result for domain** | `Result<T>` (via Repository) | `Result<RetryResult>` (unified) |
| **Lifecycle** | Wired via Riverpod (needs `Ref`) | Same as datasource (via Riverpod) |
| **Example** | `AuthRemoteDatasourceImpl` — POST /login, returns raw JSON | `Handle401UseCase` — flow through `IAuthRepository.refreshToken()`, returns `Result<RetryResult>` |

The flow for each:

**Datasource call (standard CRUD):**
```
Notifier → UseCase → Repository → guard() → Datasource → HTTP
↑ ↑
returns Result<T> throws Exception
```

**Handle401UseCase flow (standard — no separate service):**
```
AuthInterceptor → Handle401UseCase → IAuthRepository.refreshToken() → guard() → IAuthRemoteDatasource → HTTP
↑
returns Result<RetryResult>
```

**Decision guide for new code:**

| Does your class... | Then it is a... |
| :--- | :--- |
| Read/write data from an API or DB and the result must reach the UI? | **Datasource** → goes through Repository → `guard()` → `Result` |
| Need to be available before Riverpod exists? | **Exception** — document it in the architecture |
| Is an adapter that only delegates one method to another wrapper with no real logic? | **NO** — the interface should go to `shared/interfaces/` and the wrapper should implement it directly |

**Rule:** Every flow follows `UseCase → Repository → guard() → Datasource`. There are no intermediate services.
`Handle401UseCase` and `RestoreSessionUseCase` were refactored to follow this rule.

#### Anti-pattern example: thin service adapters

The 4 eliminated services were all thin adapters — less than 18 lines, delegating one method to an existing wrapper with zero transformation:

```dart
// ❌ BAD — features/auth/infrastructure/services/connectivity_checker.dart (REMOVED)
class ConnectivityChecker implements IConnectivityChecker {
  const ConnectivityChecker(this._internetService);
  final IInternetService _internetService;
  @override
  Future<bool> isConnected() => _internetService.isConnected();
}
```

This creates two problems:
1. The interface `IConnectivityChecker` lives in `features/auth/domain/services/`, making a cross-cutting concept auth-specific.
2. The service is a passthrough with no added value — it exists only to connect an interface to an implementation.

**✅ Correct fix:** move the interface to `shared/interfaces/` and have the wrapper implement it directly:

```dart
shared/interfaces/i_connectivity_checker.dart
abstract interface class IConnectivityChecker {
  Future<bool> isConnected();
}

core/network/connectivity/internet_service.dart
class InternetService implements IInternetService, IConnectivityChecker {
  @override
  Future<bool> isConnected() => _connectionChecker.checkConnectivity();
}
```

**Practical rule for detecting a thin service:** If the service has fewer than 15 lines and only delegates a method to another wrapper without data transformation, it is a sign that the interface should be in `shared/interfaces/` and the wrapper should implement it directly.

### Why `shared/interfaces/` and not `shared/domain/interfaces/`

The `shared/` folder is organized by **type of content**, not by layer:

| Folder | Type | Layer |
| :--- | :--- | :--- |
| `models/` | Domain entities | Domain |
| `interfaces/` | Domain interfaces | Domain |
| `exceptions/` | Failure types | Domain |
| `error/` | `AppError`, `Result<T>`, `guard()` | Domain (`localizeError()` lives in `l10n/`, UI layer) |
| `functions/` | Online-first helper (`online_first.dart`) | Infrastructure |
| *(migrated to design_system/)* | Theme & colors (AppColors, AppTheme) | Presentation |

No folder under `shared/` uses a layer name (`domain/`, `infrastructure/`, `presentation/`). Adding `domain/interfaces/` would break this convention — it would be the only folder organized by layer. `shared/interfaces/` follows the existing pattern: named by type, parallel to `shared/models/`.

### `RestoreSessionUseCase` depends only on `shared/interfaces/`

`RestoreSessionUseCase` persists the refreshed token via `ITokenStore` (from `shared/interfaces/`) and composes single-responsibility use cases (`CredentialLoginUseCase`, `RefreshTokenUseCase`), keeping the domain layer free of infrastructure imports:

```dart
class RestoreSessionUseCase {
  final ITokenStore _tokenStore;
  final CredentialLoginUseCase _credentialLoginUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  ...
  await _tokenStore.save(tokenData.key);
}
```

The domain layer imports only `shared/interfaces/` abstractions and `shared/exceptions/` exception types — no infrastructure packages.

### Domain Dependency Map

After all refactoring, the domain layer (`features/auth/domain/`) has clear boundaries:

**The domain only imports from:**

| Imports from | Types |
| :--- | :--- |
| `shared/interfaces/` | `IConnectivityChecker`, `ICredentialStore`, `ITokenStore`, `ITokenVerifier`, `IPasswordHasher` |
| `shared/error/` | `Result`, `Success`, `Failure`, `RetryResult`, `RetrySuccess`, `RetryFailed`, `AppError` subtypes |
| Its own files | Entities, value objects, repositories, datasources, use cases |

> `shared/exceptions/` is NOT imported by the domain: the typed exceptions (`ApiException`, `NoConnectionException`, `ServerUnreachableException`, `UnexpectedResponseException`, `AppTimeoutException`, `DeviceSecurityException`) are **thrown by infrastructure datasources** and mapped by `guard()` in `shared/error/result_guard.dart`.

**The domain NEVER imports (and should not):**

| Does not import | Reason |
| :--- | :--- |
| `core/services/` or `core/network/dio/` | Contains external package wrappers (infrastructure) |
| `core/network/interceptors/` | Contains Dio interceptors (infrastructure) |
| `core/database/` | Contains sembast persistence (infrastructure) |
| `app/` | Contains the composition root (global providers, router) |
| `infrastructure/` of any feature | Violates the Clean Architecture Dependency Rule |
| `presentation/` of any feature | The domain must not know about UI |

### What was kept

All services were eliminated. The logic was moved into use cases (`Handle401UseCase`, `RestoreSessionUseCase`) that compose the `IUseCase` seams and reach the repository only transitively (Rule 18), following the standard `UseCase → Repository` flow.

### Test impact

All unit tests and integration tests pass without behavioral changes. The only test modifications were:
- Imports updated to the current structure (`shared/error/_error.lib.dart`, `shared/interfaces/_interfaces.lib.dart`, feature domain files)
- Mocks/fakes implement the domain contracts (`ITokenStore`, `ICredentialStore`, `IUseCase<...>`, `ILogger`)

---

## Architectural decisions for a new project (lessons learned)

This project was built incrementally and some conventions evolved over time. If starting a new Clean Architecture project from scratch in a large company, here is what would likely change:

### 1. Folder structure: `app/` (composition root) + `core/` + `shared/`

The project completed the migration from a mixed `shared/` folder to a clean separation:

```
lib/
├── app/       ← Composition root (DI seams, router, guard, app initializer)
├── shared/    ← Pure domain abstractions
│   ├── interfaces/
│   ├── exceptions/
│   ├── error/
│   ├── models/
│   ├── router/ (AppRoute — typed route registry)
│   └── functions/ (online_first)
├── core/      ← Pure infrastructure
│   ├── config/    (AppEnvironment, environmentProvider)
│   ├── database/  (AppDatabase, sembast wrapper, tables, serializers)
│   ├── network/   (dio_wrapper, interceptors, connectivity, timeouts, retry, security)
│   └── services/  (auth, crypto, device, storage)
├── design_system/ ← Theme & reusable UI components
├── l10n/      ← AppLocalizations (i18n)
└── features/
    ├── auth/  ← di/, domain/, infrastructure/, presentation/, spec/
    └── clinical_history/  ← di/, domain/, infrastructure/, presentation/, spec/
```

**Why:** The dependency direction becomes visible in the import path. If a domain file imports from `core/`, it is immediately visible as a violation. `shared/` is pure domain, `core/` is pure infrastructure, `app/` is the composition root. No mixing.

### 2. Naming: descriptive suffixes, not cryptic prefixes

The project uses descriptive names like `dio_wrapper.dart`, `secure_token_store.dart`, `jwt_token_expiry_checker.dart`. Wrappers of external packages follow the `<package>_wrapper.dart` pattern (see `MD/APP_PACKAGE_WRAPPER.md`).

| File | Class(es) |
| :--- | :--- |
| `dio_wrapper.dart` | `DioWrapper` / `IDioWrapper` |
| `secure_token_store.dart` | `SecureTokenStore` (implements `ITokenStore`) |
| `jwt_token_expiry_checker.dart` | `JwtTokenExpiryChecker` (implements `ITokenVerifier`) |

The file name `dio_wrapper.dart` tells exactly what it is without needing to know project-specific conventions.

### 3. Use Dart 3 sealed classes + freezed (current pattern)

The project uses `sealed class Result<T>` with `Success` and `Failure` variants, plus `guard()`. Domain entities and states use `@freezed` with Dart 3 sealed classes:

```dart
sealed class Result<T> {
  const Result();
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  });
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
  ...
}

final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
  ...
}
```

Usage — Dart 3 pattern matching with `is` / `case` checks:

```dart
if (result is Success) {
  final data = (result as Success).data;
} else if (result is Failure) {
  final error = (result as Failure).error;
}
```

Or with `switch` / `case` patterns:

```dart
return switch (result) {
  Success(data: final d) => AuthState.loaded(...),
  Failure(error: final e) => AuthState.failure(e),
};
```

**Benefits:** native exhaustiveness checking + zero-boilerplate immutable classes (generated by `freezed`).

### 4. Code generation: yes, but scoped

The project **does** use code generation, but only for three concerns:
- `freezed` — immutable data classes, unions, sealed states.
- `json_serializable` — DTO `fromJson`/`toJson`.
- `riverpod_generator` — Riverpod providers/notifiers.

```bash
dart run build_runner build --delete-conflicting-outputs
```

Everything else (repository logic, datasources, mappers, use cases, wiring decisions) is written by hand. This keeps the generated surface small and predictable.

### 5. Riverpod v3 code-gen Notifier pattern

**Current:** Notifiers use `@Riverpod` code-gen with `extends _$AuthNotifier`:

```dart
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    state = const AuthState.loading();
    final result = await ref.read(loginUseCaseProvider)(
      LoginInput(email: email, password: password, rememberMe: rememberMe),
    );
    await result.fold<Future<void>>(
      onSuccess: (data) async {
        state = AuthState.loaded(patient: data.patient, token: data.token, ...);
      },
      onFailure: (error) async {
        state = AuthState.failure(error);
      },
    );
  }
}
```

This is the Riverpod v3 code-gen pattern: annotated notifiers, generated `*_notifier.g.dart` files.

### 6. Error handling: typed errors with metadata (no `userMessage`)

**Current:** Each `AppError` subtype is a sealed class carrying typed metadata (`field`, stack trace, diagnostic `technicalMessage`) and behavior flags (`isNetworkRelated`, `isTransient`). **`AppError` has no `userMessage`** — the UI maps types to localized strings via `localizeError()`. `technicalMessage`/`stackTrace` are diagnostic-only, consumed by the `ILogger` observability seam (`shared/interfaces/`, `loggerProvider`) in the notifiers.

**Pattern:**
- `guard()` maps exceptions to typed `AppError` subtypes (constructors take only named args — no positional message).
- UI layer maps types to localized strings via `localizeError()` from `l10n/error_localizer.dart`.
- `Handle401UseCase` reads `error.isTransient` (data-driven, no `is` dispatch) to decide retry vs logout.

```dart
sealed class AppError {
  final String? technicalMessage;
  final StackTrace? stackTrace;
  const AppError({this.technicalMessage, this.stackTrace});

  bool get isNetworkRelated => false;
  bool get isTransient => false;

  @override
  String toString() => '$runtimeType(technicalMessage: $technicalMessage)';
}

final class NetworkError extends AppError {
  const NetworkError({super.technicalMessage, super.stackTrace});

  @override
  bool get isNetworkRelated => true;
  @override
  bool get isTransient => true;
}

final class ValidationError extends AppError {
  final String? field;
  const ValidationError({super.technicalMessage, super.stackTrace, this.field});
}
```

**Why:** Errors carry typed metadata (field name, stack trace, diagnostic `technicalMessage`) instead of hiding it in a string. All user-facing strings are centralized in l10n/ and mapped via `localizeError()` — a single source of truth, with no duplicated `userMessage` field. Diagnostic detail flows to `ILogger` for observability. Coverage of the guard ↔ localizer mapping is enforced by `test/architecture/error_mapping_consistency_test.dart`.

### 7. Service locator only for infrastructure, not for domain

`core/` source files centralize the shared global providers. Each feature's `di/` imports directly the providers it needs from `core/` source files. The composition root is `app/`.

### Comparison table

| Decision | This project |
| :--- | :--- |
| Folder separation | `app/` (composition) + `shared/` (domain) + `core/` (infra) |
| Naming | `_wrapper` suffix (descriptive) |
| Result/AppError | Dart 3 sealed class (native) |
| Code generation | `freezed` + `json_serializable` + `riverpod_generator` (scoped) |
| Providers | `@riverpod` code-gen + `@Riverpod` Notifiers |
| Error model | `AppError` (typed fields) + `localizeError()` |
| Service locator | Riverpod providers wired via `core/` + feature `di/` (no app barrel) |
| Navigation | `goRouterProvider` (Riverpod) + `AuthGuard` + `AppRoute` enum |
| Tests | By layer (app/core/shared/features/bdd) |

### Summary

The project uses **scoped code generation** (`freezed`, `json_serializable`, `riverpod_generator`) plus Dart 3 sealed classes + pattern matching. Manual Riverpod providers complement the generated ones for global singletons (`Provider` / `NotifierProvider`).

These decisions are not about right vs wrong — they are about **when complexity is justified**. This project chose to keep the generated surface small (immutables + providers only) for faster builds, fewer CI failures, and simpler onboarding.

---

## CI/CD Pipeline (GitHub Actions)

### Workflow overview

The CI pipeline lives in `.github/workflows/ci.yml`. It runs on every `push` to `develop`/`main` and on every `pull_request` targeting those branches.

| Job | `runs-on` | What it does |
|-----|-----------|--------------|
| `Analyze` | `ubuntu-latest` | `flutter pub get` + `flutter analyze` (0 issues) |
| `Test` | `ubuntu-latest` | `flutter test --coverage --exclude-tags golden` (unit/widget) + Codecov upload + anti-masking workflow gates |
| `Test Goldens` | `ubuntu-latest` | `flutter test --tags golden` (cross-platform golden image tests) |
| `Build iOS` | `macos-latest` | `flutter build ios --no-codesign` |
| `Build Android` | `ubuntu-latest` | `flutter build apk --debug` |

Key design decisions:

- **Runners by real need:** Only `Build iOS` requires macOS (Xcode). Analyze, Test, Test Goldens and Build Android run on Linux, cutting macOS usage to a single job.
- **Builds decoupled from tests:** `Build iOS` and `Build Android` depend only on `Analyze` (`needs: [analyze]`), not on `Test`. This guarantees that a build/compile regression is never masked by a failing test job. Enforced structurally by `test/architecture/workflow_gates_test.dart`.
- **Anti-masking gates:** `test/architecture/workflow_gates_test.dart` (runs inside `Test`, no `golden` tag) blocks the merge if CI regresses: Analyze/Test/Test Goldens not on Linux, golden tests without `@Tags(['golden'])`, builds depending on `Test`, or more than 2 macOS jobs.
- **Caching:** all jobs enable `cache: true` on `subosito/flutter-action@v2`; `Build iOS` additionally caches CocoaPods (`actions/cache@v6`, `ios/Pods`).
- **Least privilege:** `permissions: contents: read` on the whole workflow.
- **Concurrency:** `concurrency: ci-${{ github.ref }}` with `cancel-in-progress: true` cancels superseded runs, saving minutes and avoiding races.
- **Pinned Flutter version:** All jobs pin `flutter-version: '3.44.0'`.

### Golden tests

Golden tests are tagged with `@Tags(['golden'])` (declared via `@Tags(['golden']) library;` at the top of each golden test file). The `golden` tag is declared in the root `dart_test.yaml` (`tags: golden`), so the runner emits no "A tag was used that wasn't specified in dart_test.yaml" warning. They are **cross-platform**: `test/flutter_test_config.dart` loads the embedded fonts (`test/assets/` — Roboto Regular/Medium/Bold + MaterialIcons) via `FontLoader` and installs a tolerant `GoldenFileComparator` (2% pixel threshold). Determinism comes from the fonts; the tolerance absorbs subtle anti-aliasing differences between Linux CI and macOS local. They run on **Linux** in the dedicated `Test Goldens` job. The main `Test` job excludes them with `--exclude-tags golden`.

Golden files are committed under `test/**/goldens/`. Regenerate after visual changes with:

```bash
flutter test --tags golden --update-goldens
```

### Coverage

- `flutter test --coverage` produces `coverage/lcov.info`.
- `codecov/codecov-action@v7` uploads it to Codecov with `fail_ci_if_error: false` (a Codecov outage must not break the pipeline).
- The repo is **public**, so Codecov uploads are unlimited and GitHub Actions minutes are free.
- `codecov.yml` configures the status checks:
  - `project` — overall coverage vs base, `target: auto`, `threshold: 1%`.
  - `patch` — coverage of the new lines in the PR, `target: auto`, `threshold: 1%`.

### Dependabot

`.github/dependabot.yml` enables weekly automated updates for:
- `pub` (Dart/Flutter dependencies)
- `github-actions` (GitHub Actions versions)

Updates are **grouped** to reduce PR churn and cross-dependency conflicts:
`riverpod`, `flutter-plugins`, `test-tooling`, `codegen`, `actions`.
Semver-major of `flutter_jailbreak_detection_plus` is ignored (no iOS Swift
Package Manager support yet — only minor/patch via auto-merge).

`.github/workflows/auto-merge.yml` **auto-merges dependabot patch/minor PRs**
(`gh pr merge --auto --squash`) via `dependabot/fetch-metadata@v3`; major
updates require review.

### Branch protection (`develop`)

`develop` is protected and requires all 5 checks to pass before merging (`strict: true`, so PRs must be up to date with `develop`):

`Analyze`, `Test`, `Test Goldens`, `Build iOS`, `Build Android`

No required reviewers are configured (single-account repo — PRs are self-approved after passing the 6 quality gates of the `super-pull-request-reviewer` command).

### Merge strategy

GitHub **merge queue is not available on personal accounts** (organization feature), so the repo uses the documented fallback:
- **Auto-merge** (`allow_auto_merge: true`) — PRs merge as soon as CI passes.
- **Squash** on merge (`squash_merge_commit_title: PR_TITLE`, `squash_merge_commit_message: PR_BODY`) — one clean commit per PR.
- **Delete branch on merge** (`delete_branch_on_merge: true`).
- **Allow update branch** (`allow_update_branch: true`).
- Dependabot patch/minor auto-merge via `auto-merge.yml`.

This yields the same outcome a merge queue would (clean history, no `Merge branch` noise, branches auto-removed) without the queue.

### Security features

Since the repo is public:
- **Dependabot alerts** (vulnerability alerts) enabled.
- **Dependabot security updates** enabled.
- **Secret scanning** enabled.
- **Secret scanning push protection** enabled.
- The full git history was scanned with `gitleaks` (no real secrets found — only an expired test JWT fixture that was later removed).
- **Gitleaks CI gate**: `gitleaks/gitleaks-action@v3` in the `Gitleaks` job (ubuntu-latest, full history scan with `fetch-depth: 0`, fails on findings) — blocks merges that leak secrets. The workflow gates assert this job always exists.

### Plugins

`flutter_jailbreak_detection_plus` (maintained fork) is used instead of the unmaintained `flutter_jailbreak_detection` because the original did not declare `namespace`/`compileSdk 34`/JVM 17, breaking Android builds on AGP 8+. A minimal JVM-target fix for the fork remains in `android/build.gradle.kts`.

### Cost summary

| Aspect | Before | After |
|--------|--------|-------|
| macOS jobs | 3 (`Analyze`, `Test`, `Build iOS`) | 1 (`Build iOS`) |
| Cost/min macOS | $0.062 | $0.062 (only where required) |
| Cost/min Linux | — | $0.006 (Analyze, Test, Test Goldens, Build Android) |
| Runner caching | — | `flutter-action` cache + CocoaPods cache |
| Public repo | — | GitHub Actions free, Codecov unlimited |
