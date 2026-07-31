# FILE TO LEARN ABOUT ARCHITECTURE SELECTED

## Clean Architecture — Conceptos Base

### ¿Qué es Clean Architecture?

Clean Architecture es un patrón de diseño que organiza el código en **capas concéntricas** donde las capas internas contienen las reglas de negocio (puras, sin dependencias externas) y las capas externas contienen los detalles de infraestructura (frameworks, bases de datos, UI).

```
Capas de Clean Architecture (de adentro hacia afuera):

1. Enterprise Business Rules   → Reglas de negocio globales (entidades, value objects)
2. Application Business Rules  → Reglas de negocio específicas del caso de uso
3. Interface Adapters         → Implementaciones concretas (datasources, repositorios)
4. Frameworks & Drivers       → Flutter, UI, base de datos, Composition Root
```

### La regla de dependencia (Dependency Rule)

**El código fuente de las capas internas NUNCA debe importar código de las capas externas.**

```
Capa interna:  domain/   →  solo importa shared/ (enterprise rules)  ✅
Capa media:    core/     →  importa shared/ pero NUNCA features/      ✅
Capa externa:  shared/providers/ + core/   →  puede importar TODAS las capas            ✅
```

Las dependencias SIEMPRE apuntan hacia adentro:

```
shared/  ←  core/  ←  features/infrastructure/  ←  features/presentation/  ←  shared/providers/ + core/
(más interna)                                                  (más externa)
```

### ¿Qué es Composition Root?

Es el **punto de entrada** de la app donde se construye el grafo de dependencias. En un proyecto Flutter con Riverpod, `shared/providers/` y los barrels de `core/` cumplen el rol de Composition Root porque ahí se declaran los providers que wirean la app.

En cualquier sistema con Inyección de Dependencias, **alguien** debe conocer todas las dependencias para construirlas. Ese alguien es el Composition Root. Es intencionalmente "sucio" — conoce todas las capas para poder unirlas.

### ¿Por qué NO viola Clean Architecture?

Clean Architecture dice: **la dirección de las dependencias** debe ir de afuera hacia adentro. El código fuente de las capas internas no debe mencionar a las capas externas.

```
Capa interna (domain/)  →  NO menciona capas externas  ✅
Capa externa (shared/providers/ + core/)  →  SÍ menciona capas internas  ✅
```

`shared/providers/` + `core/` son las **capas más externas** — pueden mencionar a cualquiera porque no hay nada más afuera que pueda depender de ellas de forma incorrecta.

La regla es: **lo que NO puede pasar** es que `domain/` importe `shared/providers/` o `core/`. Eso sí rompe Clean Architecture. Pero las capas externas importando `domain/` es el flujo natural: lo externo conoce lo interno.

### Definición de los conceptos clave

#### `shared/` — Enterprise Business Rules (Capa más interna)

Contiene las reglas de negocio **compartidas por toda la app**. No depende de Flutter, ni de bases de datos, ni de ningún feature específico.

| Qué va aquí | Ejemplo concreto |
|-------------|-----------------|
| Interfaces abstractas | `ITokenStore`, `IConnectivityChecker`, `IAuthenticationObserver` |
| Tipos de error | `AppError`, `Result<T>`, `guard()` |

| Modelos compartidos | `PatientEntity`, `ClinicalHistoryEntity` |
| Wrappers de paquetes | `offline_first_repository.dart` |

**Regla:** `shared/` NO puede importar `core/`, `features/`, `app/`, ni ningún paquete externo (solo Dart SDK).

#### `core/` — Interface Adapters (Infraestructura compartida)

Implementaciones concretas de servicios que **varios features pueden usar**. Conoce a `shared/` pero NO a `features/`.

| Qué va aquí | Ejemplo concreto |
|-------------|-----------------|
| HTTP client | `DioWrapper`, `IDioWrapper` en `core/network/dio/` |
| Base de datos | `AppDatabase`, `ISembastDb` en `core/database/` |
| Servicios de auth | `SecureTokenStore`, `JwtWrapper` en `core/services/auth/` |
| Conectividad | `InternetService`, `IConnectivityChecker` en `core/network/connectivity/` |
| Seguridad | `CertificatePinner` en `core/network/security/` |
| Almacenamiento | `SecureStorageWrapper` en `core/services/storage/` |

**Regla:** `core/` puede importar `shared/`, pero NUNCA `features/` ni `app/`.

#### `features/` — Application Business Rules + Interface Adapters + UI

Cada feature es un **módulo autónomo** con sus propias 4 subcapas:

| Subcapa | Rol | Importa de |
|---------|-----|-----------|
| `features/*/domain/` | Reglas de negocio del feature (use cases, entidades, interfaces) | Solo `shared/` |
| `features/*/infrastructure/` | Implementaciones de las interfaces del dominio | `domain/`, `core/`, `shared/` |
| `features/*/presentation/` | UI del feature (screens, widgets, notifiers) | `../di/`, `shared/`, `design_system/`, `l10n/` |
| `features/*/di/` | Wiring del feature (providers Riverpod) | `core/`, `shared/` |

**Regla:** Un feature NUNCA importa de otro feature. Cada feature es independiente.

#### `shared/providers/` + `core/` — Composition Root (Capas más externas)

Son las **capas más externas** — pueden importar de todas las demás porque son las encargadas de wirear todo.

| Qué va aquí | Ejemplo concreto |
|-------------|-----------------|
| Providers globales | `CustomProviders` facade en `shared/providers/` |
| Configuración de router | `CpGoRouter.create()` + `CustomConfigs.routes.goRouter` |
| Inicialización | En `main.dart` inline |

**Regla:** `core/` y `shared/providers/` pueden importar cualquier `lib/`. Ninguna capa inferior importa `core/network/dio/` desde features.

Cada feature importa los providers directamente desde sus fuentes. La tabla siguiente muestra de dónde viene cada provider:

```dart
// Los providers se importan directamente desde sus barrels o archivos
// core/database/_database.lib.dart  → appDatabaseProvider, clinicalHistoryStoreProvider, patientInfoStoreProvider
// core/network/dio/dio_provider.dart → authDioProvider
// core/services/_services.lib.dart  → tokenStoreProvider, tokenVerifierProvider, credentialStoreProvider
// core/config/environment_provider.dart → environmentProvider
// features/auth/presentation/notifiers/auth_notifier.dart → authProvider, isAuthenticatedProvider, appNameProvider
```

| Provider | Tipo | Ubicación del provider |
|---|---|---|
| `tokenStoreProvider` | `ITokenStore` | `core/services/auth/token_providers.dart` |
| `authDioProvider` | `IDioWrapper` | `core/network/dio/dio_provider.dart` |
| `appDatabaseProvider` | `IAppDatabase` | `core/database/app_database_provider.dart` |
| `clinicalHistoryStoreProvider` | `IClinicalHistoryStore` | `core/database/tables/clinical_history.dart` |
| `patientInfoStoreProvider` | `IPatientInfoStore` | `core/database/tables/patient_info.dart` |
| `passwordHasherProvider` | `IPasswordHasher` | `core/services/crypto/password_hasher_provider.dart` |
| `connectivityCheckerProvider` | `IConnectivityChecker` | `core/network/connectivity/connectivity_providers.dart` |
| `tokenVerifierProvider` | `ITokenVerifier` | `core/services/auth/token_providers.dart` |
| `credentialStoreProvider` | `ICredentialStore` | `core/services/auth/token_providers.dart` |
| `jwtWrapperProvider` | `IJwtWrapper` | `core/services/auth/token_providers.dart` |
| `environmentProvider` | `AppEnvironment` | `core/config/environment_provider.dart` |
| `internetServiceProvider` | `IInternetService` | `core/network/connectivity/connectivity_providers.dart` |

**Conclusión:** Los providers se importan directamente desde:
- `core/` → Infraestructura (database, network, services)
- `core/config/` → Configuración global
- `features/*/presentation/` → Notifiers del feature

**Ejemplo concreto de por qué `authDioProvider` vive en `core/network/dio/` y no en `features/`:**

```
authProvider          →  features/auth/presentation/notifiers/  ← capa de PRESENTACIÓN
                           ↓
core/                 →  INFRAESTRUCTURA (no puede importar presentación)
                           ↓
core/network/dio/dio_provider.dart  →  INFRAESTRUCTURA DE RED (aporta IDioWrapper sin auth interceptor)
```

`authProvider` es un `Notifier` de Riverpod que vive en `features/auth/presentation/notifiers/` porque maneja estado de UI (`AuthState.initial`, `AuthState.loading`, `AuthState.loaded`, `AuthState.failure`). La presentación es su hogar natural.

El auth state se maneja via `GoRouterListenable` en `shared/providers/go_router_notifier_provider.dart`. No se necesita composition root separado.

#### `design_system/` — Primitivas de UI

Componentes visuales reutilizables sin lógica de negocio.

| Qué va aquí | Ejemplo concreto |
|-------------|-----------------|
| Tema | `AppColors`, `AppTheme` |
| Componentes | `LoadingIndicator` |

**Regla:** Solo importa Flutter. No importa `core/`, `shared/`, ni `features/`.

#### `l10n/` — Internacionalización

Claves de texto traducidas (EN/ES) usadas por toda la app.

Los archivos `.arb` son la fuente de verdad:
- `app_en.arb` — claves en ingles
- `app_es.arb` — claves en espanol

Los archivos `.dart` (`app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_es.dart`) se generan automaticamente con `flutter gen-l10n`.

**Flujo para agregar o modificar texto:**
1. Editar `app_en.arb` y `app_es.arb`
2. Ejecutar `flutter gen-l10n`
3. Usar `AppLocalizations.of(context)!.clave` en las pantallas

**Regla:** Solo importa Flutter. Las pantallas acceden via `AppLocalizations.of(context)!`.

## Clean architecture feature first

This project follows a Feature-First Clean Architecture pattern for medium-to-large apps. Instead of grouping files strictly by their technical layer at the root level, the codebase is highly modularized around business capabilities (Features). This ensures high maintainability, scalability, and clear boundaries for development, testing, and specification-driven development.

### 1. The `features/` Directory

Each feature operates as an autonomous module containing its own lifecycle and architectural layers:

- `domain/` (Core Business Logic): The completely isolated layer that defines the business rules. It contains enterprise Entities, abstract contracts for data sources and repositories, and specific business orchestrators (Use Cases). It remains completely independent of any external library or framework.

- `infrastructure/` (Data & External Integrations): Implements the contracts defined in the Domain layer. It handles raw data fetching via concrete Datasources (REST APIs, Local DBs), maps external data structures into Domain Entities using Mappers, and coordinates data flow through Repository implementations.

- `di/` (Dependency Injection — Wiring): Feature-specific Riverpod providers that wire domain interfaces to infrastructure implementations. This is a **peer** of the other layers, not a subfolder of `presentation/`, because it knows about **all** layers: imports `core/`, `domain/`, and `infrastructure/`, but **never** imports `presentation/`. The dependency direction is `presentation/ → di/ → domain/ + infrastructure/ + core/`.

- `presentation/` (UI & State Management): Manages how the feature is displayed and how users interact with it. It contains Screens (views), atomic Widgets, and State Notifiers (`Notifier` + `State`). The **only** import toward other feature layers is `presentation/notifiers/ → di/` (notifiers consume providers from `di/`). It never contains Riverpod providers — those were migrated to `di/`.

- `spec/` (Specification-Driven Development - SDD): The source of truth for the feature's requirements. It centralizes BDD Gherkin scenarios (`.feature`), functional contracts, API schemas, and task checklists, serving as the blueprint for both automated tests and implementation.

```bash
├── features
│ ├── [feature_name]
│ │ ├── di/              ← Peer layer (WIRING): imports core/ + domain/ + infrastructure/
│ │ │   ├── [feature]_provider.dart     ← @riverpod providers
│ │ │   └── [sub_feature]_provider.dart
│ │ ├── domain/          ← Innermost layer (BUSINESS): 0 imports from outer layers
│ │ │   ├── datasources
│ │ │   │ └── i_[feature]_datasource.dart
│ │ │   ├── entities
│ │ │   │ ├── _entities.lib.dart
│ │ │   │ ├── [entity_name]_entity.dart
│ │ │   │ └── [entity_name]_entity.dart
│ │ │   ├── repositories
│ │ │   │ └── i_[feature]_repository.dart
│ │ │   └── usecases
│ │ │       └── [feature]_usecase.dart
│ │ ├── infrastructure/  ← Outer layer (IMPLEMENTS): imports domain/ only
│ │ │   ├── datasources
│ │ │   │ └── [feature]_datasource_impl.dart
│ │ │   ├── mappers
│ │ │   │ └── [feature]_mapper.dart
│ │ │   └── repositories
│ │ │       └── [feature]_repository_impl.dart
│ │ ├── presentation/    ← Outer layer (UI): imports di/
│ │ │   ├── notifiers
│ │ │   │ ├── [feature]_notifier.dart
│ │ │   │ ├── [feature]_notifier.dart
│ │ │   │ └── [feature]_state.dart
│ │ │   ├── screens
│ │ │   │ └── [feature]_screen.dart
│ │ │   └── widgets
│ │ │       ├── _widgets.lib.dart
│ │ │       └── [widget_name].dart
│ │ └── spec
│ │     ├── bdd.feature
│ │     ├── contracts.md
│ │     ├── domain.md
│ │     ├── spec.md
│ │     ├── tasks.md
│ │     └── tests.md
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
│         ├──▶ core/config/app_environment.dart
│         ├──▶ core/database/app_database_provider.dart
│         ├──▶ core/network/dio/dio_provider.dart
│         ├──▶ core/services/auth/token_providers.dart
│         │
│         ├──▶ ../domain/datasources/i_auth_remote_datasource.dart
│         ├──▶ ../domain/repositories/i_auth_repository.dart
│         ├──▶ ../domain/usecases/login_usecase.dart
│         │
│         └──▶ ../infrastructure/datasources/auth_remote_datasource_impl.dart
│             ../infrastructure/repositories/auth_repository_impl.dart
│
│       (NO importa presentation/ — 0 rutas hacia ../presentation/)
│
└── presentation/
    └── notifiers/
        └── auth_notifier.dart
              │
              └──▶ imports ../../di/auth_provider.dart   ← ÚNICA flecha
```

