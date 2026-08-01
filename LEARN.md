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
Inner layer:  domain/   →  only imports shared/ (enterprise rules)  ✅
Middle layer: core/     →  imports shared/ but NEVER features/      ✅
Outer layer:  app/di/ + core/  →  may import ALL layers             ✅
```

Dependencies always point inward:

```
shared/  ←  core/  ←  features/*/domain/  ←  features/*/infrastructure/  ←  features/*/presentation/  ←  app/ (composition root)
(most inner)                                                                                (most outer)
```

### What is a Composition Root?

It is the app's **entry point** where the dependency graph is built. In this Flutter project, the composition root lives in `lib/app/di/`. The barrel `lib/app/di/_providers.lib.dart` re-exports all shared providers, and the feature `di/` folders wire domain interfaces to infrastructure implementations.

In any system with Dependency Injection, **someone** must know all the dependencies to build them. That someone is the Composition Root. It is intentionally "dirty" — it knows all layers so it can join them together.

### Why does this NOT violate Clean Architecture?

Clean Architecture says: **the direction of the dependencies** must go from the outside in. The source code of inner layers must not mention outer layers.

```
Inner layer (domain/)  →  does NOT mention outer layers  ✅
Outer layer (app/ + core/)  →  DOES mention inner layers  ✅
```

`app/` and `core/` are the **most outer layers** — they may mention anything because there is nothing further out that could depend on them incorrectly.

The rule is: **what cannot happen** is `domain/` importing `app/`, `core/` or any provider-wiring barrel (`app/di/`). That does break Clean Architecture. But outer layers importing `domain/` is the natural flow: the outer knows the inner.

### Definition of the key concepts

#### `shared/` — Enterprise Business Rules (most inner layer)

Contains the business rules **shared by the whole app**. It does not depend on Flutter, databases, or any specific feature.

| What goes here | Concrete example |
|-------------|-----------------|
| Abstract interfaces | `ITokenStore`, `IConnectivityChecker`, `IAuthenticationObserver`, `ICredentialStore`, `ITokenVerifier`, `IPasswordHasher`, `IAppDatabase` |
| Error types | `AppError`, `Result<T>`, `guard()`, `localizeError()` |
| Shared models | `PatientEntity`, `ClinicalHistoryEntity` + 6 sub-entities |
| Offline-first mixin | `offline_first_repository.dart` |

**Rule:** `shared/` must NOT import `core/`, `features/`, `app/`, or any external package (only the Dart SDK).

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
| `features/*/domain/` | Feature business rules (use cases, entities, interfaces, value objects) | Only `shared/` |
| `features/*/infrastructure/` | Implementations of the domain interfaces | `domain/`, `core/`, `shared/` |
| `features/*/di/` | Feature wiring (Riverpod providers) | `core/`, `shared/`, own `domain/` + `infrastructure/` (never `presentation/`) |
| `features/*/presentation/` | Feature UI (screens, widgets, notifiers) | `../di/`, `shared/`, `design_system/`, `l10n/` |
| `features/*/spec/` | SDD artifacts (`spec.md`, `domain.md`, `contracts.md`, `bdd.feature`, `tests.md`, `tasks.md`) | — |

**Rule:** A feature NEVER imports from another feature. Each feature is independent.

#### `app/` — Composition Root (most outer layer)

`lib/app/` is the application composition root. It knows ALL layers because it wires them together:

| What goes here | Concrete example |
|-------------|-----------------|
| Composition root barrel | `app/di/_providers.lib.dart` (exports all shared providers) |
| Dio providers | `app/di/network/dio_provider.dart` → `authDioProvider` + `httpServiceProvider` |
| Auth interceptor wiring | `app/di/network/auth_interceptor_impl.dart` → `AuthInterceptorImpl` |
| Router provider | `app/di/router/router_provider.dart` → `goRouterProvider` |
| Auth observer | `app/di/auth/auth_provider.dart` → `authenticationObserverProvider` |
| Routing definitions | `app/router/app_route.dart`, `app/router/app_router.dart`, `app/router/guards/auth_guard.dart` |
| Initialization | `app/app_initializer.dart` → platform config + jailbreak check |

**Rule:** `app/` may import any `lib/` folder. No lower layer imports `app/` — the only exceptions are features that import the `app/di/_providers.lib.dart` barrel for global providers (this is the documented pattern for accessing global providers from feature code).

**Global provider access from features:** features import the shared providers they need from the `app/di/_providers.lib.dart` barrel (or directly from their `core/` source files), and define their own wiring in `features/*/di/`.

```dart
// Global providers come from the app/di barrel or core barrels:
// app/di/_providers.lib.dart   → authDioProvider, httpServiceProvider, appDatabaseProvider,
//                                clinicalHistoryStoreProvider, patientInfoStoreProvider,
//                                tokenStoreProvider, tokenVerifierProvider, credentialStoreProvider,
//                                passwordHasherProvider, connectivityCheckerProvider,
//                                internetServiceProvider, environmentProvider, goRouterProvider
// core/services/device/        → pathProviderProvider, flutterJailbreakDetectionProvider
```

| Provider | Type | Provider location |
|---|---|---|
| `authDioProvider` | `IDioWrapper` | `app/di/network/dio_provider.dart` |
| `httpServiceProvider` | `IDioWrapper` | `app/di/network/dio_provider.dart` |
| `goRouterProvider` | `GoRouter` | `app/di/router/router_provider.dart` |
| `authenticationObserverProvider` | `IAuthenticationObserver` | `app/di/auth/auth_provider.dart` |
| `appNameProvider` | `String` | `features/auth/di/auth_provider.dart` |
| `tokenStoreProvider` | `ITokenStore` | `core/services/auth/token_providers.dart` |
| `tokenVerifierProvider` | `ITokenVerifier` | `core/services/auth/token_providers.dart` |
| `credentialStoreProvider` | `ICredentialStore` | `core/services/auth/token_providers.dart` |
| `jwtWrapperProvider` | `IJwtWrapper` | `core/services/auth/token_providers.dart` |
| `secureStorageProvider` | `ISecureStorageWrapper` | `core/services/auth/token_providers.dart` |
| `appDatabaseProvider` | `IAppDatabase` | `core/database/app_database_provider.dart` |
| `clinicalHistoryStoreProvider` | `IClinicalHistoryStore` | `core/database/tables/clinical_history.dart` |
| `patientInfoStoreProvider` | `IPatientInfoStore` | `core/database/tables/patient_info.dart` |
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
| `loginUseCaseProvider` | `LoginUseCase` | `features/auth/di/auth_provider.dart` |
| `clearSessionUseCaseProvider` | `ClearSessionUseCase` | `features/auth/di/auth_provider.dart` |
| `refreshTokenUseCaseProvider` | `RefreshTokenUseCase` | `features/auth/di/auth_provider.dart` |
| `restoreSessionUseCaseProvider` | `RestoreSessionUseCase` | `features/auth/di/auth_provider.dart` |
| `handle401UseCaseProvider` | `Handle401UseCase` | `features/auth/di/auth_provider.dart` |
| `rememberMeProvider` | `bool` (Notifier) | `features/auth/di/remember_me_provider.dart` |

#### `design_system/` — UI primitives

Reusable visual components with no business logic.

| What goes here | Concrete example |
|-------------|-----------------|
| Theme | `AppColors`, `AppTheme` |
| Components | `LoadingIndicator` |

**Rule:** Only imports Flutter. Does not import `core/`, `shared/`, or `features/`.

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

- `domain/` (Core Business Logic): The completely isolated layer that defines the business rules. It contains enterprise Entities, value objects, abstract contracts for data sources and repositories, and specific business orchestrators (Use Cases). It remains completely independent of any external library or framework.

- `infrastructure/` (Data & External Integrations): Implements the contracts defined in the Domain layer. It handles raw data fetching via concrete Datasources (REST APIs, Local DBs), maps external data structures into Domain Entities using Mappers (DTO → Entity), and coordinates data flow through Repository implementations.

- `di/` (Dependency Injection — Wiring): Feature-specific Riverpod providers that wire domain interfaces to infrastructure implementations. This is a **peer** of the other layers, not a subfolder of `presentation/`, because it knows about **all** layers: imports `core/`, `domain/`, and `infrastructure/`, but **never** imports `presentation/`. The dependency direction is `presentation/ → di/ → domain/ + infrastructure/ + core/`.

- `presentation/` (UI & State Management): Manages how the feature is displayed and how users interact with it. It contains Screens (views), atomic Widgets, and State Notifiers (`Notifier` + `State`). The **only** import toward other feature layers is `presentation/notifiers/ → di/` (notifiers consume providers from `di/`). It never contains Riverpod providers — those live in `di/`.

- `spec/` (Specification-Driven Development - SDD): The source of truth for the feature's requirements. It centralizes BDD Gherkin scenarios (`.feature`), functional contracts, API schemas, and task checklists, serving as the blueprint for both automated tests and implementation.

```bash
├── features
│ └── auth
│     ├── di/              ← Peer layer (WIRING): imports core/ + domain/ + infrastructure/
│     │   ├── auth_provider.dart        ← @riverpod providers (datasources, repository, use cases)
│     │   ├── auth_provider.g.dart      ← generated by riverpod_generator
│     │   └── remember_me_provider.dart ← NotifierProvider<bool>
│     ├── domain/          ← Innermost layer (BUSINESS): 0 imports from outer layers
│     │   ├── datasources
│     │   │   ├── i_auth_datasource.dart
│     │   │   └── i_local_auth_datasource.dart
│     │   ├── entities
│     │   │   ├── login_response_entity.dart   (@freezed)
│     │   │   ├── token_entity.dart            (@freezed)
│     │   │   └── *.freezed.dart               ← generated by freezed
│     │   ├── repositories
│     │   │   └── i_auth_repository.dart
│     │   ├── usecases
│     │   │   ├── clear_session_usecase.dart
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
│     │       └── auth_repository_impl.dart
│     ├── presentation/    ← Outer layer (UI): imports di/
│     │   ├── notifiers
│     │   │   ├── auth_notifier.dart   ← @Riverpod(keepAlive: true) Notifier
│     │   │   ├── auth_notifier.g.dart
│     │   │   ├── auth_state.dart      ← @freezed sealed class
│     │   │   └── auth_state.freezed.dart
│     │   ├── screens
│     │   │   ├── clinical_history_placeholder_screen.dart
│     │   │   └── login_screen.dart
│     │   └── widgets
│     │       ├── _widgets.lib.dart
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
│         ├──▶ app/di/_providers.lib.dart      (global providers: authDioProvider,
│         │                                      appDatabaseProvider, tokenStoreProvider, ...)
│         ├──▶ ../domain/datasources/i_auth_datasource.dart
│         ├──▶ ../domain/datasources/i_local_auth_datasource.dart
│         ├──▶ ../domain/repositories/i_auth_repository.dart
│         ├──▶ ../domain/usecases/*.dart
│         ├──▶ ../infrastructure/datasources/*_impl.dart
│         └──▶ ../infrastructure/repositories/auth_repository_impl.dart
│
│       (does NOT import presentation/ — 0 paths toward ../presentation/)
│
└── presentation/
    └── notifiers/
        └── auth_notifier.dart
              │
              └──▶ imports ../../di/auth_provider.dart   ← ÚNICA flecha hacia di/
```

`auth_provider.dart` in `di/` imports from `app/di/` (global providers), `../domain/` and `../infrastructure/`, but **never** from `../presentation/`. In contrast, `auth_notifier.dart` in `presentation/` imports from `../../di/auth_provider.dart` — the direction is `presentation → di`, not the other way around.

If `di/` were inside `presentation/`, the semantics would be misleading: it would suggest that wiring is a "kind of UI", when in reality it is the layer that orchestrates all the others. Placing it as a peer of `domain/`, `infrastructure/` and `presentation/` reflects its true architectural role.

| Layer | Imports from | What it contains |
|------|-----------|----------------|
| `domain/` | nothing external | Entities, interfaces, value objects, use cases |
| `infrastructure/` | `domain/` + `core/` + `shared/` | Concrete implementations, DTOs, mappers |
| `di/` | `app/di/` (global providers) + `domain/` + `infrastructure/` | Providers that WIRE (never UI) |
| `presentation/` | `di/` + widgets/screens | Notifiers, screens, widgets |

### 2. The app/, core/ and shared/ Directories

Cross-cutting concerns, global configurations, and reusable utilities that are shared across multiple features are centralized here to avoid duplication:

- `app/`: Application composition root — `di/_providers.lib.dart` (barrel of all shared providers), `di/network/` (Dio providers + auth interceptor impl), `di/router/` (`goRouterProvider`), `di/auth/` (`authenticationObserverProvider`), `router/` (routes, guard, AppRoute enum), `app_initializer.dart`.

- `core/`: Pure infrastructure — `database/` (AES-256-CBC encrypted sembast), `network/` (Dio wrapper, connectivity, interceptors, timeouts, retry, security, utils), `services/` (auth, crypto, device, storage), `config/` (AppEnvironment).

- `core/database/`: Centralized persistence layer configuration (AES-256-CBC encrypted sembast) accessible by any datasource via `appDatabaseProvider`. It exposes `app_database.dart`, `sembast_db_wrapper.dart` (`ISembastDb`), `tables/` (clinical_history, patient_info), `serializers/`.

- `shared/error/`: `AppError` sealed hierarchy (ApiError, NetworkError, ServerUnreachableError, ValidationError, UnexpectedError, DeviceSecurityError), `Result<T>` with `guard()`, `error_localizer.dart`.

- `core/network/`: Network layer — Dio wrapper (`dio/`), connectivity checkers (`connectivity/`), interceptors (`interceptors/`), per-endpoint timeout configuration (`timeouts/`), retry logic (`retry/`), certificate pinning (`security/`).

- `core/services/`: Shared services organized by domain: `auth/` (token, JWT, credentials, observer), `crypto/` (bcrypt hashing), `device/` (path_provider, jailbreak detection), `storage/` (secure_storage).

- `shared/`: Pure domain abstractions — `error/` (AppError, Result, guard, localizeError), `exceptions/` (exception classes), `interfaces/` (IAppDatabase, ICredentialStore, IConnectivityChecker, ITokenStore, ITokenVerifier, IAuthenticationObserver, IPasswordHasher), `models/` (shared domain entities: PatientEntity, ClinicalHistoryEntity + sub-entities), `functions/` (offline_first_repository).

```bash
lib/
├── main.dart
│
├── app/                                ← Composition root
│   ├── app_initializer.dart            ← Platform config + jailbreak check
│   ├── di/
│   │   ├── _providers.lib.dart         ← Barrel of ALL shared providers (composition root)
│   │   ├── auth/
│   │   │   └── auth_provider.dart      ← authenticationObserverProvider
│   │   ├── network/
│   │   │   ├── auth_interceptor_impl.dart
│   │   │   └── dio_provider.dart       ← authDioProvider + httpServiceProvider
│   │   └── router/
│   │       └── router_provider.dart    ← goRouterProvider
│   └── router/
│       ├── app_route.dart              ← AppRoute enum
│       ├── app_router.dart             ← appRoutes()
│       └── guards/
│           └── auth_guard.dart         ← AuthGuard (redirect logic)
│
├── core/                               ← Pure infrastructure
│   ├── config/                         ← app_environment.dart, environment_provider.dart
│   ├── database/                       ← AppDatabase (sembast, AES-256-CBC), tables/, serializers/
│   ├── network/                        ← dio/, connectivity/, interceptors/, retry/, security/, timeouts/, utils/
│   └── services/                       ← auth/, crypto/, device/, storage/
│
├── design_system/                      ← Theme (AppColors, AppTheme), components (LoadingIndicator)
│
├── features/
│   └── auth/                           ← di/, domain/, infrastructure/, presentation/, spec/
│
├── l10n/                               ← app_en.arb, app_es.arb, app_localizations*.dart
│
└── shared/                             ← Pure domain abstractions
    ├── error/                          ← AppError sealed hierarchy, Result<T>, guard(), error_localizer
    ├── exceptions/                     ← ApiException, NoConnectionException, DeviceSecurityException, etc.
    ├── functions/                      ← offline_first_repository.dart
    ├── interfaces/                     ← IAppDatabase, IConnectivityChecker, ICredentialStore, ITokenStore, ITokenVerifier, IAuthenticationObserver, IPasswordHasher
    └── models/                         ← PatientEntity, ClinicalHistoryEntity + sub-entities
```

### 3. Startup — main.dart + AppInitializer

Platform configuration is handled in `lib/app/app_initializer.dart` and invoked from `main.dart`.

```dart
// main.dart
void main({List<Override> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  AppInitializer.configurePlatform(); // orientation lock
  runApp(
    ProviderScope(overrides: overrides, child: const TudesarrolladorApp()),
  );
}
```

`TudesarrolladorApp` (`ConsumerStatefulWidget`) runs the startup sequence in `initState`:

```dart
Future<void> _init() async {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS)) {
    await AppInitializer.checkJailbreak(
      detection: ref.read(flutterJailbreakDetectionProvider),
    );
  }
  await ref.read(authProvider.notifier).restoreSession();
  if (mounted) setState(() => _initialized = true);
}
```

While `_initialized == false`, the app shows a `MaterialApp` with a `LoadingIndicator`. After initialization it builds `MaterialApp.router` with `ref.watch(goRouterProvider)`.

#### Jailbreak detection — implemented

The jailbreak check **is implemented** (in `lib/app/app_initializer.dart` + `lib/core/services/device/`):

```dart
// lib/app/app_initializer.dart
class AppInitializer {
  static Future<void> checkJailbreak({
    required IJailbreakDetectionWrapper detection,
  }) async {
    if (await detection.isJailbroken()) {
      throw DeviceSecurityException();
    }
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
| `shared/` | **Enterprise Business Rules** | Global business rules: `AppError`, `Result<T>`, `guard()`, shared interfaces (`ITokenStore`, `IConnectivityChecker`, `IAppDatabase`, ...), shared models (`PatientEntity`, `ClinicalHistoryEntity`), exceptions (`ApiException`, `DeviceSecurityException`), `offline_first_repository` | Only `shared/` |
| `features/*/domain/` | **Application Business Rules** | Feature-specific business rules: use cases (`LoginUseCase`, `RestoreSessionUseCase`), entities (`TokenEntity`), repository interfaces (`IAuthRepository`), value objects (`Email`, `Password`) | `shared/` |
| `features/*/infrastructure/` | **Interface Adapters** | Concrete implementations of the domain interfaces: datasources, repositories, mappers, DTOs | `features/*/domain/`, `core/`, `shared/` |
| `core/` | **Interface Adapters** (shared) | Infrastructure SHARED between features: HTTP client (`DioWrapper`), database (`AppDatabase`), services (`SecureTokenStore`, `JwtWrapper`, `SecureStorageWrapper`), connectivity (`InternetService`), security (`CertificatePinner`) | `shared/`, `core/` (NEVER `features/`, NEVER `app/`) |
| `features/*/di/` | **Wiring** | Riverpod providers that wire domain interfaces to infrastructure implementations | `app/di/` (global providers), own `domain/` + `infrastructure/`, `core/`, `shared/` |
| `features/*/presentation/` | **Frameworks & Drivers** | Feature-specific UI: screens, widgets, notifiers (Riverpod). Contains the only import toward `di/` | `features/*/di/`, `shared/`, `design_system/`, `l10n/` |
| `app/` | **Frameworks & Drivers** (Composition Root) | Outer layer. Contains `di/` (all shared providers barrel), `router/` (goRouter, guard, routes), `app_initializer.dart` | Any `lib/` |
| `design_system/` | **Frameworks & Drivers** | UI primitives with no business logic: theme (`AppColors`, `AppTheme`), reusable components (`LoadingIndicator`) | Only Flutter |
| `l10n/` | **Frameworks & Drivers** | Internationalization: `AppLocalizations` with EN/ES keys for labels and error messages | Only Flutter |

#### What can each layer import? (with real project paths)

```
┌──────────────────────────────────────────────────────────┐
│                      app/di/ (outer)                      │
│  lib/app/di/_providers.lib.dart                            │
│  lib/app/di/network/dio_provider.dart                      │
│  lib/app/di/router/router_provider.dart                    │
│                                                           │
│  EACH FEATURE DI IMPORTS DIRECTLY:                        │
│  ✅ app/di/_providers.lib.dart  → all shared providers     │
│     (authDioProvider, appDatabaseProvider,                 │
│      clinicalHistoryStoreProvider, patientInfoStoreProvider│
│      tokenStoreProvider, credentialStoreProvider,          │
│      tokenVerifierProvider, passwordHasherProvider,        │
│      connectivityCheckerProvider, internetServiceProvider, │
│      environmentProvider, goRouterProvider)                │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼

┌──────────────────────────────────────────┐
│            features/auth/di/              │
│  lib/features/auth/di/auth_provider.dart  │
│                                           │
│  IMPORTS DIRECTLY:                        │
│  ✅ app/di/_providers.lib.dart            │
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

Both are built by the same internal factory in `app/di/network/dio_provider.dart` and receive `ConnectionProfile.standard` + `CertificatePinner`. The interceptor is added only to `httpServiceProvider`.

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
     │  AuthRepositoryImpl implements IAuthRepository  ← the implementation lives in infra
     ▼
infrastructure/repositories/auth_repository_impl.dart
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
  passwordHasher: ref.watch(passwordHasherProvider),
  tokenStore: ref.watch(tokenStoreProvider),
);

// Nor does it call repositories, it only builds them
@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  localDatasource: ref.watch(localAuthDatasourceProvider),
);
```

**Whoever calls the use cases is the presentation.** `di/` only makes them available. That is the key difference between "wiring" and "executing".

#### The direction of the dependencies

```
app/ (composition root) ──▶ everything
  │
  ├──▶ design_system/  ──▶ Flutter
  ├──▶ l10n/           ──▶ Flutter
  ├──▶ features/*/presentation/ ──▶ di/ + design_system/ + l10n/ + shared/
  ├──▶ features/*/di/ ──▶ app/di/ + domain/ + infrastructure/ + core/ + shared/
  ├──▶ features/*/infrastructure/ ──▶ domain/ + core/ + shared/
  ├──▶ features/*/domain/ ──▶ shared/
  ├──▶ core/ ──▶ shared/ (never features/, never app/)
  └──▶ shared/ ──▶ only shared/
```

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
| Repository | `auth_repository_impl.dart` | Uses `guard()` to capture exceptions → `Result<T>` |
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

#### 2. Logging — Removed

`LoggerWrapper`, `ILoggerWrapper`, `loggerProvider`, and the `logger` package have been removed from the project. For temporary debug output, use `debugPrint` directly and remove before PR. No structured logging provider is currently wired.

### Testing Strategy & Structure

The `test/` directory mirrors the application's production code (`lib/`) using a Feature-First Clean Architecture approach. This guarantees that every component has an isolated, predictable testing environment, supplemented by automated behavioral testing and centralized simulation utilities.

- `app/` — Composition root tests: `app_initializer_test.dart`, `di/` (dio provider wiring, keep-alive providers), `router/` (app_route, app_router, auth_guard), `environment/`.

- `bdd/` (Acceptance & High-Level Integration): Centralizes executable behavioral tests driven by the Gherkin specifications defined in the feature's `spec/` folder (`auth_bdd_test.dart`).

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
│   │   └── network
│   │       └── dio_provider_test.dart
│   ├── environment
│   │   └── app_environment_test.dart
│   └── router
│       ├── app_route_test.dart
│       ├── app_router_test.dart
│       └── auth_guard_test.dart
├── architecture
│   └── dependency_rules_test.dart
├── bdd
│   └── auth_bdd_test.dart
├── core
│   ├── database
│   │   ├── app_database_provider_test.dart
│   │   ├── app_database_test.dart
│   │   ├── clinical_history_provider_test.dart
│   │   ├── clinical_history_test.dart
│   │   ├── patient_info_provider_test.dart
│   │   ├── patient_info_test.dart
│   │   └── secure_storage_key_service_test.dart
│   ├── network
│   │   ├── connectivity
│   │   │   ├── connectivity_providers_test.dart
│   │   │   ├── http_reachability_test.dart
│   │   │   ├── internet_service_test.dart
│   │   │   └── native_socket_reachability_test.dart
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
│       │   ├── jwt_wrapper_test.dart
│       │   └── token_providers_test.dart
│       ├── crypto
│       │   ├── bcrypt_wrapper_test.dart
│       │   └── password_hasher_provider_test.dart
│       ├── device
│       │   ├── jailbreak_detection_wrapper_test.dart
│       │   ├── jailbreak_provider_test.dart
│       │   ├── path_provider_provider_test.dart
│       │   └── path_provider_wrapper_test.dart
│       └── storage
│           └── secure_storage_wrapper_test.dart
├── design_system
│   └── components
│       └── loading_indicator_test.dart
├── features
│   └── auth
│       ├── domain
│       │   ├── auth_entity_test.dart
│       │   ├── auth_usecase_test.dart
│       │   ├── clear_session_usecase_test.dart
│       │   ├── handle_401_usecase_test.dart
│       │   ├── restore_session_usecase_test.dart
│       │   └── value_objects
│       │       ├── email_test.dart
│       │       ├── password_hash_test.dart
│       │       └── password_test.dart
│       ├── infrastructure
│       │   ├── auth_datasource_impl_test.dart
│       │   ├── auth_dto_test.dart
│       │   ├── auth_mapper_test.dart
│       │   ├── auth_repository_impl_test.dart
│       │   └── local_auth_datasource_impl_test.dart
│       └── presentation
│           ├── notifiers
│           │   ├── auth_notifier_test.dart
│           │   └── auth_state_test.dart
│           ├── screens
│           │   ├── clinical_history_placeholder_screen_golden_test.dart
│           │   ├── login_screen_golden_test.dart
│           │   └── login_screen_test.dart
│           └── widgets
│               └── auth_widget_test.dart
├── flutter_test_config.dart       ← loads Roboto font for golden tests
├── helpers
│   └── mocks.dart
├── l10n
│   └── app_localizations_test.dart
└── shared
    ├── error
    │   ├── error_localizer_test.dart
    │   ├── result_guard_test.dart
    │   └── result_test.dart
    ├── exceptions
    │   ├── exceptions_import_test.dart
    │   └── exceptions_test.dart
    ├── functions
    │   └── offline_first_repository_test.dart
    └── models
        ├── clinical_history
        │   └── clinical_history_model_test.dart
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

class Success<T> extends Result<T> {
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
| **UseCase** | Business Orchestrator | Passes the `Result` through unchanged. **Zero error-handling logic.** |
| **Notifier** | Presentation State | **The Consumer.** Calls `.fold()` to transform the `Result` into UI States. **No try/catch.** |

#### 3. How to Use It (Step-by-Step) with examples:

##### Step 1: Catching and Creating the `Result` (Repository Layer)
The Repository implementation is the **only** place in the entire application where exceptions are caught. We use `guard()` to safely execute the datasource. If the datasource throws an exception, `guard` automatically maps it to a domain `Failure`. For instance:

```dart
lib/features/auth/infrastructure/repositories/auth_repository_impl.dart

@override
Future<Result<LoginResponseEntity>> login({
  required Email email,
  required PasswordHash passwordHash,
}) {
  return guard(() => _remoteDatasource.login(email: email, passwordHash: passwordHash));
}
```

Behind the scenes, `guard()` performs this automatic mapping:

- `ApiException` -> `Failure(ApiError.technical(...))`
- `NoConnectionException` -> `Failure(NetworkError.technical())`
- `ServerUnreachableException` -> `Failure(ServerUnreachableError.technical())`
- `UnexpectedResponseException` -> `Failure(UnexpectedError.technical(...))`
- `DeviceSecurityException` -> `Failure(DeviceSecurityError(...))`
- `AppTimeoutException` / `TimeoutException` -> `Failure(NetworkError.technical())`
- `Error` / `Exception` -> `Failure(UnexpectedError.technical(...))` (Safety net)

##### Step 2: Consuming the `Result` to Update UI (Notifier Layer)

In your Riverpod Notifiers, you consume the result using `.fold()`. `fold` requires two named callbacks: `onSuccess` (data) and `onFailure` (AppError).

```dart
lib/features/auth/presentation/notifiers/auth_notifier.dart

Future<void> login(String email, String password, {bool rememberMe = false}) async {
  state = const AuthState.loading();

  final result = await ref.read(loginUseCaseProvider).call(
    email: email,
    password: password,
    rememberMe: rememberMe,
  );

  await result.fold<Future<void>>(
    onSuccess: (data) async {
      state = AuthState.loaded(
        patient: data.patient,
        token: data.token,
        clinicalHistory: data.clinicalHistory,
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

`localizeError()` lives in `lib/shared/error/error_localizer.dart`:

```dart
String localizeError(AppError error, AppLocalizations l10n) => switch (error) {
  NetworkError() => l10n.errorNetwork,
  ApiError() => l10n.errorServer,
  ServerUnreachableError() => l10n.errorServer,
  UnexpectedError() => l10n.errorUnknown,
  DeviceSecurityError() => l10n.errorUnknown,
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

This barrel exports `Result`, `Success`, `Failure`, `AppError`, all error subtypes, `guard()`, `RetryResult`, `RetrySuccess`, `RetryFailed`, and `localizeError`.

#### 6. How to Add a New Failure Type (Checklist)
Whenever a new backend or feature requirement introduces a unique exception, follow this strict checklist to add its corresponding `AppError` subtype:

##### 1. Create the exception file in `shared/exceptions/`:

```dart
lib/shared/exceptions/my_custom_exception.dart
part of '_exceptions.lib.dart';

class MyCustomException implements Exception {
  const MyCustomException(this.message);
  final String message;
}
```

##### 2. Register the part inside `shared/exceptions/_exceptions.lib.dart`:

```dart
lib/shared/exceptions/_exceptions.lib.dart
part 'my_custom_exception.dart';
```

##### 3. Update the Guard Mapper: Add the matching `on MyCustomException catch` clause inside `guard()` located in `result_guard.dart` to ensure automatic mapping.

##### 4. (If it reaches the UI) Add a case in `localizeError()` in `shared/error/error_localizer.dart`.

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

Some UseCases need to chain multiple `Result`-returning operations conditionally — for example, restore a session from local storage, then check token expiry, then optionally refresh. The rule says "UseCase passes Result through unchanged" and "fold lives in Presentation", but the UseCase still needs to inspect intermediate `Result` values to decide what to do next.

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
...
```

Dart 3 sealed classes with `is` checks (or `case` patterns) give you exhaustiveness and type safety. Always check the `Failure` branch first to propagate the error, then access the data.

This pattern keeps the architectural contract intact:
- `guard` creates the `Result` (in Repository/Infrastructure)
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
await _credentialStore.deleteAll();
return const Success(null);
// Refresh failed, session cleared — "nothing to restore"
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
| Refresh failed (expired token) | `Success(null)` (session cleared) | `if (data == null) return;` | Login screen, **no error** |

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

The two Dio providers are built in `lib/app/di/network/dio_provider.dart`:
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

  AuthRemoteDatasourceImpl({required IDioWrapper dio}) : _dio = dio;

  @override
  Future<LoginResponseDto> login({...}) async {
    final response = await _dio.post(
      AppUries().login,
      sla: EndpointSla.login,
      body: {...},
    );
    return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
```

##### Step 2: Wire the provider

```dart
lib/features/auth/di/auth_provider.dart
@riverpod
IAuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasourceImpl(dio: ref.watch(authDioProvider));
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
| **Plain `Provider` / `NotifierProvider`** | `core/` (defined) + `app/di/` (barrel) | Shared singletons (dio, token, goRouter, sembast). |

Example of the code-gen provider (functional):

```dart
// lib/features/auth/di/auth_provider.dart
part 'auth_provider.g.dart';

@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  localDatasource: ref.watch(localAuthDatasourceProvider),
);
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
    final result = await ref.read(loginUseCaseProvider).call(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    await result.fold<Future<void>>(
      onSuccess: (data) async {
        state = AuthState.loaded(
          patient: data.patient,
          token: data.token,
          clinicalHistory: data.clinicalHistory,
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
@riverpod
IAuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(
      remoteDatasource: ref.watch(authRemoteDatasourceProvider),
      localDatasource: ref.watch(localAuthDatasourceProvider),
    );
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
    @Default(null) List<ClinicalHistoryEntity>? clinicalHistory,
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

- ✅ Feature code accesses global providers by name (e.g. `ref.watch(authDioProvider)`), imported from the `app/di/_providers.lib.dart` barrel or the `core/` source file.
- ✅ Use `@riverpod` annotation for functional providers and `@Riverpod` for Notifiers.
- ✅ Run `dart run build_runner build --delete-conflicting-outputs` after adding/changing annotated providers.
- 🚫 Never import provider files directly from another feature. Import from the `app/di/_providers.lib.dart` barrel or `core/` barrels.
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
| **Value Object** | `features/*/domain/value_objects/` | Validated value objects (`Email`, `Password`, `PasswordHash`) — `@freezed`. |
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
    required String type,
    required String key,
  }) = _TokenEntity;
}
```

