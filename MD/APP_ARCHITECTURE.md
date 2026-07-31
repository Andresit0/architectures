### Architecture (clean + feature-first)

```
lib/
├── core/                    ← Pure infrastructure (no domain imports)
│   ├── config/              ← AppEnvironment sealed class + environmentProvider
│   ├── database/            ← AppDatabase (sembast, AES-256-CBC via codec)
│   ├── network/             ← Dio wrapper, interceptors (auth, retry), connectivity, certificate pinning, timeouts (per-endpoint SLA), retry (exponential backoff + policy), api_endpoints
│   ├── router/
│   ├── services/            ← Wrappers organized by domain (auth, crypto, device, events, storage)
│   └── utils/               ← General-purpose utilities
│
├── app/                     ← Application composition root
│   ├── di/                  ← `_providers.lib.dart` composition root barrel (imports providers from core/), goRouterProvider
│   └── router/              ← GoRouter definitions (`appRoutes()`), AppRoute enum, auth_guard — single source of truth
│
├── design_system/           ← Theme, colors, reusable UI components
│   ├── components/          ← Reusable UI components
│   └── theme/               ← AppColors, AppTheme (migrated from shared/configs/)
│
├── features/<feature>/
│   ├── di/                  ← Feature-specific Riverpod providers (auth_provider, remember_me_provider) — migrated from presentation/providers/
│   ├── domain/              ← interfaces (i_*.dart), entities, usecases, services, value_objects — no Flutter imports
│   ├── infrastructure/      ← datasource impl, dtos, mapper, repository impl, service impl
│   ├── presentation/        ← Riverpod notifiers (no providers — moved to di/), screens, widgets
│   └── spec/                ← SDD specification files
│
├── l10n/                    ← AppLocalizations (i18n wired into MaterialApp.router)
│
└── shared/                  ← Shared domain abstractions, mock data
    ├── error/               ← AppError sealed hierarchy, Result<T>, Failure, guard(), error_localizer
    ├── exceptions/          ← Exception classes (ApiException, NoConnectionException, etc.)
    ├── functions/           ← offline_first_repository.dart
    ├── interfaces/          ← Cross-cutting domain interfaces (IAppDatabase, ISembastDb, ICredentialStore, IConnectivityChecker, ITokenStore, ITokenVerifier, IAuthenticationObserver, etc.)
    ├── models/              ← Shared entities barrel (PatientEntity, ClinicalHistoryEntity + sub-entities)
    └── pagination/          ← Pagination utilities (PaginatedResult, PaginationParams)
```

---

### Result / AppError data flow

All fallible operations return `Result<T>` (Success / Failure) via `guard()`.

```
shared/error/ → guard() in result_guard.dart catches Exception/Error → creates Failure(AppError)
datasource  → raw call, no try/catch
repository  → guard(() => datasource.call())                            ← creates Result
usecase     → passes Result through unchanged, uses `is Success` / `is Failure` to branch
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

The `ITokenVerifier` interface lives in `lib/shared/interfaces/` (not `core/services/auth/`). Its implementation (`JwtTokenExpiryChecker`) remains in `core/services/auth/`. Feature code accesses it via `ref.watch(tokenVerifierProvider)` (imported from `_providers.lib.dart`).

Infrastructure files that import `ITokenVerifier` — such as `local_auth_datasource_impl.dart` and `session_restoration_service_impl.dart` — import it from `shared/interfaces/_interfaces.lib.dart`.

### guard() exception mapping

```
ApiException               → Failure(ApiError())
NoConnectionException      → Failure(NetworkError())
ServerUnreachableException → Failure(ServerUnreachableError())
UnexpectedResponseException→ Failure(UnexpectedError())
AppTimeoutException        → Failure(NetworkError())
TimeoutException (dart)    → Failure(NetworkError())
DioException (timeout)     → AppTimeoutException (checked before falling through)
Error                      → Failure(UnexpectedError())   ← catches Error + Exception
```
