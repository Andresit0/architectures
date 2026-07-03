## Auth — Implementation Tasks

### Shared mock data
- [x] Create lib/shared/jsons/auth_json.dart
- [x] Update _jsons.lib.dart and _jsons.dart barrel files

### Domain
- [x] Define IAuthDatasource interface
- [x] Create PatientEntity with @freezed and @JsonSerializable
- [x] Create TokenEntity with @freezed and @JsonSerializable
- [x] Create LoginResponseEntity with @freezed and @JsonSerializable
- [x] Create ClinicalHistoryEntity with @freezed and @JsonSerializable (with nested sub-entities: Service, Facility, Professional, Diagnosis, Attachment, State)
- [x] Define IAuthRepository interface (login, refreshToken, saveSession, clearSession, restoreSession)
- [x] Create LoginUseCase
- [x] Create RefreshTokenUseCase
- [x] Refactor SaveSessionUseCase to depend on IAuthRepository instead of local services
- [x] Refactor ClearSessionUseCase to depend on IAuthRepository instead of local services
- [x] Create RestoreSessionUseCase

### Infrastructure
- [x] Implement AuthDatasourceImpl (real HTTP via cp_dio, with mock fallback via CustomJsons)
- [x] Create AuthMapper (JSON -> entity, no DTOs — entities are used directly)
- [x] Implement AuthRepositoryImpl (login, refreshToken, saveSession, clearSession, restoreSession) with IPatientInfoStore, IClinicalHistoryStore, ITokenService, AppDatabase injected

### Presentation
- [x] Create AuthState sealed class (AuthInitial, AuthLoading, AuthLoaded, AuthFailure)
- [x] Create AuthNotifier with methods: login, logout, restoreSession (all use fold with Either<Failure, T>)
- [x] Create Riverpod DI chain providers (datasource, repository, usecases, notifier)
- [x] Create LoginScreen with email field, password field, "Remember me" checkbox, login button
- [x] Create login screen widgets (error display, loading indicator)

### Navigation (if applicable)
- [x] Add /login route to app_routes.dart
- [x] Add /clinical_history route to app_routes.dart
- [x] Add navigation trigger from AuthNotifier (go to /login or /clinical_history based on auth state)
- [x] Wire GoRouterListenable to auth state changes

### Shared dependencies used
- [x] CustomProviders.dio — CpDio (HTTP calls)
- [x] CustomProviders.token — ITokenService (delete token on logout)
- [x] CustomProviders.sembast — ICpSembast (session persistence for remember-me)
- [x] CustomFunction.crypto — CpCrypto (SHA-256 password hashing)
- [x] CustomFunction.fpdart — CpFpdart (Either/Failure guard)
- [x] CustomFunction.failure — CpFailure (error message formatting)
- [x] CustomDb.clinicalHistory — ClinicalHistoryStore (sembast storage)

### Tests
- [x] Unit tests: domain entities, usecases, datasource, repository, notifier, screens
- [x] Widget tests: login screen form behavior, error display, loading state
- [x] BDD tests: 11 scenarios from bdd.feature via gherkart
- [x] Integration: auth_login_successful_flow
- [x] Integration: auth_login_invalid_credentials_flow
- [x] Integration: auth_logout_flow
- [x] Integration: auth_auto_login_valid_token