`auth_provider.dart` en `di/` importa de `core/`, `../domain/` y `../infrastructure/`, pero **nunca** de `../presentation/`. En cambio, `auth_notifier.dart` en `presentation/` importa de `../../di/auth_provider.dart` — la dirección es `presentation → di`, no al revés.

Si `di/` estuviera dentro de `presentation/`, la semántica sería engañosa: sugeriría que el wiring es un "tipo de UI", cuando en realidad es la capa que orquesta todas las demás. Ponerlo como peer de `domain/`, `infrastructure/` y `presentation/` refleja su verdadero rol arquitectónico.

| Capa | Importa de | Lo que contiene |
|------|-----------|----------------|
| `domain/` | nada externo | Entidades, interfaces, use cases |
| `infrastructure/` | solo `domain/` | Implementaciones concretas |
| `di/` | `core/` + `domain/` + `infrastructure/` | Providers que WIRING (nunca UI) |
| `presentation/` | `di/` + widgets/screens | Notifiers, screens, widgets |

Los providers globales se centralizan en `shared/providers/` (CustomProviders). Cada feature importa directamente lo que necesita desde los barrels de `core/`.

### 2. The core/ and shared/ Directories

Cross-cutting concerns, global configurations, and reusable utilities that are shared across multiple features are centralized here to avoid duplication:

- `core/`: Pure infrastructure — service wrappers (`services/`), database (`database/`), network (`network/`). Domain layer must NEVER import from `core/`.

- `core/database/`: Centralized persistence layer configuration (AES-256-CBC encrypted sembast) accessible by any datasource via `appDatabaseProvider`.

- `shared/error/`: AppError sealed hierarchy (ApiError, NetworkError, ServerUnreachableError, ValidationError, UnexpectedError), `Result<T>` with `guard()`, `error_localizer.dart`.

- `core/network/`: Network layer — Dio wrapper (`dio/`), connectivity checkers (`connectivity/`), interceptors (`interceptors/`), per-endpoint timeout configuration (`timeouts/`), retry logic (`retry/`), certificate pinning (`security/`).

- `core/services/`: Shared services organized by domain: `auth/` (token, JWT, credentials), `crypto/` (hashing, encryption, bcrypt), `device/` (path_provider, share_plus, jailbreak), `storage/` (sembast, secure_storage).

- `core/`: Core infrastructure — `database/`, `network/`, `services/`, `config/`.

- `shared/`: Pure domain abstractions — `error/` (AppError, Result, guard, localizeError), `exceptions/` (exception classes), `interfaces/` (cross-cutting interfaces including IAppDatabase, ICredentialStore, IConnectivityChecker, ITokenStore, ITokenVerifier, IAuthenticationObserver), `models/` (shared domain entities), `pagination/` (pagination utilities), `jsons/` (mock data), `functions/` (offline_first_repository).

```bash
├── main.dart
│
├── [eliminado] app/                     ← Composition root eliminado
│
    ├── core/                                ← Pure infrastructure
    │   ├── database/                        ← AppDatabase (sembast, AES-256-CBC)
│   │   ├── app_database.dart
│   │   ├── app_database_provider.dart
│   │   ├── database_encrypt.dart
│   │   ├── secure_storage_key_service.dart
│   │   ├── serializers/
│   │   └── tables/
│   ├── network/
│   │   ├── _network.lib.dart
│   │   ├── api_endpoints.dart
│   │   ├── connectivity/
│   │   ├── dio/                         ← DioWrapper + HttpResponse
│   │   ├── interceptors/                ← AuthInterceptor
│   │   ├── retry/                       ← ExponentialBackoff, RetryPolicy
│   │   ├── security/
│   │   ├── timeouts/                    ← EndpointSla, ConnectionProfile
│   │   └── utils/
│   ├── services/
│   │   ├── _services.lib.dart
│   │   ├── auth/                        ← Token, JWT, credentials
│   │   ├── crypto/                      ← Hashing, encryption, bcrypt
│   │   ├── device/                      ← path_provider, share_plus, jailbreak
│   │   └── storage/                     ← sembast, secure_storage
│
├── design_system/
│   ├── _design.lib.dart
│   ├── components/
│   │   └── loading_indicator.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
│
├── features/
│   └── auth/
│       ├── di/
│       ├── domain/
│       │   ├── datasources/             ← i_auth_datasource, i_credential_local, etc.
│       │   ├── entities/                ← @freezed entities
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
│       │   ├── dio_token_retry_handler.dart
│       │   └── services/
│       └── presentation/
│           ├── notifiers/, screens/, widgets/, spec/
│
├── l10n/
│   ├── app_en.arb
│   ├── app_es.arb
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_es.dart
│
└── shared/                              ← Pure domain abstractions
    ├── exceptions/                      ← ApiException, NoConnectionException, etc.
    ├── functions/                       ← offline_first_repository.dart
    ├── interfaces/                      ← IAppDatabase, IConnectivityChecker, ICredentialStore, ITokenStore, ITokenVerifier, IPasswordHasher, etc.
    ├── models/                          ← PatientEntity, ClinicalHistoryEntity + sub-entities
    ├── pagination/                      ← PaginatedResult, PaginationParams
    └── error/                           ← AppError sealed hierarchy, Result<T>, guard(), error_localizer
```

### 3. Startup — Inline in main.dart

La configuración de plataforma se maneja directamente en `main.dart`.

El `main.dart` actual solo configura orientación y arranca la app. El jailbreak check no se implementó.

```dart
// main.dart
void main({List<Override> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ProviderScope(overrides: overrides, child: const TudesarrolladorApp()));
}
```

Si en el futuro se necesita jailbreak detection, se implementará en el notifier de auth, no en una clase separada.
    throw const DeviceSecurityException();
  }
}
```

| Escenario | `kIsWeb` | `defaultTargetPlatform` | ¿Ejecuta check? |
|-----------|----------|------------------------|-----------------|
| Android/iOS real | `false` | `android` / `iOS` | ✅ Sí |
| macOS desktop (dev, integración) | `false` | `macOS` | ❌ No |
| Web | `true` | — (short-circuit) | ❌ No |
| Tests unitarios (mock) | `false` | `android` (default) | ✅ Sí (mock inyectado) |

**Regla enterprise:** La jailbreak check solo se ejecuta en las plataformas donde tiene sentido (Android/iOS). En el resto se omite sin ruido. El plugin nunca se llama en plataformas no soportadas, eliminando la necesidad de capturar `MissingPluginException`.

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
| `shared/` | **Enterprise Business Rules** | Reglas de negocio globales: `AppError`, `Result<T>`, `guard()`, interfaces compartidas (`ITokenStore`, `IConnectivityChecker`, etc.), modelos compartidos (`PatientEntity`), excepciones (`ApiException`), validadores | Solo `shared/` |
| `features/*/domain/` | **Application Business Rules** | Reglas de negocio específicas del feature: use cases (`LoginUseCase`), entidades (`TokenEntity`), interfaces de repositorio (`IAuthRepository`), value objects (`Email`) | `shared/` |
| `features/*/infrastructure/` | **Interface Adapters** | Implementaciones concretas de las interfaces del dominio: datasources, repositorios, mappers, retry handlers | `features/*/domain/`, `core/`, `shared/` |
| `core/` | **Interface Adapters** (compartidos) | Infraestructura COMPARTIDA entre features: HTTP client (`DioWrapper`), base de datos (`AppDatabase`), servicios (`TokenStore`, `JwtWrapper`, `SecureStorage`), conectividad (`InternetService`) | NUNCA `core/` desde `domain/` |
| `features/*/presentation/` | **Frameworks & Drivers** | UI específica del feature: screens, widgets, notifiers (Riverpod). Contiene el único import hacia `di/` | `features/*/di/`, `shared/`, `design_system/`, `l10n/` |
| `core/` | **Frameworks & Drivers** (Infrastructure) | Capa externa. Contiene `database/`, `network/`, `services/`, `config/`. Providers de infraestructura se importan desde sus barrels directamente. | `shared/`, `core/` |
| `design_system/` | **Frameworks & Drivers** | Primitivas de UI sin lógica de negocio: theme (`AppColors`, `AppTheme`), componentes reutilizables (`LoadingIndicator`) | Solo Flutter |
| `l10n/` | **Frameworks & Drivers** | Internacionalización: `AppLocalizations` con claves EN/ES para labels y mensajes de error | Solo Flutter |

#### ¿Qué puede importar cada capa? (con paths reales del proyecto)

```
┌──────────────────────────────────────────────────────────┐
│                    shared/providers/ + core/              │
│  lib/shared/providers/_providers.lib.dart                  │
│  lib/core/network/dio/dio_provider.dart                    │
│  lib/core/database/_database.lib.dart                      │
│  lib/core/services/_services.lib.dart                      │
│                                                           │
│  CADA FEATURE IMPORTA DIRECTAMENTE:                        │
│  ✅ core/database/_database.lib.dart                       │
│     (appDatabaseProvider, patientInfoStoreProvider,         │
│      clinicalHistoryStoreProvider)                         │
│  ✅ core/network/dio/dio_provider.dart                     │
│     (authDioProvider)                                      │
│  ✅ core/services/_services.lib.dart                       │
│     (tokenStoreProvider, credentialStoreProvider,           │
│      tokenVerifierProvider)                                │
│  ✅ core/config/environment_provider.dart                  │
│     (environmentProvider)                                  │
│  ✅ features/auth/presentation/notifiers/auth_notifier.dart│
│     (authProvider, isAuthenticatedProvider, appNameProvider)│
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼

┌──────────────────────────────────────────┐
│            features/di/                   │
│  lib/features/auth/di/auth_provider.dart  │
│                                           │
│  IMPORTA DIRECTAMENTE:                    │
│  ✅ core/database/_database.lib.dart      │
│  ✅ core/network/dio/dio_provider.dart    │
│  ✅ core/services/_services.lib.dart      │
│  ✅ core/config/environment_provider.dart │
│  ✅ auth/presentation/notifiers/          │
│                                           │
│  ✅ shared/ → auth_provider.dart:10       │
│               import '.../core/services/'  │
│               (tokenStoreProvider)         │
│                                           │
│  ❌ features/X/ (otro feature)            │
│     auth_provider.dart NO importa         │
│     clinical_history/di/ porque:          │
│     → features son módulos autónomos       │
│     → Si auth dependiera de clinical_hist, │
│       no se podría testear auth sin        │
│       montar clinical_history              │
│     → Si se elimina clinical_history,      │
│       auth se rompe                        │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│              core/di/                     │
│  lib/core/services/auth/token_providers   │
│                                           │
│  IMPORTA:                                 │
│  ✅ shared/ → token_providers.dart:2     │
│               import '.../shared/interfaces'│
│               (ITokenStore, ITokenVerifier)│
│                                           │
│  ❌ features/ → VIOLACIÓN GRAVE          │
│     token_providers.dart NUNCA importa    │
│     features/auth/ porque:                │
│     → core/ es INFRAESTRUCTURA            │
│     → Si core importara features/auth/:   │
│       Ejemplo concreto, si existiera:     │
│       import '.../features/auth/...';     │
│       ┌─────────────────────────────────┐ │
│       │  ¿Qué pasa si mañana se         │ │
│       │  elimina el feature auth?       │ │
│       │  core/ queda ROTO porque        │ │
│       │  token_providers.dart importa   │ │
│       │  algo que ya no existe.         │ │
│       │  core/ DEBE ser reutilizable    │ │
│       │  en cualquier app, sin conocer  │ │
│       │  los features de esta app.      │ │
│       └─────────────────────────────────┘ │
│                                           │
│  ✅ core/  → puede importar otro core/   │
│               token_providers.dart:1      │
│               import '.../core/services/' │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│            shared/di/                     │
│  lib/shared/interfaces/i_token_store.dart  │
│                                           │
│  ✅ shared/ → puede importar shared/     │
│               i_token_store.dart:1        │
│               (solo dart, sin imports     │
│                del proyecto)              │
│                                           │
│  ❌ core/     → VIOLACIÓN MORTAL         │
│     shared/ NUNCA importa core/ porque:   │
│     → shared/ son ENTERPRISE BUSINESS     │
│       RULES (capa más interna)            │
│     → core/ es Interface Adapters         │
│       (capa externa)                      │
│     ┌─────────────────────────────────┐   │
│     │ Ejemplo de lo que NO se puede   │   │
│     │ hacer en i_token_store.dart:    │   │
│     │                                 │   │
│     │ import 'package:clean_arch/     │   │
│     │   core/services/storage/        │   │  ← ❌
│     │   secure_storage_wrapper.dart'; │   │
│     │                                 │   │
│     │ Si shared/ importara core/:     │   │
│     │ - No podrías compartir shared/  │   │
│     │   entre apps que usen diferente │   │
│     │   almacenamiento (Hive, SQLite) │   │
│     │ - Cambiar la impl de storage    │   │
│     │   en core/ rompería ITokenStore │   │
│     │   en shared/ — la abstracción   │   │
│     │   dependería de la concreción   │   │
│     └─────────────────────────────────┘   │
│                                           │
│  ❌ features/ → VIOLACIÓN DOBLE           │
│     shared/ NUNCA importa features/       │
│     porque shared/ debe ser                │
│     completamente independiente de        │
│     cualquier feature específico.         │
└──────────────────────────────────────────┘
```

#### Resumen de violaciones con paths reales

| Violación | Path | ¿Qué pasaría? |
|-----------|------|---------------|
| `core/ → features/` | `core/network/dio/` queriendo importar `features/auth/presentation/notifiers/auth_notifier.dart` | El `authDioProvider` en `core/network/dio/` NO necesita importar features porque provee un `DioWrapper` sin auth interceptor. El auth interceptor se configura en `CpDio` (`shared/functions/cp_dio.dart`) sin violar dependencias. `onForceLogout` se asigna via static callback desde `main.dart`. |
| `shared/ → core/` | `shared/interfaces/i_token_store.dart` importando `core/services/storage/secure_storage_wrapper.dart` | `ITokenStore` es una abstracción. Si importara `SecureStorageWrapper` (una implementación concreta en core/), la abstracción dependería de la concreción. Se viola el Dependency Inversion Principle: "abstracciones no deben depender de detalles". |
| `shared/ → features/` | `shared/interfaces/` importando `features/auth/domain/entities/token_entity.dart` | Las Enterprise Business Rules (`shared/`) no pueden conocer las Application Business Rules de un feature específico. `ITokenStore` debe funcionar para CUALQUIER token, no solo los del feature auth. |
| `features/X/ → features/Y/` | `features/auth/di/` importando `features/clinical_history/di/` | Los features son módulos autónomos. Si auth dependiera de clinical_history, no se podría testear auth de forma aislada, ni eliminar clinical_history sin romper auth. |

#### La consecuencia práctica

`authDioProvider` (en `core/network/dio/dio_provider.dart`) provee un `DioWrapper` **sin** auth interceptor — usado exclusivamente por `authRemoteDatasource` para login/refresh, donde no se necesita interceptación. El `DioWrapper` **con** auth interceptor se obtiene via `CustomProviders.dio` (`httpServiceProvider` en `shared/providers/`).

Esta separación evita la necesidad de un composition root separado. Cada capa importa solo lo que necesita respetando las reglas de dependencia de Clean Architecture.

#### La cadena completa: cómo se conectan las capas

```
presentation/ (notifier)
     │  ref.read(loginUseCaseProvider)  ← di/ expone el use case
     ▼
features/*/di/
     │  LoginUseCase(repository: ...)  ← di/ wirea use case + repositorio
     ▼