##### Mapper (infrastructure)

```dart
// lib/features/auth/infrastructure/mappers/auth_mapper.dart
class AuthMapper {
  static TokenEntity tokenFromDto(TokenDto dto) => TokenEntity(
    type: dto.type,
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
- ✅ Mappers use constructors named (e.g. `TokenEntity(type: dto.type, key: dto.key)`), NEVER `Entity.fromJson`.
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
| `shared/interfaces/` | `abstract interface class` | `ITokenStore`, `IConnectivityChecker`, `IAuthenticationObserver`, `ICredentialStore`, `ITokenVerifier`, `IPasswordHasher`, `IAppDatabase` — business contracts that any layer can implement |
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
- ✅ Mappers use constructors named (e.g. `TokenEntity(type: dto.type, key: dto.key)`), NEVER `Entity.fromJson`.
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
| `AppRoute` | Enum of route paths/names in `app/router/app_route.dart`. |
| `AuthGuard` | `redirect()` logic in `app/router/guards/auth_guard.dart` (login vs clinical-history). |
| `authenticationObserverProvider` | `ChangeNotifier` (`AuthObserver`) that mirrors auth state and notifies GoRouter when auth state changes. |

```dart
// lib/app/di/router/router_provider.dart
final goRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(authenticationObserverProvider);
  const guard = AuthGuard();
  return GoRouter(
    initialLocation: '/',
    refreshListenable: observer as Listenable,
    redirect: (context, state) => guard.redirect(
      location: state.matchedLocation,
      isAuthenticated: observer.isAuthenticated,
    ),
    routes: appRoutes(),
  );
});
```

```dart
// lib/app/router/app_route.dart
enum AppRoute {
  login(path: '/', name: 'login'),
  clinicalHistory(path: '/clinical-history', name: 'clinical-history');
  ...
}
```

```dart
// lib/app/router/app_router.dart
List<RouteBase> appRoutes() => [
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.clinicalHistory.path,
        name: AppRoute.clinicalHistory.name,
        builder: (_, _) => const ClinicalHistoryPlaceholderScreen(),
      ),
    ];
