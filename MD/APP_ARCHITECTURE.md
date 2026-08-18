### Architecture (clean + feature-first)

```
lib/
├── core/                    ← Pure infrastructure (no domain imports)
│   ├── config/              ← AppEnvironment sealed class + environmentProvider
│   ├── database/            ← AppDatabase (sembast, AES-256-CBC via codec)
│   ├── network/             ← Dio wrapper, providers (authDioProvider/httpServiceProvider + authInterceptorProvider seam), interceptors (auth, retry), connectivity, certificate pinning, timeouts (per-endpoint SLA), retry (exponential backoff + policy), api_endpoints, contracts/ (shared transport DTOs)
│   ├── router/              ← IAppNavigator seam (appNavigatorProvider, fail-fast if not bound by app/)
│   ├── services/            ← Wrappers organized by domain (auth, charts, crypto, device, logging, storage)
│   └── utils/               ← General-purpose utilities
│
├── app/                     ← Application composition root
│   ├── di/                  ← app-level DI seams (dio_overrides.dart, auth_observer_provider.dart), goRouterProvider
│   └── router/              ← GoRouter definitions (`appRoutes({onLogout})`), auth_guard (deep-link `?from=` redirect) — single source of truth for the route graph
│
├── design_system/           ← Theme, colors, reusable UI components
│   ├── components/          ← Reusable UI components (LoadingIndicator, EmptyState, ErrorState, InfoChip, SkeletonList)
│   ├── theme/               ← AppColors, AppTheme (migrated from shared/configs/)
│   └── utils/               ← UI formatters (app_formatters.dart: formatClinicalDate / formatBytes via intl)
│
├── features/<feature>/
│   ├── di/                  ← Feature-specific Riverpod providers (auth_provider) — migrated from presentation/providers/
│   ├── domain/              ← interfaces (i_*.dart), entities, usecases, services, value_objects — no Flutter imports
│   ├── infrastructure/      ← datasource impl, dtos, mapper, repository impl, service impl
│   ├── presentation/        ← Riverpod notifiers (business providers en di/; UI-state providers como remember_me_provider viven aquí), screens, widgets
│   └── spec/                ← SDD specification files
│
├── l10n/                    ← AppLocalizations (i18n wired into MaterialApp.router)
│
└── shared/                  ← Shared domain abstractions, mock data
    ├── error/               ← AppError sealed hierarchy, Result<T>, Failure, guard() — pure Dart (localizeError lives in l10n/, UI layer)
    ├── exceptions/          ← Exception classes (ApiException, NoConnectionException, etc.)
    ├── functions/           ← online_first.dart (online-first: remote first, cache fallback ONLY on connectivity failure; fetchOrFallback owns all boundary guarding and reports DataOrigin remote/cache)
    ├── interfaces/          ← Cross-cutting domain interfaces (IAppNavigator, ICredentialStore, IConnectivityChecker, ITokenStore, ITokenVerifier, IPasswordHasher, IPatientInfoStore, IClinicalHistoryReader/Writer/Store, etc.) — pure Dart, no third-party types. Los ports del Shared Kernel pueden ser refinados por subinterfaces en `core/` (p. ej. `IInternetService implements IConnectivityChecker` añade `isServerReachable`/`onStatusChange`) — no es una violación de "1 contrato = 1 impl" (Rule 19a aplica solo a contratos de feature)
    ├── models/              ← Shared entities barrel (PatientEntity, ClinicalHistoryEntity + sub-entities)
    └── router/              ← AppRoute enum (typed route registry — Shared Kernel, pure Dart)
```

---

### Shared Kernel — `shared/models/`

`lib/shared/models/` is the **domain Shared Kernel** (DDD): pure domain models shared by two or more bounded contexts, owned by NO single feature.

| Model | Consumers |
|---|---|
| `PatientEntity` | `features/auth` (login envelope `LoginResponseEntity.patient`) + `core/database` (`PatientSerializer`) |
| `ClinicalHistoryEntity` + 6 sub-entities | `features/clinical_history` (domain/infrastructure/presentation) + `core/database` (`ClinicalHistorySerializer`) |
| `LabResultEntity` + sub-entities | `features/lab_results` (domain/infrastructure/presentation) + `core/database` (`LabResultsSerializer`) |

**Why they live in `shared/` and not in their owning feature:** `core/database/` persists these models, and `core/` is feature-agnostic (architecture Rule 14: `core/` NO importa `features/`). Moving them back to a feature would force `core/` → `features/` imports and break the dependency direction.

**Criteria for adding a model to the Shared Kernel:**
1. The model is consumed by ≥ 2 bounded contexts (features and/or `core/`).
2. It is 100% Dart puro (no Flutter, no third-party types) — enforced by Rule 2/Rule 10.
3. It does NOT depend on `core/`, `app/`, `l10n/`, or any feature.

**Governance of changes:** a change to a Shared Kernel model impacts ALL its consumers. When modifying one, run the full test suite (unit + goldens + integration) and update every affected serializer/mapper/store. The round-trip guard tests `test/core/database/*_serializer_test.dart` protect consistency across boundaries.