domain/usecases/login_usecase.dart
     │  _repository.login(email, password)  ← use case llama al REPOSITORIO (interfaz)
     ▼
domain/repositories/i_auth_repository.dart
     ▲  (interfaz — el use case conoce SOLO la interfaz)
     │
     │  AuthRepositoryImpl implements IAuthRepository  ← la implementación está en infra
     ▼
infrastructure/repositories/auth_repository_impl.dart
     │  _remoteDatasource.login(...)  ← implementación llama al DATASOURCE
     ▼
infrastructure/datasources/auth_datasource_impl.dart
     │  _dio.post(...)  ← datasource llama al HTTP (core/)
     ▼
core/network/dio/dio_wrapper.dart
```

**Siempre es así** y no puede ser de otra forma por dos razones:

| Regla | ¿Por qué? |
|-------|-----------|
| La UI **nunca** llama a un datasource directo | Si la UI llamara a `DioWrapper.post()` directamente, cualquier cambio en el backend obligaría a cambiar la UI. El use case la protege. |
| El use case **nunca** llama a un datasource directo | El use case conoce la interfaz del repositorio (`IAuthRepository`), no sabe si la implementación usa REST, GraphQL, SQLite, o un archivo local. |

**La única excepción:**

`features/*/di/` NO llama a nada. Su único trabajo es **wirear**:

```dart
// di/ no llama a use cases, solo los construye
@riverpod
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(
  repository: ref.watch(authRepositoryProvider),
);

// Tampoco llama a repositorios, solo los construye
@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  localDatasource: ref.watch(localAuthDatasourceProvider),
);
```

**Quien llama a los use cases es la presentación.** `di/` solo los pone a disposición. Esa es la diferencia clave entre "wirear" y "ejecutar".

#### La dirección de las dependencias

```
app/ (composition root) ──▶ todo
  │
  ├──▶ design_system/  ──▶ Flutter
  ├──▶ l10n/           ──▶ Flutter
  ├──▶ features/*/presentation/ ──▶ di/ + design_system/ + l10n/ + shared/
  ├──▶ features/*/infrastructure/ ──▶ domain/ + core/ + shared/
  ├──▶ features/*/domain/ ──▶ shared/
  ├──▶ core/ ──▶ shared/ (nunca domain/)
  └──▶ shared/ ──▶ solo shared/
```

#### Lo que NUNCA debe pasar

| Dirección | ¿Por qué está mal? |
|-----------|-------------------|
| `domain/ → core/` | El dominio no debe saber de infraestructura. Rompe la independencia del negocio. |
| `domain/ → presentation/` | El dominio no debe saber de UI. Rompe la testabilidad del dominio. |
| `infrastructure/ → presentation/` | La infraestructura no debe saber de UI. |
| `core/ → features/*/domain/` | Core es infraestructura compartida; no debe depender de reglas de negocio específicas de un feature. |
| `shared/ → features/*/` | Shared es enterprise rules; no debe depender de features específicos. |
| `presentation/ → infrastructure/` | La UI no debe importar implementaciones concretas. Debe pasar por `di/` + interfaces de `domain/`. |

### 5. Patrones Arquitectónicos del Proyecto

#### 1. Synchronous Simple (Result\<T\>) — ✅ El patrón principal

```bash
Presentation            Domain                Infrastructure          Externo
────────────            ──────                ──────────────          ───────
                  UseCase → IRepository → DatasourceImpl → HTTP/DB
                      ↕                         ↕
Notifier ←────── Result<T> (Success/Failure)  guard() → AppError
                      ↕
Widget ←─────── AuthState.loaded/failure
                      ↕
Navegación (GoRouter via AuthObserver)
```

| Quién | Archivo representativo | Rol |
|-------|----------------------|-----|
| Notifier | `auth_notifier.dart` | Llama al use case, hace `fold()` sobre `Result<T>` |
| UseCase | `login_usecase.dart` | Orquesta negocio, retorna `Result<T>` |
| Repository | `auth_repository_impl.dart` | Usa `guard()` para capturar excepciones → `Result<T>` |
| Datasource | `auth_datasource_impl.dart` | Llama a `DioWrapper`, deja que las excepciones fluyan |
| Result | `result.dart` | Sealed class `Success<T>` / `Failure<T>` (Either monad) |
| guard | `result_guard.dart` | Captura 8 tipos de excepción → `AppError` tipado |

**¿Válido para empresa grande?** Sí, por estas razones:

| Razón | Explicación |
|-------|-------------|
| **Compile-time safety** | El tipo `Result<T>` fuerza al compilador a recordar que la operación puede fallar. No hay surprises en runtime. |
| **Sealed class exhaustiva** | Dart 3 `switch` obliga a cubrir todos los subtipos de `AppError`. Si agregas un nuevo error, el compilador te dice dónde falta el `case`. |
| **Testabilidad** | `guard()` se puede mockear fácilmente. Cada capa se testea aislada. |
| **Offline-first integrado** | `fetchOrFallback()` extiende el patrón sin romperlo. |

**Conclusión enterprise:** Este patrón es exactamente lo que una empresa grande esperaría ver. No cambiar nada.

#### 2. Logging — Removed

`LoggerWrapper`, `ILoggerWrapper`, `loggerProvider`, and the `logger` package have been removed from the project. For temporary debug output, use `debugPrint` directly and remove before PR. No structured logging provider is currently wired.


### Testing Strategy & Structure

The `test/ `directory mirrors the application's production code (`lib/`) using a Feature-First Clean Architecture approach. This guarantees that every component has an isolated, predictable testing environment, supplemented by automated behavioral testing and centralized simulation utilities.

- `bdd/` (Acceptance & High-Level Integration): Centralizes executable behavioral tests driven by the Gherkin specifications defined in the feature's spec/ folder. They validate complete end-to-end user flows and multi-layered reactive state updates.

- `features/` (Layer-Isolated Testing): Verifies the implementation details of each decoupled business capability across three distinct scopes: domain, infrastructure and presentation.

- `shared/` (Cross-Cutting & Service Testing): Validates common application-wide layers. This includes the deterministic handling of global configurations, error-propagation pipelines, routing interceptors, and critical third-party defensive wrappers (e.g., database, secure storage, and chart processing extensions).

- `mocks/` (Centralized Test Utilities): Centralizes global, high-frequency reusable test doubles to prevent boilerplate redundancy across the testing suites. This ensures predictable framework stubs without mounting full component trees or hitting volatile operational systems:

| Centralized Mock | Core Testing Purpose |
| :--- | :--- |
| `path_provider.dart` | Mocks cross-platform underlying disk paths to test local persistence, caching, and document download operations. |

```bash
.
├── bdd
│ └── [feature_name]_bdd_test.dart
├── features
│ ├── [feature_name]
│ │ ├── domain
│ │ │ └── [feature_name]_usecase_test.dart
│ │ ├── infrastructure
│ │ │ ├── [feature_name]_datasource_test.dart
│ │ │ ├── [feature_name]_mapper_test.dart
│ │ │ └── [feature_name]_repository_test.dart
│ │ └── presentation
│ │ ├── [feature_name]_state_test.dart
│ │ ├── notifiers
│ │ │ └── [feature_name]_notifier_test.dart
│ │ ├── providers
│ │ │ └── [feature_name]_provider_test.dart
│ │ ├── screens
│ │ │ └── [feature_name]_screen_test.dart
│ │ └── widgets
│ │ └── [widget_name]_test.dart
├── mocks
│ └── path_provider.dart
├── core
│ ├── configs
│ │ ├── uries_test.dart
│ │ └── vars_test.dart
│ ├── database
│ │ └── app_database_test.dart
│ ├── error
│ │ └── result_guard_test.dart
│ ├── network
│ │ ├── connectivity
│ │ │ └── internet_service_test.dart
│ │ ├── dio
│ │ │ └── diowrapper_test.dart
│ │ ├── interceptors
│ │ │ └── [feature_name]_interceptor_test.dart
│ │ └── security
│ │ └── certificate_pinner_test.dart
│ └── services
│ ├── auth
│ │ └── token_service_test.dart
│ ├── crypto
│ │ └── encrypter_test.dart
│ ├── device
│ │ ├── path_provider_test.dart
│ │ └── share_plus_test.dart
│ └── storage
│ ├── secure_storage_test.dart

├── design_system
│ └── components
│ └── loading_indicator_test.dart
└── shared
├── models
│ ├── patient_model_test.dart
│ └── clinical_history_model_test.dart
└── pagination
    └── pagination_test.dart
```

## Dependencies used

### Result<T> — Functional Error Handling Pattern

Now, we go to undertand why we use the Functional Programming paradigm for error handling, how the `Result<T>` package is integrated into our **Clean Architecture**, and how you must implement it in your day-to-day development.

#### 1. Why `Result<T>`? (The Problem & The Solution)

In standard Dart, errors are handled using `try-catch` blocks and throwing `Exceptions`. This introduces two major problems in large codebases:
1. **Unpredictability:** A function's signature (e.g., `Future<[EntityName]Entity> login()`) hides the fact that it can crash. You don't know it throws an exception unless you read its source code or wait for a runtime crash.
2. **Layer Pollution:** `try-catch` blocks end up duplicated everywhere (Datasource, Repository, UseCase, Notifier), breaking Clean Architecture boundaries.

##### The Solution: `Result<T>`
We use `Result<T>` to enforce **Type-Safe Error Handling** via the `Result` type.
An `Result` represents a value that can take one of two possible types:
* **`Failure (L)`**: Contains the **Failure** (by convention, the error side).
* **`Success (R)`**: Contains the **Success Data** (by convention, the correct side).

By returning `Future<Result<[EntityName]Entity>>`, we force the compiler to remind us that the operation might fail, completely eliminating unexpected runtime crashes due to unhandled exceptions.

#### 2. Core Rule per Layer (The Call-Chain)

To keep the architecture clean, each layer has a strict single responsibility regarding error propagation. **Never break these boundaries.**

| Layer | Architectural Responsibility | Rule |
| :--- | :--- | :--- |
| **`dio_wrapper.dart`** | Network / Core Clients | Throws typed infrastructure exceptions (`ApiException`, `NoConnectionException`, etc.). |
| **Datasource Impl** | External Data Ingestion | Raw call execution only. **No try/catch.** Let exceptions propagate upward. |
| **Repository Impl** | Boundary Adapter | **The Guard.** Captures exceptions and converts them into an `Result<T>`. |
| **Repository Domain** | Contract Definition | Declares strict `Future<Result<T>>` return types. |
| **UseCase** | Business Orchestrator | Passes the `Result` through unchanged. **Zero error-handling logic.** |
| **Notifier** | Presentation State | **The Consumer.** Calls `.fold()` to transform the `Result` into UI States. **No try/catch.** |

#### 3. How to Use It (Step-by-Step) with examples:

##### Step 1: Catching and Creating the `Result` (Repository Layer)
The Repository implementation is the **only** place in the entire application where exceptions are caught. We use `guard()` to safely execute the datasource. If the datasource throws an exception, `guard` automatically maps it to a domain `Failure`. For instance:

```dart
app/lib/features/auth/infrastructure/repositories/auth_repository_impl.dart