```

#### 3. How to Use It (Step-by-Step)

##### Step 1: Register a new route (in `app/router/app_route.dart` + `app/router/app_router.dart`)

Add a value to the `AppRoute` enum, then a `GoRoute` inside `appRoutes()`.

##### Step 2: Navigate from anywhere

Navigation is mostly **reactive**: `authProvider` changes → `AuthObserver` notifies → `AuthGuard` redirects. For imperative navigation from a notifier or widget, use the Riverpod provider:

```dart
// From any notifier or widget — via Riverpod, never import go_router directly
ref.read(goRouterProvider).go(AppRoute.clinicalHistory.path);
ref.read(goRouterProvider).push('/some-route');
ref.read(goRouterProvider).pop();
```

#### 4. Developer Policies

- 🚫 **Never import `go_router` directly** in feature code. Use `ref.read(goRouterProvider).xxx()`.
- 🚫 **Never instantiate `GoRouter` directly** in features. Use `goRouterProvider` in `app/di/router/router_provider.dart`.
- ✅ Define routes in `app/router/app_route.dart` (enum) + `app/router/app_router.dart` (`appRoutes()`).

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

// Clear all data (on logout or reset)
await ref.read(appDatabaseProvider).resetDatabase();
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

Sembast is also used internally by `ClinicalHistoryStore` and `PatientInfoStore` for offline-first storage of clinical data (`clinicalHistoryStoreProvider`, `patientInfoStoreProvider` in `core/database/tables/`).

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
  final env = AppEnvironment.current;
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
lib/core/database/database_encrypt.dart — internal implementation detail
getEncryptSembastCodec(password:) returns SembastCodec with AES-256-CBC
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

Wrapped in `jailbreak_detection_wrapper.dart` (`IJailbreakDetectionWrapper` / `JailbreakDetectionWrapper`) and exposed via `flutterJailbreakDetectionProvider` (`core/services/device/jailbreak_provider.dart`). Called at startup in `AppInitializer.checkJailbreak()` for Android/iOS only; on a jailbroken device it throws `DeviceSecurityException`, which maps to `DeviceSecurityError` via `guard()`.

#### 3. Developer Policies

- 🚫 **Never access `flutter_jailbreak_detection_plus` directly from features.** Use `flutterJailbreakDetectionProvider`.
- ✅ The check runs only on Android/iOS (short-circuit on web/desktop).

---

### fl_chart — Charts & Graphs

`fl_chart` was evaluated for lab-result line charts but is **currently not a dependency** of the project (not present in `pubspec.yaml`). If added later, use it directly in presentation layer widgets only — never in domain/notifier layers.

---

### logger — Structured Logging

#### 1. Logger — Removed

`LoggerWrapper`, `ILoggerWrapper`, `loggerProvider`, and the `logger` package have been removed from the project. Use `debugPrint` directly for temporary debug output. Remove all `debugPrint` calls before submitting a pull request.

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

### riverpod_lint — Riverpod Linting

A `custom_lint` plugin that adds Riverpod-specific lint rules to `flutter analyze`. Catches common mistakes like:
- Using `ref.read` where `ref.watch` is required.
- Improper notifier method signatures.

Configured in `analysis_options.yaml`.

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
test/bdd/auth_bdd_test.dart
import 'package:gherkart/gherkart.dart';

void main() {
  _testFunction(); // standalone top-level call
}

Future<void> _testFunction() async {
  final feature = File('lib/features/auth/spec/bdd.feature');
  final parser = GherkartParser(feature);
  final document = await parser.parse();

  for (final scenario in document.scenarios) {
    testWidgets(scenario.name, (tester) async {
      for (final step in scenario.steps) {
        await step.keyword.match(
          onGiven: () async { /* arrange */ },
          onWhen: () async { /* act */ },
          onThen: () async { /* assert */ },
        );
      }
    });
  }
}
```