**`AppRoute` — shared navigation contract (`shared/router/app_route.dart`):** typed route registry consumed by `app/` (route table + guard) and features (navigation via `IAppNavigator`) and tests. Pure Dart (no go_router), so it complies with Rule 10. It is NOT a persisted model → no serializer round-trip required, but a move/change touches all consumers and must be done in one commit.

> Feature-private entities (e.g. `LoginResponseEntity`, `TokenEntity`) stay in `features/<name>/domain/entities/`. Only genuinely shared models migrate to the Shared Kernel.

---

### Shared transport contracts (`core/network/contracts/`)

Wire DTOs that cross bounded contexts live in `lib/core/network/contracts/` (barrel `_contracts.lib.dart`, re-exported by `core/network/_network.lib.dart`). This is the shared transport-contract module: DTOs here describe API payloads consumed by more than one feature, so they cannot live in a single feature's `infrastructure/dtos/`.

**Criterion**: cross-feature wire contracts → `core/network/contracts/`; feature-exclusive payloads → `features/<name>/infrastructure/dtos/`.

Currently it holds: the clinical-history wire contract (`ClinicalHistoryDto` + 6 sub-DTOs, `ClinicalHistoryListResponseDto`, `ClinicalHistoryMapper`) and `PatientDto` (shared patient wire shape used by the auth login envelope). Both **auth** (login envelope parsing) and **clinical_history** (GET /user/clinical-history) consume it.

> **Guarda (Rule 29):** el CI falla si un `*.freezed.dart`/`*.g.dart` queda sin su fuente `*.dart` hermana en el mismo directorio. Al mover un contrato a `core/network/contracts/`, borra los generados de la carpeta de origen (p. ej. restos de una migración de DTOs).

### Configuration — via providers (DIP)

`AppUries` (implementing `IEndpointConfig`) reads host/port/https from an injected `AppEnvironment`, exposed through `appUriesProvider` (`core/network/api_endpoints.dart`) bound to `environmentProvider`. Remote datasources receive `IEndpointConfig` by constructor (via feature DI) — no static `AppEnvironment.current` reads outside `core/config/` (architecture Rule 16).

### Session data clearing (logout)

`clearSession()` clears the session-scoped data explicitly (token + credentials + registered session stores: patient info, clinical history). Contract: a feature that caches session-scoped data must register its store's clear in `LocalAuthDatasourceImpl.clearSession()`. App-global/device data survives logout; a total database wipe is only done via `IAppDatabase.resetDatabase()` (core primitive, for account reset / GDPR) — a **full wipe** that deletes the DB file **and** the encryption key. The production consumer is `ResetAccountUseCase` (auth) → `LocalAuthDatasourceImpl.resetAccount()` = `clearSession()` (secure storage: token + credentials) **+** `resetDatabase()` (DB file + key) — no orphaned credentials survive the GDPR wipe.

**Lab results cache is deliberately NOT cleared on logout** (`labResultsStore` is not registered in `clearSession()`): its data is session-scoped but write-through-invalidated on every load/refresh, so a stale read is impossible after re-login; the only full wipe is `resetAccount()`. Documented coupling for auth in `features/lab_results/spec/contracts.md`.

### Features

- `features/auth` — authentication (login, session restore, token refresh). Repository split by role (ISP): `IAuthRepository` (login/refreshToken, remote) implemented by `AuthRemoteRepositoryImpl` + `ILocalAuthRepository` (saveSession/clearSession/restoreSession, local) implemented by `AuthLocalRepositoryImpl` — one class = one contract (Rules 19a/19b).

> **Enforced by CI (`test/architecture/dependency_rules_test.dart`):** Rule 18 (usecases dependen de otros usecases via `IUseCase<Input, Output>`, nunca clases concretas), Rule 19a (1 contrato = 1 impl en `domain/repositories` + `domain/datasources`), Rule 19b (1 clase = 1 contrato en `infrastructure/`), Rule 20 (providers de `core/database/tables/` solo en archivos `*_providers.dart`).
- `features/clinical_history` — clinical history list (remote `GET /user/clinical-history` via `IClinicalHistoryRemoteDatasource` + offline cache via `IClinicalHistoryLocalDatasource`/`clinicalHistoryStoreProvider`, online-first repository with write-through: cache fallback only on a genuine connectivity failure).
- `features/lab_results` — lab results (remote `GET /user/clinical-history/lab-results` via `ILabResultsRemoteDatasource` + offline cache via `ILabResultsLocalDatasource`/`labResultsStoreProvider`, online-first repository; numeric tests render as trend charts through the `ITrendChart` seam (`trendChartProvider`, wraps `package:fl_chart` — never imported in features), non-numeric tests as a flat list; period filter + pull-to-refresh; navigated to imperatively from the clinical_history AppBar via `IAppNavigator`).

### Bounded contexts — auth ↔ clinical_history (documented coupling)