@override
Future<Result<UserEntity>> login({required String email, required String password}) {
return guard(
() => _datasource.login(email: email, password: password),
);
}
```

Behind the scenes, `guard()` performs this automatic mapping:

- `ApiException` -> `Failure(ApiExceptionFailure())`
- `NoConnectionException` -> `Failure(NetworkError())`
- `ServerUnreachableException` -> `Failure(ServerUnreachableError())`
- `catch (e)` -> `Failure(UnexpectedError())` (Safety net)

##### Step 2: Consuming the `Result` to Update UI (Notifier Layer)

In your Riverpod Notifiers, you consume the result using `.fold()`. `fold` requires two functions: one for the failure scenario (`Failure`) and one for the success scenario (`Success`).

- Scenario A: Basic Synchronous State Mutation

```dart
app/lib/features/auth/presentation/notifiers/auth_notifier.dart

Future<void> login(String email, String password) async {
state = const AuthState.loading();

final result = await ref.read(authUseCaseProvider).call(email, password);

state = result.fold(
(failure) => switch (failure) {
ApiError() => AuthState.error(failure.message),
NetworkError() => const AuthState.error('No internet connection'),
ServerUnreachableError() => const AuthState.error('Server is down for maintenance'),
_ => AuthState.error(failure.message),
},
(user) => AuthState.authenticated(user),
);
}
```

- Scenario B: Asynchronous Success Operations: If you need to perform another asynchronous operation (like saving a token to secure storage) after a successful call, explicit types are required for the fold method:

```dart
app/lib/features/auth/presentation/notifiers/auth_notifier.dart
state = await result.fold<Future<void>>(
(failure) async {
state = AuthState.error(failure.message);
},
(user) async {
await ref.read(tokenServiceProvider).saveToken(user.token);
state = AuthState.authenticated(user);
},
);
```

- Scenario C: Localized Errors via `localizeError()`: Notifier passes `AppError` to state. The UI layer maps it to localized strings:

```dart
// Notifier — passes AppError to state
state = result.fold(
  (failure) => AuthState.error(failure),
  (user) => AuthState.authenticated(user),
);

// UI Screen — localizes the error message
ref.listen<AuthState>(authProvider, (_, state) {
  state.maybeWhen(
    error: (error) {
      final msg = localizeError(error, AppLocalizations.of(context)!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    },
    orElse: () {},
  );
});
```

#### 4. Architectural Golden Rule

💡 `guard` creates, `fold` decides.

- `guard` lives in the Infrastructure Layer — it knows about network exceptions and translates them into domain terms.

- `fold` lives in the Presentation Layer — it knows about UI states, loading spinners, and error dialogs.

Neither layer must ever invade the other's territory.

#### 5. Important Developer Policies

🚫 Never Import `Result<T>` Directly
To keep our code unified and easily maintainable, never add `

Instead,

```dart
From app/lib/features/any_feature/presentation/notifiers/
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
```

#### 6. How to Add a New Failure Type (Checklist)
Whenever a new backend or feature requirement introduces a unique exception, follow this strict checklist to add its corresponding `Failure`:

##### 1. Create the exception file in `shared/exceptions/`:

```dart
app/lib/shared/exceptions/my_custom_exception.dart
part of '_exceptions.lib.dart';

class MyCustomException implements Exception {
const MyCustomException(this.message);
final String message;
}
```

##### 2. Register the part inside `shared/exceptions/_exceptions.lib.dart`:

```dart
app/lib/shared/exceptions/_exceptions.lib.dart
part 'my_custom_exception.dart';
```

##### 3. Update the Guard Mapper: Add the matching `on MyCustomException catch` clause inside `guard()` located in `result_guard.dart` to ensure automatic mapping.

#### 7. Execution Architecture Summary
```bash
Notifier.someMethod()
├── state = Loading
├── result = await usecase.call(...) Returns: Result<T>
│ └── repository.someMethod(...)
│ └── guard.guard(
│ () => datasource.someMethod() Raw execution (Can throw exceptions)
│ )
│ ├── Success Context 🟢 ──> Returns: Success(data)
│ └── Exception Catch 🔴 ──> Returns: Failure(MappedFailure)
│
└── state = result.fold(
Failure(failure) ──> Transform into: AuthState.error(failure.message),
Success(data) ──> Transform into: AuthState.success(data),
```

#### 8. What About Composing Results in a UseCase?

Some UseCases need to chain multiple `Result`-returning operations conditionally — for example, restore a session from local storage, then check token expiry, then optionally refresh. The rule says "UseCase passes Result through unchanged" and "fold lives in Presentation", but the UseCase still needs to inspect intermediate `Result` values to decide what to do next.

**❌ Wrong — using `fold` in a UseCase:**

```dart
restore_session_usecase.dart (before fix)
final result = await _repository.restoreSession();
return result.fold(
(failure) => Failure(failure),
(data) async {
if (data == null) return const Success(null);
if (await _tokenExpiryChecker.isExpired(data.token.key)) {
if (await _connectivityChecker.isConnected()) {
return _tryRefresh(data); ← Another fold inside
}
}
return Success(data);
},
);
```

This violates the architecture because `fold` is reserved for Presentation (UI state mapping, `AuthState.error`/`AuthState.loaded`).

**✅ Correct — use `is Success` / `is Failure` instead:**

```dart
restore_session_usecase.dart (after fix)
final result = await _repository.restoreSession();
if (result is Failure) return result; ← propagate Failure unchanged

final data = (result as Success).data;
if (data == null) return const Success(null); ← no session

if (await _tokenExpiryChecker.isExpired(data.token.key)) {
if (await _connectivityChecker.isConnected()) {
return _tryRefresh(data);
}
}
return Success(data);
```

For `_tryRefresh`, which needs to handle both the success and failure of `refreshToken`:

```dart
Future<Result<LoginResponseEntity?>> _tryRefresh(
LoginResponseEntity data,
) async {
final refreshResult = await _repository.refreshToken(token: data.token.key);
if (refreshResult is Success) {
final newToken = (refreshResult as Success).data;
await _credentialStore.saveToken(newToken.key);
return Success(data.copyWith(token: newToken));
}
Failure case: clear session and return null
await _repository.clearSession();
return const Success(null);
}
```

**Why `is Failure` / `is Success` work:**

| Scenario | Check | Extracting data |
| :--- | :--- | :--- |
| `Failure(failure)` | `result is Failure` → true | Access via `(result as Failure).error` |
| `Success(null)` | `result is Success` → true | `(result as Success).data` is `null` — no session |
| `Success(data)` | `result is Success` → true | `(result as Success).data` gives the data |

**The key insight:** Dart 3 sealed classes with `is` checks give you exhaustiveness and type safety. Always check `is Failure` first to propagate the error, then access `(result as Success).data`.

This pattern keeps the architectural contract intact:
- `guard` creates the `Result` (in Repository/Infrastructure)
- `fold` decides the UI outcome (in Notifier/Presentation)
- `is Success` / `is Failure` composes business logic (in UseCase/Domain)

#### 9. Understanding `Success(null)` in `RestoreSessionUseCase`

`Success(null)` is a specific signal in the session restore flow. The return type `Result<LoginResponseEntity?>` has a **nullable** `Success`, enabling three distinct states:

| Value | Meaning |
| :--- | :--- |
| `Failure(failure)` | The operation **failed** (corrupted DB, unexpected error) |
| `Success(null)` | The operation **succeeded** but **there is no session** to restore |
| `Success(LoginResponseEntity(...))` | The operation **succeeded** and **here is the session data** |

##### Where `Success(null)` originates

**a) No local session** (`restore_session_usecase.dart:40`):
```dart
final data = (result as Success).data;
if (data == null) return const Success(null);
The local datasource returned null — user has never logged in
```

**b) Expired token + refresh failed** (`restore_session_usecase.dart:59-60`):
```dart
await _repository.clearSession();
return const Success(null);
Refresh failed, session cleared — "nothing to restore"
```

##### The full traversal to the UI

```
RestoreSessionUseCase.call()
│
├── Success(null) ─────────────────────────────────────────────────┐
│ │
▼ ▼
AuthNotifier.restoreSession() (auth_notifier.dart:45-66)
│
├── result.fold(
│ (failure) → AuthState.failure(failure),   ← Failure: AppError passed to state; UI localizes via localizeError()
│ (data) →
│ if (data == null) return; ← Success(null): NO-OP
│ ^^^^^^^^^^^^^^^^
│ No state change, no goRouter.update()
│ state = AuthState.loaded(...);
│ CustomFunction.goRouter.go('/app'); ← Success(data): go to app
│ )
│
▼
routerProvider watches authProvider: AuthInitial → isAuthenticated=false
│
▼
CpGoRouter.create() inline redirect logic (cp_go_router.dart)
│
├── authenticated == false
├── isLoginRoute == true (initialLocation: '/')
└── return null → "stay where you are"
│
▼
LoginScreen — the user sees the login form, no errors
```

##### The critical line: `if (data == null) return;`

```dart
auth_notifier.dart:57
(data) async {
if (data == null) return; ← Success(null): silent exit
state = AuthState.loaded(...);
CustomFunction.goRouter.go('/app');
},
```

When `data` is `null` (`Success(null)`):

- **`state` remains `AuthState.initial()`** — login screen is already showing
- **`routerProvider` sees `AuthInitial`** — `isAuthenticated=false`, no navigation trigger
- **No error message** — the widget stays in `AuthInitial`, login form is visible
- **No loading state** — the restore already completed, loading indicator is gone

##### `Success(null)` vs `Failure(failure)` at the UI level

| Situation | UseCase returns | Notifier does | User sees |
| :--- | :--- | :--- | :--- |
| No local session | `Success(null)` | `if (data == null) return;` | Login screen, **no error** |
| Corrupted DB | `Failure(DbFailure(...))` | `state = AuthState.failure(failure)` | Login screen, **error message** |
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

In this project, `dio` is wrapped in `dio_wrapper.dart` (`IDioWrapper` / `DioWrapper`) and exposed via `authDioProvider`. The wrapper adds:
- Automatic internet connectivity checks before every request.
- Automatic `Authorization` header injection via `AuthInterceptor`.
- Typed exception mapping (`DioException` → `ApiException`, etc.).
- Support for `GET`, `POST`, `PATCH`, `DELETE`, `PUT`, and multipart file uploads.
- Configurable timeout per request.

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
app/lib/features/encounter/infrastructure/datasources/encounter_datasource_impl.dart
class EncounterDatasourceImpl implements IEncounterDatasource {
final IDioWrapper _dio;

EncounterDatasourceImpl(this._dio);

@override
Future<List<Map<String, dynamic>>> getEncounters() async {
final response = await _dio.get('/api/v1/encounters');
return response as List<Map<String, dynamic>>;
}
}
```

##### Step 2: Wire the provider

```dart
app/lib/features/encounter/di/encounter_providers.dart
// manual Provider
IEncounterDatasource encounterDatasource(Ref ref) =>
EncounterDatasourceImpl(ref.watch(authDioProvider));
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

- 🚫 **Never import `dio` directly** in feature code. Always use `IDioWrapper` via `ref.watch(authDioProvider)`.
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

Then pass it when constructing `DioWrapper` in your datasource's provider:

```dart
final uploadDatasourceProvider = Provider<IUploadDatasource>((ref) {
  final dio = DioWrapper(
    ref.watch(internetServiceProvider),
    null, null, null,
    ConnectionProfile.slowNetwork,
  );
  return UploadDatasourceImpl(dio);
});
```

**Alternative — use `withProfile()`** if per-call switching becomes common (not yet implemented, pattern to follow):

```dart
final response = await _dio
    .withProfile(ConnectionProfile.slowNetwork)
    .post(url, sla: EndpointSla.upload, body: formData);
```

> Add `withProfile()` to `IDioWrapper` when multiple datasources need per-call profile switching.

**`EndpointSla`** — maps logical endpoint categories to timeouts + retry policy:

| Value | Timeout | Retry | When to use |
| :--- | :--- | :--- | :--- |
| `urgent` | 5s | none | Health checks, lightweight queries |
| `standard` | 15s | none | Default CRUD operations |
| `login` | 30s | 2 attempts, retry on timeout | Authentication, refresh token |
| `upload` | 120s | 2 attempts, retry on timeout | File uploads |
| `unknown` | 10s | none | Fallback when no SLA is explicitly declared |