#### 3. Developer Policies

- ✅ Each BDD test file must use a top-level `_testFunction()` — never embed scenarios inside `main()`.
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
| **go_router** | Declarative routing with redirect guards | `goRouterProvider` in `app/di/router/router_provider.dart`; `ref.read(goRouterProvider).go/push/pop(...)` from features | `lib/app/router/` (routes, guard, AppRoute), `lib/app/di/router/` (provider) |
| **sembast** | Lightweight NoSQL document DB with AES-256 encryption | `ref.read(appDatabaseProvider).database` / `.resetDatabase()` | `core/database/app_database.dart` (encrypted sembast) |
| **flutter_secure_storage** | Platform-native secure keystore | `ref.read(tokenStoreProvider).save/read/delete()` for tokens; `DatabaseKeyService` (internal) for DB encryption key | `secure_token_store.dart` (auth tokens), `secure_credential_store.dart` (remember-me), `secure_storage_wrapper.dart` (DB encryption key) |
| **path_provider** | Platform temp & documents directories | `await ref.read(pathProviderProvider).getTemporaryDirectory()` or `.getApplicationDocumentsDirectory()` | Temp file storage for sharing, caching |
| **internet_connection_checker_plus** | Internet access detection | Wrapped by `InternetConnectionCheckerWrapper`; `InternetService.isConnected()` | Only inside `core/network/connectivity/` |
| **encrypt** | AES-256-CBC encryption | Used by `database_encrypt.dart` to create `SembastCodec` for transparent encryption | Only inside `core/database/` (internal to `AppDatabase`) |
| **flutter_jailbreak_detection_plus** | Jailbreak / root detection | `AppInitializer.checkJailbreak()` via `flutterJailbreakDetectionProvider` | `core/services/device/jailbreak_detection_wrapper.dart`, `app/app_initializer.dart` |
| **dart_jsonwebtoken** | JWT encode/decode/verify | `JwtWrapper` (`IJwtWrapper`) + `JwtTokenExpiryChecker` (`ITokenVerifier`) | `core/services/auth/` |
| **bcrypt** | Password hashing | `BcryptWrapper` (`IPasswordHasher`) via `passwordHasherProvider` | `core/services/crypto/` |