`LocalAuthDatasourceImpl` (contexto **auth**) persiste, limpia y lee la cache de `ClinicalHistoryEntity` (contexto **clinical_history**): el envelope de login (`LoginResponseEntity.clinicalHistory`) transporta la historia clínica y, por online-first, se cachea al loguear — responsabilidad documentada de auth en `features/clinical_history/spec/contracts.md` ("the cache is populated by the auth feature at login").

Es un acoplamiento cross-context **intencional y contenido**: el Shared Kernel (`shared/models/`) existe precisamente para permitirlo sin que `core/` dependa de features (Rule 14) ni features entre sí (Rule 5).

**Criterios para re-evaluar (no implementar hoy):** aparición de un bus de eventos/sesión inter-feature (auth publica "sesión restaurada"; clinical_history suscribe y cachea su propio dato), o que otro bounded context necesite escribir la cache de clinical history.

---

### Dependency direction — one-way DI (no `features → app`)

Feature DI (`features/*/di/`) wires domain interfaces to infrastructure impls and imports the providers it needs **directly from `core/`** (never from `app/`). The `app/` layer is the composition root and binds cross-cutting seams:

| Core provider | App binding |
|---|---|
| `authDioProvider` (no interceptor), `httpServiceProvider` (with auth interceptor), `authInterceptorProvider` (seam, fail-fast default) | `app/di/network/dio_overrides.dart` → `dioOverrides()`, merged in `main.dart` |
| `appNavigatorProvider` (seam, fail-fast default) | `app/di/router/router_overrides.dart` → `routerOverrides()`, merged in `main.dart` |

`httpServiceProvider` applies whatever `IAuthInterceptorProvider` the composition root provides, so `core/network` never imports the auth feature. A feature that navigates imperatively uses `IAppNavigator` (imported from its own `di/`, which re-exports the core seam on-demand) — never via `app/` nor `go_router`. Enforced by architecture Rule 11 (`features/` no importa `app/`).

---

### Result / AppError data flow

All fallible operations return `Result<T>` (Success / Failure) via `guard()`.

```
shared/error/ → guard() in result_guard.dart catches Exception/Error → creates Failure(AppError)
datasource  → raw call, no try/catch
repository  → guard(() => datasource.call())                            ← creates Result
usecase     → passes repository Results through unchanged; wraps shared ports (raw values) with guard() ← still a Result boundary
notifier    → result.fold(onFailure: ..., onSuccess: ...)               ← consumes Result
```

> See **MD/APP_DARTZ.md** for the full pattern, code examples and checklist.

### Local datasource layer

If a feature needs offline persistence, add an `ILocal<Feature>Datasource` (e.g. `ILocalAuthDatasource`) in `domain/datasources/` with its implementation in `infrastructure/datasources/`. The repository combines remote + local:

```
repository → guard(() => remoteDs.method())
              guard(() => localDs.storeSession(data))
              guard(() => localDs.restoreSession())
```

### Domain services

Complex domain logic (e.g., session restoration with token expiry checks) lives directly in use cases under `domain/usecases/`, eliminating the need for separate service interfaces and service implementations:

- `RestoreSessionUseCase` in `domain/usecases/` — reemplaza al servicio de restauracion de sesion
- `Handle401UseCase` in `domain/usecases/` — reemplaza al servicio de retry handler

### ITokenVerifier — interface in shared/interfaces/

The `ITokenVerifier` interface lives in `lib/shared/interfaces/` (not `core/services/auth/`). Its implementation (`JwtTokenExpiryChecker`) remains in `core/services/auth/`. Feature code accesses it via `ref.watch(tokenVerifierProvider)` (imported from `core/services/auth/token_providers.dart`).

`ITokenVerifier` is deliberately **expiry-only** (ISP): it exposes a single `isExpired()` and does NOT decode payloads nor verify signatures. Payload decoding is delegated to `IJwtWrapper.decodePayload()` (`core/services/auth/jwt_wrapper.dart`, via `jwtWrapperProvider`), and signature verification is a server-side concern (the app never verifies JWT signatures locally).

Infrastructure files that import `ITokenVerifier` — such as `local_auth_datasource_impl.dart` — import it from `shared/interfaces/_interfaces.lib.dart` (Rule 26: the folder is only imported through its barrel).

### guard() exception mapping

```
ApiException               → Failure(ApiError(technicalMessage: 'HTTP <code>'))
NoConnectionException      → Failure(NetworkError())
ServerUnreachableException → Failure(ServerUnreachableError())
UnexpectedResponseException→ Failure(UnexpectedError(technicalMessage: details))
AppTimeoutException        → Failure(TimeoutError(technicalMessage: message))
TimeoutException (dart)    → Failure(TimeoutError(technicalMessage: message))
DioException (timeout)     → AppTimeoutException (checked before falling through)
Error                      → RETHROWN (fail-fast — programming errors are NOT swallowed)
```

> Exception `details` are developer-facing technical messages: **English only**, never interpolating a raw error object. User-facing strings are produced by `localizeError()` in `lib/l10n/` (UI layer), never from the exception message.