**How a datasource uses it:**

```dart
final httpResponse = await _dio.post(
  AppUries().login,
  sla: EndpointSla.login,   // ← 30s timeout + idempotent retry
  body: {...},
);
```

When `sla` is omitted, `EndpointSla.unknown` (10s timeout, no retry) applies by default.

**`RetryPolicy`** — defines if and how to retry on timeout. `DioWrapper._request()` executes this policy automatically: on timeout, if `sla.retry.retryOnTimeout == true` and `attempt < maxRetries`, it delays by `baseDelay` and retries recursively.

| Policy | `maxRetries` | `retryOnTimeout` |
| :--- | :--- | :--- |
| `standard` | 0 | false |
| `idempotent` | 2 | true |

---

### flutter_riverpod — State Management & DI

#### 1. Why Riverpod? (The Problem & The Solution)

Flutter's built-in `setState` + `InheritedWidget` pattern becomes unmanageable in medium-to-large apps. You end up with widget tree coupling, manual dependency passing, and no way to override dependencies in tests.

Riverpod solves this with:
- **Compile-safe providers** — no runtime errors for missing providers.
- **Manual providers** (`// manual Provider` annotation) — eliminates boilerplate.
- **Dependency override** — every provider can be replaced in `ProviderScope` for testing.
- **Fine-grained reactivity** — only rebuild widgets that depend on changed data.
- **`keepAlive`** — global singletons that never dispose.

#### 2. Integration Into the Architecture

| Provider type | Where | Purpose |
| :--- | :--- | :--- |
| **Functional `// manual Provider`** | `di/` | Wires datasources, repositories, use cases. |
| **`// manual Provider` Notifier** | `presentation/notifiers/` | Manages UI state with async actions. |
| **Global `Provider` / `NotifierProvider`** | `core/` (defined) + `shared/providers/` (facade) | Shared singletons (dio, token, goRouter, sembast). Providers defined in `core/`, exposed via `CustomProviders` facade in `shared/providers/`. |

Global providers are accessible via `CustomProviders` facade:
```dart
// shared/providers/_providers.dart
class CustomProviders {
  static final dio = httpServiceProvider;
  static final token = tokenServiceProvider;
  static final goRouter = goRouterListenableProvider;
  static final sembast = sembastProvider;
}

```

#### 3. How to Use It (Step-by-Step)

##### Step 1: Declare a functional provider (for wiring dependencies)

```dart
app/lib/features/auth/di/auth_provider.dart
// manual Provider
IAuthRepository userRepository(Ref ref) =>
AuthRepositoryImpl(ref.watch(userDatasourceProvider));
```

##### Step 2: Declare a Notifier (for async state management)

```dart
app/lib/features/auth/presentation/notifiers/auth_notifier.dart
// manual Provider
class LoginNotifier extends Notifier<LoginState> {
@override
LoginState build() => const LoginInitial();

Future<void> login(String email, String password) async {
state = const LoginLoading();
final result = await ref.read(loginUseCaseProvider).call(email, password);
if (result is Failure) {
state = LoginFailure(result.error);
} else if (result is Success) {
state = LoginSuccess();
}
}
}
```

##### Step 3: Watch in the UI

```dart
In any Screen's build() — e.g., app/lib/features/auth/presentation/screens/login_screen.dart
final state = ref.watch(loginNotifierProvider);
switch (state) {
  LoginInitial() => ...,
  LoginLoading() => const CircularProgressIndicator(),
  LoginSuccess() => ...,
  LoginFailure(:final message) => Text(message),
};
```

#### 4. `ref.watch` vs `ref.read` vs `ref.listen`

| Method | Use when |
| :--- | :--- |
| `ref.watch(provider)` | Inside `build()` of widget/Notifier or functional provider — **reactivity** (rebuilds on change). |
| `ref.read(provider)` | Inside callbacks, `initState`, Notifier methods — **one-shot** action. |
| `ref.listen(provider, callback)` | Inside `build()` of Notifier — **react without rebuilding** the notifier. |

#### 5. Developer Policies

- ✅ Feature code accesses global providers by their name (e.g. `ref.watch(authDioProvider)`), imported directly from `core/` or `shared/providers/`.
- ✅ Always use `// manual Provider` annotation.
- ✅ No code generation needed — files compile directly.
- 🚫 Never import provider files directly from another feature. Import from `core/` or `shared/providers/` barrels.
- 🚫 Never use `ref.watch` inside callbacks or async methods — use `ref.read`.

---

### Sealed Classes — Immutable Data & Union Types (Manual)

#### 1. Why Sealed Classes? (The Problem & The Solution)

Model classes in Dart require: `==` operator, `hashCode`, `copyWith`, `toString`, union types, and JSON serialization. Dart 3 sealed classes solve this natively without code generation:
- **Value equality** (`==` and `hashCode`) — write by hand or use `equatable`.
- **`copyWith`** — write by hand.
- **Union types** — native Dart 3 `sealed class` with pattern matching via `switch`.
- **JSON serialization** — delegated to dedicated **DTOs** in infrastructure (VGV-standard). Domain entities remain pure (no `fromJson`/`toJson`).

#### 2. Where It's Used

| File type | Location | Purpose |
| :--- | :--- | :--- |
| **DTO (Data Transfer Object)** | `features/*/infrastructure/dtos/` | API JSON contract — `@freezed` with `fromJson`/`toJson`. |
| **Domain Entity** | `features/*/domain/entities/` | Pure business object — `@freezed` ONLY, NO `fromJson`/`toJson`. |
| **Mapper** | `features/*/infrastructure/mappers/` | Converts DTO → Entity via constructors. |
| **State Classes** | `features/*/presentation/notifiers/*_state.dart` | UI state as sealed class hierarchy. |

#### 3. How to Use It

##### DTO (infrastructure — with JSON)

```dart
// lib/features/auth/infrastructure/dtos/user_dto.dart
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String fullname,
    required String token,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}
```

##### Domain Entity (pure — no JSON)

```dart
// lib/features/auth/domain/entities/user_entity.dart
@freezed
abstract class UserEntity with _$UserEntity {
  const UserEntity._();
  const factory UserEntity({
    required String fullname,
    required String token,
  }) = _UserEntity;
}
```

##### Mapper (infrastructure)

```dart
// lib/features/auth/infrastructure/mappers/user_mapper.dart
class UserMapper {
  static UserEntity fromDto(UserDto dto) => UserEntity(
    fullname: dto.fullname,
    token: dto.token,
  );
}
```

##### Presentation State (sealed class)

```dart
app/lib/features/auth/presentation/notifiers/auth_state.dart
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
}
```

Consume with `switch` pattern matching:

```dart
Used in any Screen's build() method that watches the notifier
switch (state) {
  LoginInitial() => ...,
  LoginLoading() => const CircularProgressIndicator(),
  LoginSuccess() => const Text('Success'),
  LoginFailure(:final message) => Text(message),
};
```

#### 4. Developer Policies

- ✅ Write sealed classes by hand.
- ✅ No `part` directives — each file is a standalone library.
- ✅ JSON serialization via DTOs in `infrastructure/dtos/` with `@freezed` code generation.
- ✅ Run `dart run build_runner build` after adding/changing DTOs.

---

### abstract interface class — Pure Contracts (Dart 3)

#### 1. Why `abstract interface class` instead of `abstract class`?

Dart 3 introdujo `abstract interface class` para definir **contratos puros** que nadie puede heredar, solo implementar.

```dart
abstract interface class IConnectivityChecker {
  Future<bool> isConnected();
}

// ✅ Correcto: implementa la interfaz
class InternetService implements IConnectivityChecker { ... }

// ❌ Error de compilación: no se puede extender una interfaz
class MyChecker extends IConnectivityChecker { ... }
```

| Característica | `abstract class` | `abstract interface class` |
|---------------|-----------------|---------------------------|
| Se puede `extends` | ✅ Sí | ❌ No |
| Se puede `implements` | ✅ Sí | ✅ Sí |
| Propósito | Clase base con posible implementación parcial | **Contrato puro** (solo métodos sin cuerpo) |

**¿Dónde se usa cada uno en el proyecto?**

| Ubicación | Usa | Para |
|-----------|-----|------|
| `shared/interfaces/` | `abstract interface class` | `ITokenStore`, `IConnectivityChecker`, `IAuthenticationObserver` — contratos de negocio que cualquier capa puede implementar |
| `core/` | `abstract interface class` | `IInternetService`, `IDioWrapper` — contratos de infraestructura |
| `core/network/connectivity/` | `abstract class` (sin `interface`) | `IInternetConnectionChecker` — por simplicidad (es una abstracción interna con un solo método) |

**Regla enterprise:** Usar `abstract interface class` para TODAS las interfaces nuevas. Reservar `abstract class` solo para casos donde se necesite herencia compartida (raro en este proyecto).

#### 2. Patrón de caché en servicios de infraestructura

En `lib/core/network/connectivity/internet_service.dart` se usa un caché temporal para evitar llamadas de red repetitivas:

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
      return _lastReachableResult!;  // ← cache hit, no llama a la red
    }
    final result = await _strategy.check();  // ← cache miss, llamada real
    _lastReachableCheck = now;
    _lastReachableResult = result;
    return result;
  }
}
```

**¿Por qué es necesario?** Sin caché, si durante un login se llama a `isServerReachable()` 5 veces, se hacen 5 conexiones socket en 2 segundos. Con el caché de 10 segundos, solo la primera llamada hace la conexión real.

**¿Cuándo usar este patrón?**

| Escenario | ¿Usar caché temporal? |
|-----------|----------------------|
| Verificaciones de conectividad repetitivas en corto tiempo | ✅ Sí (como en `InternetService`) |
| Lecturas de datos que cambian lentamente (config, features flags) | ✅ Sí |
| Datos que cambian en cada request (tokens, precios) | ❌ No |

**Regla enterprise:** El caché temporal en servicios de infraestructura es válido cuando:
- La fuente de datos es externa (red, disco, sensor) y costosa de consultar
- El dato no cambia en la ventana de caché
- El caché se invalida automáticamente por tiempo (TTL), no manualmente

---

### JSON Serialization — via Freezed DTOs (VGV-standard)

This project follows the **Very Good Ventures (VGV) Layered Architecture** standard for serialization:
- **Data models (DTOs)** in `infrastructure/dtos/` handle ALL JSON serialization (`fromJson`/`toJson`).
- **Domain entities** in `domain/entities/` are PURE business objects — NO `fromJson`/`toJson`.
- **Mappers** in `infrastructure/mappers/` convert DTO → Entity via constructors named.

#### 0. Why VGV-standard?

**Very Good Ventures (VGV)** es la consultora Flutter que Google contrata para sus proyectos internos. Su arquitectura por capas (Layered Architecture) con DTOs separados de entidades de dominio es el estandar que usan empresas como:

| Empresa | Industria | Por que usa Flutter + VGV architecture |
|---------|-----------|----------------------------------------|
| **Google** | Tecnologia | Socio principal de Flutter. VGV construyo el Flutter News Toolkit y otras herramientas oficiales. |
| **BMW Group** | Automotriz | Unifico las apps BMW y MINI en una sola base de codigo, eliminando divergencias iOS/Android. |
| **Toyota** | Automotriz | VGV envio software de produccion para sistemas de infoentretenimiento en vehiculos (IVI). |
| **Dow Jones / MarketWatch** | Finanzas / Medios | App nueva lanzada en 3 meses. Reduccion de ~50% en costos de desarrollo. |
| **Betterment** | Fintech (inversiones) | Adopto Flutter con VGV, establecio mejores practices, entreno equipos internos. |
| **NASCAR / Trackhouse** | Deportes | Sistemas de engagement para VIPs y sponsors con Flutter. |
| **Blade** | Transporte de lujo | App para clientes entregada en 8 semanas. |
| **Slickdeals** | E-commerce | App nativa reconstruida en Flutter. Duplico frecuencia de releases. |
| **V1 Sports** | Deportes / Fitness | Unifico 6 apps nativas en un solo producto cross-platform. Duplico ingresos. |

**Por que estas empresas eligen esta arquitectura:**

1. **Escalabilidad** — DTOs independientes de las entidades de dominio permiten que el equipo de backend cambie la API sin afectar el modelo de negocio, y viceversa.
2. **Mantenibilidad** — Capas con responsabilidades unicas. Un desarrollador nuevo entiende donde va cada cosa sin adivinar.
3. **Testeabilidad** — Las entidades de dominio se testean sin JSON. Los DTOs se testean independientemente. Los mappers se testean por separado. Cobertura precisa.
4. **Paralelismo** — Equipos diferentes pueden trabajar en API layer (DTOs) y domain layer (entidades) simultaneamente sin conflictos.
5. **Estandar VGV + Google** — No es una decision arbitraria. Es el patron que VGV (socio oficial de Google) aplica en todos sus proyectos enterprise. Flutter docs oficiales recomiendan esta separacion.
6. **Produccion probada** — BMW, Toyota, Google Pay, Nubank, Alibaba (50-100M+ usuarios) usan Flutter con esta arquitectura en produccion.

#### 1. Why DTOs?

Domain entities must remain pure (no `fromJson`/`toJson`). JSON serialization is delegated to **DTOs** in `infrastructure/dtos/` using `@freezed` code generation. This decouples the API contract from the domain model.

#### 2. How to Use It

DTOs use `@freezed` with `fromJson`/`toJson` generated. Mappers in `infrastructure/mappers/` convert DTO → Entity via constructors named.

#### 3. Developer Policies

- ✅ DTOs in `infrastructure/dtos/` use `@freezed` with `fromJson`/`toJson`.
- ✅ Domain entities use `@freezed` ONLY — NO `fromJson`/`toJson`.
- ✅ Mappers use constructors named (e.g. `PatientEntity(id: dto.id)`), NEVER `Entity.fromJson`.
- ✅ Code generation via `dart run build_runner build`.

---

### go_router — Declarative Navigation & Routing

#### 1. Why go_router? (The Problem & The Solution)

Flutter's built-in `Navigator` is imperative and doesn't support URL-based routing, deep linking, or declarative route definitions. As the app grows, managing navigation with `Navigator.push`/`pop` becomes messy.

`go_router` solves this with:
- **Declarative routing** — all routes defined in one place.
- **URL-based navigation** — `go('/encounter')`, `goNamed('vaccines')`.
- **Redirect guards** — automatically redirect unauthenticated users to login.
- **Deep linking support** — routes map directly to URLs.

In this project, `go_router` is created via `CpGoRouter.create()` in `main.dart`, which receives routes from `CustomConfigs.routes.goRouter` and a `refreshListenable` from `CustomProviders.goRouter` (`GoRouterListenable`). Navigation from features uses `CustomFunction.goRouter.go(...)`.

#### 2. Integration Into the Architecture

| Component | Responsibility |
| :--- | :--- |
| `CpGoRouter.create()` | Builds the `GoRouter` instance in `main.dart`, receives `GoRouterListenable` as `refreshListenable`. |
| `CustomConfigs.routes.goRouter` | Define routes en `shared/configs/app_routes.dart`. |
| `GoRouterListenable` | `ChangeNotifier` that mirrors auth state and notifies GoRouter when auth state changes. |
| `CpGoRouter.create()` inline redirect | Redirect logic dentro de `CpGoRouter.create()` (login vs clinical-history). |

#### 3. How to Use It (Step-by-Step)

##### Step 1: Register a new route (in `shared/configs/app_routes.dart`)

```dart
// lib/shared/configs/app_routes.dart (part of _configs.lib.dart)
class Routes {
  final List<RouteBase> goRouter = [
    GoRoute(
      path: '/',
      name: CpGoRouter.nameLogin,
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/${CpGoRouter.nameClinicalHistory}',
      name: CpGoRouter.nameClinicalHistory,
      builder: (_, _) => const ClinicalHistoryPlaceholderScreen(),
    ),
  ];
}
```

##### Step 2: Navigate from anywhere

```dart
// From any screen or notifier — use CustomFunction.goRouter
CustomFunction.goRouter.go('/vaccines');
CustomFunction.goRouter.push('/appointments');
CustomFunction.goRouter.pop();
```

#### 4. Developer Policies

- 🚫 **Never import `go_router` directly** in feature code. Use `CustomFunction.goRouter.xxx()`.
- 🚫 **Never instantiate `GoRouter` directly** in features. Use `CpGoRouter.create()` in `main.dart`.
- ✅ Define routes in `shared/configs/app_routes.dart` dentro de `Routes.goRouter`.

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

`AppDatabase` manages the sembast `Database` instance, encryption, and lifecycle using proper dependency injection (no longer a singleton). It receives `IPathProviderWrapper` and `DatabaseFactory` via constructor. It is exposed via `appDatabaseProvider`:

```dart
AppDatabase — dependency-injected, manages encrypted sembast database
final db = await ref.read(appDatabaseProvider).database;