### Dev Dependencies

| Package | Description | How to Use | Where It's Used |
| :--- | :--- | :--- | :--- |
| **build_runner** | Code generation runner | `dart run build_runner build --delete-conflicting-outputs` | Regenerates `.g.dart` / `.freezed.dart` files |
| **freezed** | Code-gen for immutable classes/unions | `@freezed` annotations | All entities, DTOs, states, value objects |
| **json_serializable** | Code-gen for JSON | `fromJson`/`toJson` on DTOs | DTOs in `infrastructure/dtos/` |
| **riverpod_generator** | Code-gen for Riverpod | `@riverpod` / `@Riverpod` annotations | All `features/*/di/` and notifiers |
| **riverpod_lint** | Riverpod-specific lint rules | Added to `analysis_options.yaml` (custom_lint) | Enforces correct Riverpod usage at analyze time |
| **flutter_lints** | Official Flutter lint rules | Added to `analysis_options.yaml` | Enforces code style & best practices |
| **mocktail** | Mock interfaces for unit tests | `class MockRepo extends Mock implements IRepo {}` + `when/verify` | All unit tests under `test/features/*/`, `test/core/*/`, `test/shared/*/` |
| **gherkart** | Parse and run Gherkin `.feature` files | `GherkartParser(file).parse()` → iterate scenarios → `testWidgets` per scenario | BDD tests under `test/bdd/*_bdd_test.dart` |

---

## Interceptor

There is a single Dio infrastructure, but **two providers**:

- `authDioProvider` — a `DioWrapper` **without** the auth interceptor. Used by `AuthRemoteDatasource` for login/refresh (no token exists yet, no 401 retry needed).
- `httpServiceProvider` — a `DioWrapper` **with** the auth interceptor (401 retry + force logout). Used by every feature that makes authenticated HTTP calls.

Both are built by the same internal factory in `lib/app/di/network/dio_provider.dart`.

The `AuthInterceptor` is added once to `httpServiceProvider` and from then on intercepts all authenticated HTTP requests from any feature.

```dart
// lib/app/di/network/dio_provider.dart
final httpServiceProvider = Provider<IDioWrapper>((ref) {
  final dio = _createDioWrapper(ref);
  AuthInterceptorImpl(
    handle401UseCase: ref.watch(handle401UseCaseProvider),
  ).setupAuthInterceptor(
    dio,
    onForceLogout: () => ref.read(authProvider.notifier).reset(),
  );
  return dio;
});
```

The interceptor implementation (`AuthInterceptorImpl`) implements `IAuthInterceptorProvider` and lives in `lib/app/di/network/auth_interceptor_impl.dart`:

```dart
class AuthInterceptorImpl implements IAuthInterceptorProvider {
  const AuthInterceptorImpl({required this.handle401UseCase});
  final Handle401UseCase handle401UseCase;

  @override
  void setupAuthInterceptor(IDioWrapper dioWrapper, {required VoidCallback onForceLogout}) {
    dioWrapper.addAuthInterceptor(
      () async {
        final result = await handle401UseCase();
        return switch (result) {
          Success(data: final retryResult) => retryResult,
          Failure() => const RetryFailed(),
        };
      },
      onForceLogout: onForceLogout,
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
│   └─ NO → Failure(NetworkError) → RetryFailed (silent, pass through)
│
├─ tokenStore.read()? → token found
│   └─ RefreshTokenUseCase(token)
│       └─ IAuthRepository.refreshToken(token)
│         └─ IAuthRemoteDatasource.refreshToken(token)
│           └─ authDioProvider.post(/refreshtoken) → new token
│           ├─ success → save new token → RetrySuccess(newToken)
│           └─ fails → fallback: re-login with saved credentials
│               └─ if also fails → RetryFailed → onForceLogout
│
└─ Result<RetryResult> unwrapped by interceptor
↓ is Success(RetrySuccess(token)):
internalDio.fetch(original requestOptions with new Authorization header) → retry
↓ success
handler.resolve(response) → the feature receives its data
```