Clear all data (on logout or reset)
await ref.read(appDatabaseProvider).resetDatabase();
```

For session/token storage, use `SecureTokenStore` (which implements `ITokenStore`) via `tokenStoreProvider`:

```dart
Save token (from notifier after login)
await ref.read(tokenStoreProvider).save(user.token);

Read token (from main.dart at startup)
final token = await ref.read(tokenStoreProvider).read();

Delete token (on logout)
await ref.read(tokenStoreProvider).delete();
```

Sembast is also used internally by `ClinicalHistoryStore` and `PatientInfoStore` for offline-first storage of clinical data (`clinicalHistoryStoreProvider`, `patientInfoStoreProvider`).

#### 3. Developer Policies

- 🚫 **Never access `AppDatabase` or sembast types directly** from features.
- ✅ Use `appDatabaseProvider` for database access.
- ✅ Use `tokenStoreProvider` for token persistence.
- 🚫 Never import `package:sembast/sembast.dart` in feature code.

---

### flutter_secure_storage — Secure Key-Value Storage

#### 1. Why flutter_secure_storage?

Storing auth tokens and encryption keys in plain text or `SharedPreferences` is a security risk. `flutter_secure_storage` uses the platform's native secure keystore (Keychain on iOS, EncryptedSharedPreferences on Android).

In this project, it is wrapped in `secure_storage_wrapper.dart` (`ISecureStorageWrapper` / `SecureStorageWrapper`) and consumed by two service groups:
- **`SecureTokenStore`** (implements `ITokenStore`) — stores the JWT auth token via `tokenStoreProvider`.
- **`SecureCredentialStore`** (implements `ICredentialStore`) — stores email + password hash for remember-me via `credentialStoreProvider`.
- **`DatabaseKeyService`** — stores the AES-256 encryption key used by `AppDatabase`.

#### 2. How to Use It

Never access `flutter_secure_storage` directly from features. Use these facades:

```dart
From any notifier — via tokenStoreProvider (injectable service)
await ref.read(tokenStoreProvider).save(token);
final token = await ref.read(tokenStoreProvider).read();

app/lib/core/services/storage/secure_storage_wrapper.dart — internal only
Handled by AppDatabase._resolveKey() automatically — never call from features
```

#### 3. Developer Policies

- 🚫 **Never import `flutter_secure_storage` directly** in feature code.
- ✅ Use `tokenStoreProvider` for auth tokens (injectable, overridable in tests).
- ✅ `DatabaseKeyService` is an internal dependency — never called from features.

---

---

### path_provider — File System Paths

#### 1. Why path_provider?

When you need to write files locally (for sharing, caching, etc.), you need platform-appropriate directories. `path_provider` provides access to the device's temporary and documents directories.

In this project, it is wrapped in `path_provider_wrapper.dart` — a **pure utility** (`IPathProviderWrapper` / `PathProviderWrapper`).

#### 2. How to Use It

```dart
app/lib/core/services/device/path_provider_wrapper.dart — pure utility
Get temp directory (files can be deleted by OS)
final tempDir = await ref.read(pathProviderProvider).getTemporaryDirectory();

Get documents directory (persistent storage)
final docsDir = await ref.read(pathProviderProvider).getApplicationDocumentsDirectory();
```

#### 3. Developer Policies

- ✅ Access via `ref.read(pathProviderProvider).xxx()` directly (pure utility).

---

### logger — Structured Logging

#### 1. Logger — Removed

`LoggerWrapper`, `ILoggerWrapper`, `loggerProvider`, and the `logger` package have been removed from the project. Use `debugPrint` directly for temporary debug output. Remove all `debugPrint` calls before submitting a pull request.

---

### internet_connection_checker_plus — Network Connectivity

#### 1. Why internet_connection_checker_plus?

Before making HTTP requests, we need to verify that the device actually has internet access (not just WiFi with no connectivity). This package provides a reliable `InternetConnection().hasInternetAccess` check.

In this project, it is wrapped in `internet_service.dart` (`IInternetService` / `InternetService`) — an **internal dependency** of `DioWrapper`.

#### 2. How It's Used

The `InternetService` is injected into `DioWrapper` and called automatically before every request:

```dart
app/lib/core/network/dio/dio_wrapper.dart — called automatically inside _request()
if (!await _internetService.isConnected()) {
    throw const NoConnectionException();
}
```

It also checks if the server is reachable via a raw TCP socket connection (with 10-second cache).

#### 3. Developer Policies

- 🚫 **Never access `InternetService` directly from features.** `DioWrapper` already handles connectivity checks internally.
- ✅ If you absolutely need connectivity outside HTTP, inject `IInternetService` through your provider — do not access `internetServiceProvider` directly from features; use `ref.read(authDioProvider)` for HTTP calls.

---

### encrypt — AES-256 Encryption

#### 1. Why encrypt?

Session data (auth token, user fullname) stored in the local SQLite database must be encrypted at rest. The `encrypt` package provides AES-256-CBC encryption with secure random IV generation.

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

### fl_chart — Charts & Graphs

#### 1. Why fl_chart?

The app displays lab results as line charts. `fl_chart` is a popular, customizable Flutter charting library.

In this project, it is wrapped in `fl_chart_wrapper.dart` (`IFlChartWrapper` / `FlChartWrapper`) — a **pure utility** (thin UI facade).

#### 2. How to Use It

```dart
From any widget — use the wrapper, never fl_chart directly
(fl_chart wrapper was removed — use fl_chart directly following Clean Architecture rules)
Use `fl_chart` directly via a dedicated screen widget, never in domain/notifier layers.
```

#### 3. Developer Policies

- ✅ Use `fl_chart` directly in screen/widget files (presentation layer only).
- 🚫 **Never import `fl_chart` in domain or notifier layers.** Keep chart logic in the widget tree.

---

## Dev Dependencies used

### Code Generation

This project uses code generation selectively — for freezed entities and Riverpod providers — but avoids it for other concerns.

```bash
# Run after modifying any @freezed or @Riverpod annotated file:
dart run build_runner build --delete-conflicting-outputs
```

### Code generation packages

`freezed` (for immutable data classes), `json_serializable` (for JSON serialization), and `riverpod_generator` (for Riverpod providers) are used where annotated. All other code is written by hand.

### drift_dev — Drift Code Generator

Generates database access code from drift table definitions. Reads `@DataClass`, `@Table`, and `@UseRowClass` annotations and produces type-safe query methods.

Not used — all code is written by hand.

### riverpod_lint — Riverpod Linting

A `custom_lint` plugin that adds Riverpod-specific lint rules to `flutter analyze`. Catches common mistakes like:
- Missing `// manual Provider` annotation.
- Using `ref.read` where `ref.watch` is required.
- Improper notifier method signatures.

Configured in `analysis_options.yaml`.

### flutter_lints — Dart Lint Rules

The official lint rule set from the Flutter team. Enforces consistent code style, naming conventions, and best practices.

### mocktail — Test Mocks

#### 1. Why mocktail?

Unit tests need to isolate the unit under test from its dependencies. `mocktail` lets you create mock implementations of interfaces without manual boilerplate:

```dart
test/mocks/ or inline in test files
class MockAuthRepository extends Mock implements IAuthRepository {}
```

With `mocktail`, you can:
- Stub return values: `when(() => repo.login(...)).thenAnswer(...)`.
- Verify interactions: `verify(() => repo.login(...)).called(1)`.
- Mock async methods, streams, and void methods.

#### 2. How to Use It

```dart
Used in any unit test file under test/features/*/ or test/shared/*
Register fallback values for complex parameter types
registerFallbackValues(Uri());

Stub a method
when(() => mockDatasource.getData()).thenAnswer(
(_) async => <Map<String, dynamic>>[...],
);

Execute the test
final result = await repository.getData();

Verify interaction
verify(() => mockDatasource.getData()).called(1);
```

#### 3. Developer Policies

- ✅ Use `mocktail` for all unit tests (domain, infrastructure, presentation).
- ✅ Create mocks that implement the **wrapper interfaces** (`IFlChart`, `IDioWrapper`, etc.), not raw packages.
- ✅ Register fallback values for any complex parameter types used in mocked methods.

### gherkart — BDD / Gherkin Test Runner

#### 1. Why gherkart?

The project uses Behavior-Driven Development (BDD) with Gherkin syntax (given/when/then scenarios defined in `bdd.feature` files). `gherkart` parses `.feature` files and provides a Dart API to iterate through scenarios and steps.

#### 2. How to Use It

```dart
app/test/bdd/auth_bdd_test.dart
import 'package:gherkart/gherkart.dart';

void main() {
_testFunction(); standalone top-level call
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
| **Result<T>** | Functional error handling with `Result<T>` | `guard(...)` in repositories; `.fold(...)` in notifiers | All repository impls (catch → `Result`), all notifiers (consume → state) |
| **dio** | HTTP client with interceptors | `ref.watch(authDioProvider).get/post/patch/delete/put/multiFiles(uri)` | All datasource impls for API communication |
| **flutter_riverpod** | State management & DI | `// manual Provider` functional providers for wiring; `// manual Provider` Notifiers for state; `ref.watch/read/listen` | Every provider, notifier, and screen in every feature |
| **Sealed classes (Dart 3 native)** | Immutable data classes & union types | `sealed class` + `extends` for state variants; plain `class` for entities | All domain entities (`*_entity.dart`), all presentation states (`*_state.dart`) |
| **Manual JSON** | Hand-written `fromJson`/`toJson` | Map access with type casts | DTOs in `infrastructure/dtos/` |
| **go_router** | Declarative routing with redirect guards | `CpGoRouter.create(routes:, refreshListenable:)` in main.dart; `CustomFunction.goRouter.go/push/pop(...)` from features | `lib/shared/functions/cp_go_router.dart` (wrapper), `lib/shared/configs/app_routes.dart` (route defs) |
| **sembast** | Lightweight NoSQL document DB with AES-256 encryption | `ref.read(appDatabaseProvider).database` / `.resetDatabase()` | `app_database.dart` (encrypted sembast) |
| **flutter_secure_storage** | Platform-native secure keystore | `ref.read(tokenStoreProvider).save/read/delete()` for tokens; `DatabaseKeyService` (internal) for DB encryption key | `secure_token_store.dart` (auth tokens), `secure_storage_wrapper.dart` (DB encryption key) |
| **path_provider** | Platform temp & documents directories | `await ref.read(pathProviderProvider).getTemporaryDirectory()` or `.getApplicationDocumentsDirectory()` | Temp file storage for sharing, caching |
| **internet_connection_checker_plus** | Internet access detection | Automatically called inside `dio_wrapper.dart` before every request | Only inside `internet_service.dart` (injected into `DioWrapper`) |
| **encrypt** | AES-256-CBC encryption | Used by `database_encrypt.dart` to create `SembastCodec` for transparent encryption | Only inside `database_encrypt.dart` (internal to `AppDatabase`) |