**Key distinction:**

- `Handle401UseCase` uses `IAuthRepository` + `RefreshTokenUseCase` (no custom service) — follows the standard `UseCase → Repository → guard() → Datasource` flow.
- `internalDio` is a separate, bare `Dio` instance created inside `AuthInterceptor`. It is used **only** for retrying the original failed request after obtaining a new token.
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
| Exists | Expired | No internet | Success(data) → preserves session (offline-first). If the user makes a request, DioWrapper throws NoConnectionException |
| Exists | Expired | Internet, refresh succeeds | POST /refresh_token → saves new token → Success(data.copyWith(token: newToken)) → app starts without interruption |
| Exists | Expired | Internet, refresh fails | POST /refresh_token → Failure(failure) → deleteAll() → Success(null) → login screen |
| Exists | Any | restoreSession() fails | Failure(failure) → Notifier shows error and stays at login |

**Explanation of each scenario:**

| Scenario | Rationale |
| :--- | :--- |
| No local session | Nothing saved, nothing to restore. Login screen. |
| Valid token | JWT has not expired. AuthInterceptor handles any 401 at runtime if the server rejects it. |
| Expired token, no internet | Cannot refresh without a network. Preserving the session allows offline use. AuthInterceptor never fires because requests never reach the API. |
| Expired token, internet, refresh succeeds | Refresh endpoint accepts the old token and returns a new one. Seamless experience — the user never sees the login. |
| Expired token, internet, refresh fails | Server rejected the refresh. Session is cleared. On login screen, Handle401UseCase can attempt re-login with saved credentials. |
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

1. **Local** (always): read patient + token + histories from Sembast/SecureStorage
2. **Remote** (only if token expired + internet): POST /refreshtoken

```bash
RestoreSessionUseCase.call()
↓
_connectivityChecker.isConnected()? + _credentialStore.readCredentials()?
├── online && credentials → attempt re-login (remember-me)
│
↓
_repository.restoreSession() → LocalDatasource → returns LoginResponseEntity?
↓
Token expired?
├── No → returns Success(data) ← keeps the local session
│
└── Yes → Has internet?
    ├── No → returns Success(data) ← offline-first, preserves session
    │
    └── Yes → **attempts refresh via API** ← SECOND infrastructure call
        ├── OK → saves new token → returns Success(data with new token)
        └── Fails → clears session → returns Success(null)
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
├── ref.read(loginUseCaseProvider).call(email, password, rememberMe)
│   │
│   LoginUseCase (domain/usecases)
│   ├── Email.create(email) ← value object validation
│   ├── Password.create(password) ← value object validation
│   ├── _passwordHasher.hash(password) ← BcryptWrapper (via IPasswordHasher)
│   ├── _repository.login(email, passwordHash)
│   │   │
│   │   AuthRepositoryImpl (infrastructure/repositories)
│   │   └── guard(() => _remoteDatasource.login(...))
│   │       │
│   │       AuthRemoteDatasourceImpl
│   │       └── _dio.post('/login', sla: EndpointSla.login) → HTTP
│   │       → Result<LoginResponseEntity>
│   │
│   ├── if (rememberMe) _repository.saveSession(data, email, passwordHash)
│   └── _tokenStore.save(data.token.key) ← token persistence in use case
│
└── result.fold<Future<void>>(
  onSuccess: (data) → state = AuthState.loaded(patient, token, clinicalHistory)
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
    ├── _repository.refreshToken(token) ← AuthRepositoryImpl → RemoteDatasource
    ├── on success: _credentialStore.saveToken(newToken.key)
    └── on failure: _credentialStore.deleteAll() → Success(null)
```

---

## Eliminating Thin Service Adapters

### Problem

The auth feature had 5 service files that were all eliminated. Four were one-line delegations — adapters that existed solely to bridge domain interfaces with shared wrapper implementations. The fifth (`dio_token_retry_handler.dart`) had real logic but was later eliminated when `Handle401UseCase` was refactored to use `IAuthRepository` directly, breaking the Riverpod cycle.

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
i_connectivity_checker.dart
i_credential_store.dart
i_token_store.dart
i_token_verifier.dart
i_password_hasher.dart
i_authentication_observer.dart
i_app_database.dart
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

### Eliminated services — `Handle401UseCase` now uses `IAuthRepository` + `RefreshTokenUseCase`

`Handle401UseCase` used to use a service created inline in `AuthInterceptorImpl` to avoid a Riverpod dependency cycle between `authDioProvider` and `authRemoteDatasourceProvider`.

The solution was to create a separate `authDioProvider` (Dio without an auth interceptor) for the auth datasource, breaking the cycle. Now `Handle401UseCase` uses `IAuthRepository` (via `RefreshTokenUseCase`) directly, following the standard `UseCase → Repository → guard() → Datasource` flow.

This eliminated the intermediate services and the inline creation in `AuthInterceptorImpl`. `AuthInterceptorImpl` now receives `Handle401UseCase` by constructor (1 parameter instead of 6).

#### Unified with `Result<T>` — `Handle401UseCase` returns `Result<RetryResult>`

`Handle401UseCase` follows the standard pattern. It returns `Future<Result<RetryResult>>` — unified with all other use cases.

```
Datasource pattern:
Datasource → Repository.guard() → Result<T> → UseCase → Notifier.fold()

Handle401UseCase pattern (current):
AuthInterceptor → Handle401UseCase → IAuthRepository (+ RefreshTokenUseCase) → guard() → IAuthRemoteDatasource → HTTP
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
| `error/` | `AppError`, `Result<T>`, `guard()`, `localizeError()` | Domain |
| `functions/` | Package wrapper mixin (`offline_first_repository.dart`) | Infrastructure |
| *(migrated to design_system/)* | Theme & colors (AppColors, AppTheme) | Presentation |

No folder under `shared/` uses a layer name (`domain/`, `infrastructure/`, `presentation/`). Adding `domain/interfaces/` would break this convention — it would be the only folder organized by layer. `shared/interfaces/` follows the existing pattern: named by type, parallel to `shared/models/`.

### `RestoreSessionUseCase` depends only on `shared/interfaces/`

`RestoreSessionUseCase` uses `ICredentialStore.saveToken()` (from `shared/interfaces/`) after a successful token refresh, keeping the domain layer free of infrastructure imports:

```dart
class RestoreSessionUseCase {
  final ICredentialStore _credentialStore;
  ...
  await _credentialStore.saveToken(tokenData.key);
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
| `shared/exceptions/` | `ApiException`, `NoConnectionException`, `ServerUnreachableException`, `UnexpectedResponseException`, `AppTimeoutException`, `DeviceSecurityException` |
| Its own files | Entities, value objects, repositories, datasources, use cases |

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

All services were eliminated. The logic was moved into use cases (`Handle401UseCase`, `RestoreSessionUseCase`) that use `IAuthRepository` directly, following the standard `UseCase → Repository` flow.

### Test impact

All unit tests and integration tests pass without behavioral changes. The only test modifications were:
- Imports changed from `features/auth/domain/services/` to `shared/exceptions/_exceptions.lib.dart`
- `TokenCredentialStore(mockTokenService)` replaced with `mockTokenService` directly (the mock now implements `ICredentialStore`)
- Integration test fakes (`_FakeTokenStore`, `_FakeExpiredTokenStore`) now implement `ITokenStore` and `ICredentialStore`

---

## Architectural decisions for a new project (lessons learned)

This project was built incrementally and some conventions evolved over time. If starting a new Clean Architecture project from scratch in a large company, here is what would likely change:

### 1. Folder structure: `app/` (composition root) + `core/` + `shared/`

The project completed the migration from a mixed `shared/` folder to a clean separation:

```
lib/
├── app/       ← Composition root (providers barrel, router, guard, app initializer)
├── shared/    ← Pure domain abstractions
│   ├── interfaces/
│   ├── exceptions/
│   ├── error/
│   ├── models/
│   └── functions/ (offline_first_repository)
├── core/      ← Pure infrastructure
│   ├── config/    (AppEnvironment, environmentProvider)
│   ├── database/  (AppDatabase, sembast wrapper, tables, serializers)
│   ├── network/   (dio_wrapper, interceptors, connectivity, timeouts, retry, security)
│   └── services/  (auth, crypto, device, storage)
├── l10n/      ← AppLocalizations (i18n)
└── features/
    └── auth/  ← di/, domain/, infrastructure/, presentation/, spec/
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

class Success<T> extends Result<T> {
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
    final result = await ref.read(loginUseCaseProvider).call(
      email: email, password: password, rememberMe: rememberMe,
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

### 6. Error handling: typed errors with metadata + `.technical()` constructor

**Current:** Each `AppError` subtype carries typed metadata (`statusCode`, `field`, stack trace) plus a `userMessage`. Localization happens at the UI layer via `localizeError()`.

**Pattern:**
- Domain/infrastructure uses `AppError.technical()` constructors (empty `userMessage` placeholder).
- UI layer maps types to localized strings via `localizeError()` from `shared/error/error_localizer.dart`.

```dart
sealed class AppError {
  final String userMessage;
  final String? technicalMessage;
  final StackTrace? stackTrace;
  const AppError(this.userMessage, {this.technicalMessage, this.stackTrace});
  const AppError.technical({this.technicalMessage, this.stackTrace}) : userMessage = '';
}

final class NetworkError extends AppError {
  const NetworkError(super.userMessage, {super.technicalMessage, super.stackTrace});
  const NetworkError.technical({super.technicalMessage, super.stackTrace}) : super.technical();
}

final class ValidationError extends AppError {
  final String? field;
  const ValidationError(super.userMessage, {this.field, super.technicalMessage, super.stackTrace});
  const ValidationError.technical({super.technicalMessage, super.stackTrace, this.field}) : super.technical();
}
```

**Why:** Errors carry typed metadata (statusCode, field name, stack trace) instead of hiding it in a string. All user-facing strings are centralized in l10n/ and mapped via `localizeError()`.

### 7. Service locator only for infrastructure, not for domain

`app/di/_providers.lib.dart` centralizes the shared global providers via barrel exports. Each feature's `di/` imports directly the providers it needs from the `app/di/_providers.lib.dart` barrel or from `core/` barrels. The composition root is `app/`.

### Comparison table

| Decision | This project |
| :--- | :--- |
| Folder separation | `app/` (composition) + `shared/` (domain) + `core/` (infra) |
| Naming | `_wrapper` suffix (descriptive) |
| Result/AppError | Dart 3 sealed class (native) |
| Code generation | `freezed` + `json_serializable` + `riverpod_generator` (scoped) |
| Providers | `@riverpod` code-gen + `@Riverpod` Notifiers |
| Error model | `AppError` (typed fields) + `localizeError()` |
| Service locator | Riverpod providers via `app/di/_providers.lib.dart` barrel |
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
| `Test` | `ubuntu-latest` | `flutter test --coverage --exclude-tags golden` (unit/widget) + Codecov upload |
| `Test Goldens` | `macos-latest` | `flutter test --tags golden` (golden image tests only) |
| `Build iOS` | `macos-latest` | `flutter build ios --no-codesign` |
| `Build Android` | `ubuntu-latest` | `flutter build apk --debug` |

Key design decisions:

- **Runners by real need:** Only `Build iOS` and `Test Goldens` require macOS (Xcode / deterministic golden rendering). Analyze, Test and Build Android run on Linux, cutting macOS usage.
- **Builds decoupled from tests:** `Build iOS` and `Build Android` depend only on `Analyze` (`needs: [analyze]`), not on `Test`. This guarantees that a build/compile regression is never masked by a failing test job.
- **Least privilege:** `permissions: contents: read` on the whole workflow.
- **Concurrency:** `concurrency: ci-${{ github.ref }}` with `cancel-in-progress: true` cancels superseded runs, saving minutes and avoiding races.
- **Pinned Flutter version:** All jobs pin `flutter-version: '3.44.0'`.

### Golden tests

Golden tests are tagged with `@Tags(['golden'])` (declared via `@Tags(['golden']) library;` at the top of each golden test file). They run on macOS in the dedicated `Test Goldens` job because the images are rendered with an embedded font (`test/flutter_test_config.dart` loads `test/assets/Roboto-Regular.ttf` via `FontLoader`), which keeps rendering deterministic on macOS. The main `Test` job excludes them with `--exclude-tags golden`.

### Coverage

- `flutter test --coverage` produces `coverage/lcov.info`.
- `codecov/codecov-action@v5` uploads it to Codecov with `fail_ci_if_error: false` (a Codecov outage must not break the pipeline).
- The repo is **public**, so Codecov uploads are unlimited and GitHub Actions minutes are free.
- `codecov.yml` configures the status checks:
  - `project` — overall coverage vs base, `target: auto`, `threshold: 1%`.
  - `patch` — coverage of the new lines in the PR, `target: auto`, `threshold: 1%`.

### Dependabot

`.github/dependabot.yml` enables weekly automated updates for:
- `pub` (Dart/Flutter dependencies)
- `github-actions` (GitHub Actions versions)

Up to 5 open PRs per ecosystem at a time.

### Branch protection (`develop`)

`develop` is protected and requires all 5 checks to pass before merging (`strict: true`, so PRs must be up to date with `develop`):

`Analyze`, `Test`, `Test Goldens`, `Build iOS`, `Build Android`

No required reviewers are configured (single-account repo — PRs are self-approved after passing the 6 quality gates of the `super-pull-request-reviewer` command).

### Security features

Since the repo is public:
- **Dependabot alerts** (vulnerability alerts) enabled.
- **Dependabot security updates** enabled.
- **Secret scanning** enabled.
- **Secret scanning push protection** enabled.
- The full git history was scanned with `gitleaks` (no real secrets found — only an expired test JWT fixture that was later removed).

### Plugins

`flutter_jailbreak_detection_plus` (maintained fork) is used instead of the unmaintained `flutter_jailbreak_detection` because the original did not declare `namespace`/`compileSdk 34`/JVM 17, breaking Android builds on AGP 8+. A minimal JVM-target fix for the fork remains in `android/build.gradle.kts`.

### Cost summary

| Aspect | Before | After |
|--------|--------|-------|
| macOS jobs | 3 (`Analyze`, `Test`, `Build iOS`) | 2 (`Test Goldens`, `Build iOS`) |
| Cost/min macOS | $0.062 | $0.062 (only where required) |
| Cost/min Linux | — | $0.006 (Analyze, Test, Build Android) |
| Public repo | — | GitHub Actions free, Codecov unlimited |