| **fl_chart** | Line charts & graphs | Use directly in screen widgets (presentation layer only) | `lab_results_chart` feature for lab result visualization |

### Dev Dependencies

| Package | Description | How to Use | Where It's Used |
| :--- | :--- | :--- | :--- |
| **(no code gen packages)** | All code is written by hand | Not applicable | Not applicable |
| **riverpod_lint** | Riverpod-specific lint rules | Added to `analysis_options.yaml` (custom_lint) | Enforces correct Riverpod usage at analyze time |
| **flutter_lints** | Official Flutter lint rules | Added to `analysis_options.yaml` | Enforces code style & best practices |
| **mocktail** | Mock interfaces for unit tests | `class MockRepo extends Mock implements IRepo {}` + `when/verify` | All unit tests under `test/features/*/` and `test/shared/*/` |
| **gherkart** | Parse and run Gherkin `.feature` files | `GherkartParser(file).parse()` → iterate scenarios → `testWidgets` per scenario | BDD tests under `test/bdd/*_bdd_test.dart` |

---

## Interceptor

There is a single Dio across the entire app. No matter which feature makes the request (`auth`, `clinical_history`, or any other) — they all use `ref.read(authDioProvider)` (the same `DioWrapper` instance). The `AuthInterceptor` is added once to that Dio and from then on intercepts all HTTP requests from any feature.

```dart
// Handle401UseCase now uses IAuthRepository directly — no separate service needed
// The use case is wired via handle401UseCaseProvider in auth_provider.dart
@riverpod
Handle401UseCase handle401UseCase(Ref ref) => Handle401UseCase(
  tokenStore: ref.watch(tokenStoreProvider),
  connectivityChecker: ref.watch(connectivityCheckerProvider),
  credentialStore: ref.watch(credentialStoreProvider),
  repository: ref.watch(authRepositoryProvider),
);
```

The interceptor receives `Handle401UseCase` via constructor injection:

```dart
class AuthInterceptorImpl implements IAuthInterceptorProvider {
  const AuthInterceptorImpl({required this.handle401UseCase});
  final Handle401UseCase handle401UseCase;

  @override
  void setupAuthInterceptor(IDioWrapper dioWrapper, ...) {
    dioWrapper.addAuthInterceptor(() async {
      final result = await handle401UseCase();
      return switch (result) {
        Success(data: final retryResult) => retryResult,
        Failure() => const RetryFailed(),
      };
    }, onForceLogout: ...);
  }
}
```

When clinical_history receives a 401:

```bash
AuthRemoteDatasource of clinical_history
↓ uses ref.read(authDioProvider)
Dio.get('/clinical-history/...')
↓
AuthInterceptor.onError() detects 401
↓ executes
Handle401UseCase.call() → returns Result<RetryResult>
│
├─ connectivityChecker.isConnected()?
│ └─ NO → RetryNoConnection (silent, pass through)
│
├─ tokenStore.readToken()? → token found
│ └─ IAuthRepository.refreshToken(token)
│   └─ IAuthRemoteDatasource.refreshToken(token)
│     └─ authDioProvider.post(/refreshtoken) → new token
│     ├─ success → save new token → RetrySuccess(newToken)
│     └─ fails → RetryFailed → onForceLogout
│
└─ Result<RetryResult> unwrapped by interceptor
↓ is Success(RetrySuccess(token)):
internalDio.fetch(original requestOptions with new Authorization header) → retry
↓ success
handler.resolve(response) → clinical_history receives its data
```

**Key distinction:**

- `Handle401UseCase` uses `IAuthRepository` (not a custom service) — follows the standard `UseCase → Repository → guard() → Datasource` flow.
- `internalDio` is a separate, bare `Dio` instance created inside `AuthInterceptor`. It is used **only** for retrying the original failed request after obtaining a new token.
- The auth datasource uses a dedicated `authDioProvider` (Dio without auth interceptor) to avoid re-entering the interceptor chain for refresh and re-login calls.
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
| Exists | Expired | Internet, refresh fails | POST /refresh_token → Failure(failure) → clearSession() → Success(null) → login screen |
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
main → Notifier → UseCase → Repository → Local Datasource
↓
Sembast (patient)
SecureStorage (token)
↓
Main ← Notifier ← UseCase ← Repository ← Datasource
↓
AuthState.loaded(...)
↓
GoRouter redirects to /clinical-history
```

When the domain communicates with infrastructure, there is an extra decision. The infrastructure call is not a single one — it is potentially two:

1. **Local** (always): read patient + token + histories from Sembast/SecureStorage
2. **Remote** (only if token expired + internet): POST /refreshtoken

```bash
RestoreSessionUseCase.call()
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
COMPILE TIME (imports) RUNTIME (data flow)
────────────────────── ─────────────────────
Presentation → Domain Presentation → Domain → Infrastructure
Infrastructure → Domain (the flow traverses all layers)
Domain → no one
```

At compile time, arrows point inward: Infrastructure imports Domain interfaces, and Domain imports nothing from outer layers.

At runtime, the data flow traverses all layers — Presentation starts, Domain orchestrates, Infrastructure executes. The result comes back the same way.

There are three distinct runtime patterns in this project:

### Sync Simple Pattern

```
Presentation Domain Infrastructure External
──────────── ────── ────────────── ───────
UseCase → Repository → Datasource → HTTP/DB/SDK
↕ ↕
Notifier ←────── Result<T> Exception → guard()
↕
Widget ←─────── AuthState.loaded()
↕
Navigation (GoRouter)
```

Used for: Login, Register, Restore session, Standard CRUD, typical GET/POST/PUT/DELETE.

**Key characteristic:** data always returns the way it came. A single causal thread: request → response.

### Outgoing Only Pattern

```
Presentation Domain Infrastructure External
──────────── ────── ────────────── ───────
UseCase → DomainService → IPort.log() → LoggerImpl
```

Used for: Failure propagation, logging, analytics, push notifications.

**Key characteristic:** the UI never receives a response. Return type is `void` or `Future<void>`.

### Comparison

| Aspect | Sync Simple | Outgoing Only |
| :--- | :--- | :--- |
| Return value | Yes (Result\<T, E\>) | No (void) |
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
└── MaterialApp.router(routerConfig: CpGoRouter.create(
    routes: CustomConfigs.routes.goRouter,
    refreshListenable: ref.read(CustomProviders.goRouter),
  ))
│
LoginScreen (presentation/screens)
└── ref.read(authProvider.notifier).login(email, password, rememberMe: true)
│
AuthNotifier (presentation/notifiers)
├── state = AuthState.loading()
├── ref.read(loginUseCaseProvider).call(email, password, rememberMe)
│ │
│ LoginUseCase (domain/usecases)
│ ├── CustomValidator.auth.validateEmail(email)
│ ├── CustomValidator.auth.validatePassword(password)
│ ├── _passwordHasher.hash(password) ← BcryptWrapper (via IPasswordHasher)
│ ├── _repository.login(email, passwordHash)
│ │ │
│ │ AuthRepositoryImpl (infrastructure/repositories)
│ │ └── guard(
│ │ remote: guard(() => _remoteDatasource.login(...))
│ │ │
│ │ AuthRemoteDatasourceImpl
│ │ └── _dio.post('/login') → HTTP
│ │ local: guard(() => _localDatasource.restoreSession())
│ │ )
│ │ → Result<LoginResponseEntity>
│ │
│ ├── _tokenStore.save(data.token.key) ← token persistence in use case
│ └── if (rememberMe) _repository.saveSession(data, email, passwordHash)
│ └── AuthRepositoryImpl
│ └── AuthRepositoryImpl.saveSession()
│ └── delegates to:
│ ├── IPatientLocalDatasource.save(...) ← Sembast
│ ├── ITokenLocalDatasource.save(...) ← Secure Storage
│ └── ICredentialLocalDatasource.saveCredentials(...) ← Secure Storage
│
└── result.fold<Future<void>>(
(failure) → state = AuthState.failure(failure)   ← AppError passed to state; UI localizes via localizeError()
(data) →
├── state = AuthState.loaded(patient, token, clinicalHistory)
└── CustomFunction.goRouter.go('/clinical-history') → GoRouter redirects to /clinical-history
```

### restoreSession() Flow (for comparison)

```bash
AuthNotifier
└── ref.read(restoreSessionUseCaseProvider).call()
│
RestoreSessionUseCase (domain/usecases)
├── _connectivityChecker.isConnected()? ← InternetService (implements IConnectivityChecker)
│ └── YES → _credentialStore.readCredentials()?
│ └── creds found → _repository.login(email, passwordHash)
│
├── _repository.restoreSession() ← LocalDatasource
├── _tokenVerifier.isExpired(token) ← JwtTokenExpiryChecker (implements ITokenVerifier)
├── _connectivityChecker.isConnected() ← InternetService (implements IConnectivityChecker) (checked again)
└── _tryRefresh(data)
├── _repository.refreshToken(token) ← AuthRepositoryImpl → RemoteDatasource
├── on success: _tokenService.save(newToken)
└── on failure: _credentialStore.clearSession()
```

---

## Eliminating Thin Service Adapters

### Problem

The auth feature had 5 service files that were all eliminated. Four were one-line delegations — adapters that existed solely to bridge domain interfaces with shared wrapper implementations. The fifth (`dio_token_retry_handler.dart`) had real logic but was later eliminated when `Handle401UseCase` was refactored to use `IAuthRepository` directly via `authDioProvider`, breaking the Riverpod cycle.

| Service | Lines | Actual logic | Status |
| :--- | :--- | :--- | :--- |
| `connectivity_checker.dart` | 11 | `_internetService.isConnected()` | Eliminated |
| `crypto_password_hasher.dart` | 11 | `_crypto.sha256(password)` | Eliminated |
| `token_expiry_checker.dart` | 11 | `_tokenService.isTokenExpired(token)` | Eliminated |
| `token_credential_store.dart` | 18 | `_tokenService.read()` / `.save()` / `.readCredentials()` | Eliminated |
| `dio_token_retry_handler.dart` | 45 | Real HTTP + JSON logic | **Eliminated** (moved to Handle401UseCase + IAuthRepository) |

### Solution

**Cross-cutting interfaces live in `shared/interfaces/`**, while auth-specific concerns that need an interface live in `features/auth/domain/services/`:

```
shared/interfaces/
i_connectivity_checker.dart
i_credential_store.dart
i_token_store.dart
i_token_verifier.dart
i_password_hasher.dart

features/auth/domain/services/
i_token_retry_service.dart ← only used by Handle401UseCase
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

**Providers use wrappers as the interface types:**

```dart
// manual Provider
IPasswordHasher passwordHasher(Ref ref) => ref.watch(passwordHasherProvider);

// manual Provider
ITokenVerifier tokenVerifier(Ref ref) => ref.watch(tokenVerifierProvider);

// manual Provider
IConnectivityChecker connectivityChecker(Ref ref) => ref.read(internetServiceProvider) as IConnectivityChecker;
```

### Servicios eliminados — `Handle401UseCase` ahora usa `IAuthRepository`

`Handle401UseCase` solia usar un servicio creado inline en `AuthInterceptorImpl`
para evitar un ciclo de dependencia Riverpod entre `authDioProvider` y `authRemoteDatasourceProvider`.

La solucion fue crear un `authDioProvider` separado (Dio sin auth interceptor) para el datasource de auth,
rompiendo el ciclo. Ahora `Handle401UseCase` usa `IAuthRepository` directamente via
`handle401UseCaseProvider`, siguiendo el flujo estandar `UseCase → Repository → guard() → Datasource`.

Esto elimino los servicios intermedios y la creacion inline en `AuthInterceptorImpl`.
`AuthInterceptorImpl` ahora recibe `Handle401UseCase` por constructor (1 parametro en vez de 6).
IAuthRemoteDatasource authRemoteDatasource(Ref ref) => AuthRemoteDatasourceImpl(
dio: ref.watch(authDioProvider), ← necesita Ref
);
```

The `AuthInterceptor` must be connected to `DioWrapper` before any HTTP request can be made. Waiting for Riverpod would leave the app unprotected against 401s during the initial startup requests.

#### Unified with `Result<T>` — `Handle401UseCase` returns `Result<RetryResult>`

`Handle401UseCase` now follows the standard pattern. It returns `Future<Result<RetryResult>>` — unified with all other use cases.

```
Datasource pattern:
Datasource → Repository.guard() → Result<T> → UseCase → Notifier.fold()

Handle401UseCase pattern (current):
AuthInterceptor → Handle401UseCase → IAuthRepository → guard() → IAuthRemoteDatasource → HTTP
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
| **Example** | `AuthRemoteDatasourceImpl` — POST /login, returns raw JSON | `Handle401UseCase` — flow through `IAuthRepository.refreshToken()`, returns `Result<TokenEntity>` |

The flow for each:

**Datasource call (standard CRUD):**
```
Notifier → UseCase → Repository → guard() → Datasource → HTTP
↑ ↑
devuelve Result<T> lanza Exception
```

**Handle401UseCase flow (standard — no separate service):**
```
AuthInterceptor → Handle401UseCase → IAuthRepository.refreshToken() → guard() → IAuthRemoteDatasource → HTTP
↑
devuelve Result<RetryResult>
```

**Decision guide for new code:**

| ¿Tu clase... | Entonces es un... |
| :--- | :--- |
| Lee/escribe datos de una API o DB y el resultado debe llegar a la UI? | **Datasource** → pasa por Repository → `guard()` → `Result` |
| Necesita estar disponible antes de que Riverpod exista? | **Excepcion** — documentar en la arquitectura |
| Es un adapter que solo delega un método a otro wrapper sin lógica real? | **NO** — la interfaz debe ir a `shared/interfaces/` y el wrapper implementarla directamente |

**Regla:** Todo flujo sigue `UseCase → Repository → guard() → Datasource`. No hay servicios intermedios.
`Handle401UseCase` y `RestoreSessionUseCase` fueron refactorizados para seguir esta regla.

#### Anti-pattern example: thin service adapters

The 4 eliminated services were all thin adapters — less than 18 lines, delegating one method to an existing wrapper with zero transformation:

```dart
// ❌ MAL — features/auth/infrastructure/services/connectivity_checker.dart (ELIMINADO)
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
Future<bool> isConnected() => InternetConnection().hasInternetAccess;
}
```

**Regla práctica para detectar un thin service:** Si el service tiene menos de 15 líneas y solo delega un método a otro wrapper sin transformación de datos, es una señal de que la interfaz debería estar en `shared/interfaces/` y el wrapper implementarla directamente.

### Why `shared/interfaces/` and not `shared/domain/interfaces/`

The `shared/` folder is organized by **type of content**, not by layer:

| Folder | Type | Layer |
| :--- | :--- | :--- |
| `models/` | Domain entities | Domain |
| `interfaces/` | Domain interfaces | Domain |
| `exceptions/` | Failure types | Domain |
| `validators/` | Validation logic | Domain |
| `functions/` | Package wrapper interface (`offline_first_repository.dart`) | Infrastructure |
| *(migrated to design_system/)* | Theme & colors (AppColors, AppTheme) | Presentation |
| `providers/` | Riverpod DI | Infrastructure |

No folder under `shared/` uses a layer name (`domain/`, `infrastructure/`, `presentation/`). Adding `domain/interfaces/` would break this convention — it would be the only folder organized by layer. `shared/interfaces/` follows the existing pattern: named by type, parallel to `shared/models/`.

### `RestoreSessionUseCase` depends only on `shared/interfaces/`

`RestoreSessionUseCase` uses `ICredentialStore.saveToken()` (from `shared/interfaces/`) after a successful token refresh, keeping the domain layer free of infrastructure imports:

```dart
class RestoreSessionUseCase {
final ICredentialStore _credentialStore;

Future<Result<...>> _tryRefresh(data) async {
final newToken = ...;
await _credentialStore.saveToken(newToken.key);
}
}
```

The domain layer imports only `shared/interfaces/` abstractions and `shared/exceptions/` exception types — no infrastructure packages.

### Domain Dependency Map

After all refactoring, the domain layer (`features/auth/domain/`) has clear boundaries:

**El dominio SOLO importa de:**

| Importa desde | Tipos |
| :--- | :--- |
| `shared/interfaces/` | `IConnectivityChecker`, `ICredentialStore`, `ITokenStore`, `ITokenVerifier`, `IPasswordHasher` |
| `shared/error/` | `RetryResult` |
| `shared/exceptions/` | `ApiException`, `NoConnectionException`, `ServerUnreachableException`, `UnexpectedResponseException`, `AppTimeoutException` |
| `shared/validators/` | `CustomValidator` (permitido por reglas del proyecto) |
| Sus propios archivos | Entities, repositorios, datasources, use cases (`IAuthRepository`, `RestoreSessionUseCase`, `Handle401UseCase`) |

**El dominio NUNCA importa (y no debe hacerlo):**

| No importa | Razón |
| :--- | :--- |
| `core/services/` o `core/network/dio/` | Contiene wrappers de paquetes externos (infraestructura) |
| `core/network/interceptors/` | Contiene Dio interceptors (infraestructura) |
| `core/database/` | Contiene persistencia sembast (infraestructura) |
| `shared/providers/` | Contiene `CustomProviders` facade (expone providers globales) |
| `data/` de cualquier feature | Viola la Dependency Rule de Clean Architecture |
| `presentation/` de cualquier feature | El dominio no sabe de UI |

### What was kept

All services were eliminated. The logic was moved into use cases (`Handle401UseCase`, `RestoreSessionUseCase`)
that use `IAuthRepository` directly, following the standard `UseCase → Repository` flow.

#### Servicios eliminados

Las carpetas `domain/services/` e `infrastructure/services/` fueron eliminadas.
Toda la logica que antes vivia en servicios ahora esta en use cases (`Handle401UseCase`,
`RestoreSessionUseCase`) que usan `IAuthRepository` directamente, siguiendo el flujo estandar
`UseCase → Repository → guard() → Datasource`.

### Test impact

All 276 unit tests and 24 integration tests pass without behavioral changes. The only test modifications were:
- Imports changed from `features/auth/domain/services/` to `shared/exceptions/_exceptions.lib.dart`
- `TokenCredentialStore(mockTokenService)` replaced with `mockTokenService` directly (the mock now implements `ICredentialStore`)
- Integration test fakes (`_FakeTokenStore`, `_FakeExpiredTokenStore`) now implement `ITokenStore` and `ICredentialStore`

---

## Architectural decisions for a new project (lessons learned)

This project was built incrementally and some conventions evolved over time. If starting a new Clean Architecture project from scratch in a large company, here is what would likely change:

### 1. Folder structure: `core/` vs `shared/`

The project completed the migration from a mixed `shared/` folder to a clean separation:

```
lib/
├── shared/ ← Pure domain abstractions
│ ├── interfaces/
│ ├── exceptions/
│ ├── models/
│ ├── validators/
│ ├── pagination/
│ └── functions/ (offline_first_repository)
│
├── core/ ← Pure infrastructure
│ ├── database/ (AppDatabase, serializers, tables)
│ ├── error/ (AppError, Result, guard)
│ ├── network/ (dio_wrapper, auth_interceptor, connectivity, certificate pinning)
│ ├── services/ (auth, crypto, device, storage)
│ └── utils/
│
├── [eliminado] app/ ← Composition root eliminado
│ (los providers se importan directamente desde core/)
│
├── l10n/ ← AppLocalizations (i18n)
│
└── features/
```

**Why:** The dependency direction becomes visible in the import path. If a domain file imports from `core/`, it is immediately visible as a violation. `shared/` is pure domain, `core/` is pure infrastructure. No mixing.

### 2. Naming: descriptive suffixes, not cryptic prefixes

**Current:** `dio_wrapper.dart` — what does `cp` mean? Custom Package? It is not obvious to newcomers.

**Recommended:** Suffixes that describe the role:

| Current | Recommended |
| :--- | :--- |
| `dio_wrapper.dart` → `DioWrapper` / `IDioWrapper` | `dio_wrapper.dart` → `DioWrapper` / `IDioWrapper` |
| `router_provider.dart` → `routerProvider` | `go_router_wrapper.dart` → `routerProvider` |
| `secure_token_store.dart` → `SecureTokenStore` (implements `ITokenStore`) | `token_service.dart` → `TokenService` (deprecated) |

The file name `dio_wrapper.dart` tells exactly what it is without needing to know project-specific conventions.

### 3. Use Dart 3 sealed classes (current pattern)

The project uses `sealed class Result<T>` with `Success` and `Failure` variants, plus `guard()`:

```dart
sealed class Result<T> {
const Result();
}

class Success<T> extends Result<T> {
final T data;
const Success(this.data);
}

class Failure<T> extends Result<T> {
final AppError error;
const Failure(this.error);
}
```

Usage — Dart 3 pattern matching with `is` checks:
```dart
if (result is Success) {
final data = (result as Success).data;
} else if (result is Failure) {
final error = (result as Failure).error;
}
```

Or with `switch`:
```dart
return switch (result) {
Success(data: final d) => AuthState.loaded(d),
Failure(error: final e) => AuthState.error(e),
};
```

**Benefits:** Zero external dependencies, native exhaustiveness checking.

### 4. No code generation (current pattern)

The project does not use code generation. All code is written by hand using Dart 3 features:

```dart
Instead of code-gen providers:
final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final loginProvider = Provider.family<void, LoginParams>((ref, params) async {
ref.read(authStateProvider.notifier).state = AuthState.loading();
final result = await ref.read(loginUseCaseProvider).call(params);
...
});

Instead of freezed sealed classes:
sealed class AuthState {
const AuthState();
}
class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthLoaded extends AuthState {
final PatientEntity patient;
final TokenEntity token;
const AuthLoaded({required this.patient, required this.token});
}
class AuthFailure extends AuthState {
final String message;
const AuthFailure(this.message);
}
```

**Benefits:** Zero code generation means instant builds, no conflicts, predictable code.

### 5. Riverpod: manual NotifierProvider pattern

**Current:** Notifiers use `// manual Provider` with `extends Notifier<State>`:

```dart
final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
@override
AuthState build() => const AuthInitial();

Future<void> login(String email, String password) async {
state = const AuthLoading();
final result = await ref.read(loginUseCaseProvider).call(email: email, password: password);
if (result is Success) {
state = AuthLoaded(patient: result.data.patient, token: result.data.token);
} else if (result is Failure) {
state = AuthFailure(result.error);
}
}
}
```

This is the manual Riverpod pattern: no code generation, no annotations, just `NotifierProvider`.

### 6. Error handling: typed errors with metadata + `.technical()` constructor

**Current:** Each subclass hardcodes a user-facing message string. Localization requires changing error classes.

**Pattern:**
- Domain/infrastructure uses `AppError.technical()` constructors (no `userMessage` — empty string placeholder).
- UI layer maps types to localized strings via `localizeError()` from `shared/error/error_localizer.dart`.

```dart
sealed class AppError {
  final String userMessage;
  final String? technicalMessage;
  final StackTrace? stackTrace;
  const AppError(this.userMessage, {this.technicalMessage, this.stackTrace});
  const AppError.technical({this.technicalMessage, this.stackTrace}) : userMessage = '';
}

class NetworkError extends AppError {
  final int? statusCode;
  const NetworkError(super.userMessage, {this.statusCode, super.technicalMessage});
  const NetworkError.technical({super.technicalMessage, super.stackTrace}) : super.technical();
}

class ValidationError extends AppError {
  final String field;
  const ValidationError(super.userMessage, {this.field, super.technicalMessage});
  const ValidationError.technical({super.technicalMessage, super.stackTrace, this.field}) : super.technical();
}
```

**Why:** Errors carry typed metadata (statusCode, field name, stack trace) instead of hiding it in a string. All user-facing strings are centralized in l10n/ and mapped via `localizeError()`.

### 7. Service locator only for infrastructure, not for domain

**Current:** `shared/providers/_providers.lib.dart` centraliza los 4 providers globales via `CustomProviders` facade. Cada feature importa directamente los providers que necesita desde los barrels de `core/` (`core/database/`, `core/network/`, `core/services/`). No existe composition root separado.

### Comparison table

| Decision | This project | New project (recommended) |
| :--- | :--- | :--- |
| Folder separation | `shared/` (domain) + `core/` (infra) + `app/` (composition) | `shared/` (domain) + `core/` (infra) |
| Naming | `_wrapper` suffix (descriptive) | `_wrapper` suffix (descriptive) |
| Result/Result | Dart 3 sealed class (native) | Dart 3 sealed class (native) |
| Code generation | None | None |
| Providers | `NotifierProvider` (manual) | `NotifierProvider` (manual) |
| Error model | `Failure.message` (string only) | `AppError` (typed fields) |
| Service locator | Riverpod providers (eliminated `CustomFunction`) | Riverpod providers |
| Part files | Shared barrels use `part`; features use standalone files | Standalone files preferred |
| Navigation wrapper | `CustomFunction.goRouter` (wrapper) (single source: `CustomConfigs.routes.goRouter`) | `CpGoRouter` wrapper |
| Tests | By layer (6 levels) | By contract (integration + complex logic) |

### Summary

The project has eliminated code generation entirely. Dart 3 sealed classes + pattern matching make external Result packages unnecessary. Manual Riverpod providers give the same safety with zero build-time overhead.

These decisions are not about right vs wrong — they are about **when complexity is justified**. This project chose to eliminate code generation entirely for faster builds, fewer CI failures, and simpler onboarding.
