## Auth — Implementation Tasks

### Shared mock data
- [x] Removed FakeAuthRemoteDatasource — auth uses AuthRemoteDatasourceImpl for all environments
- [x] Old lib/shared/jsons/ directory deleted

### Domain
- [x] Define IAuthDatasource interface
- [x] Create PatientEntity with @freezed and @JsonSerializable
- [x] Create TokenEntity with @freezed and @JsonSerializable
- [x] Create LoginResponseEntity with @freezed and @JsonSerializable
- [x] Create ClinicalHistoryEntity with @freezed and @JsonSerializable (with nested sub-entities: Service, Facility, Professional, Diagnosis, Attachment, State)
- [x] Define IAuthRepository interface (login, refreshToken, saveSession, clearSession, restoreSession)
- [x] Create LoginUseCase
- [x] Create RefreshTokenUseCase
- [x] LoginUseCase calls _repository.saveSession() directly (SaveSessionUseCase removed)
- [x] Refactor ClearSessionUseCase to depend on IAuthRepository instead of local services
- [x] Create RestoreSessionUseCase

### Infrastructure
- [x] Implement AuthDatasourceImpl (real HTTP via IDioWrapper — no mock fallback inside datasource)
- [x] Create AuthMapper (JSON -> entity, no DTOs — entities are used directly)
- [x] Implement AuthRepositoryImpl (login, refreshToken, saveSession, clearSession, restoreSession) with IPatientInfoStore, IClinicalHistoryStore, ITokenService, AppDatabase injected

### Presentation
- [x] Create AuthState sealed class (AuthInitial, AuthLoading, AuthLoaded, AuthFailure)
- [x] Create AuthNotifier with methods: login, logout, restoreSession (all use fold with Result<T>)
- [x] Create Riverpod DI chain providers (datasource, repository, usecases, notifier)
- [x] Create LoginScreen with email field, password field, "Remember me" checkbox, login button
- [x] Create login screen widgets (error display, loading indicator)

### Navigation (if applicable)
- [x] Add /login route to app_router.dart
- [x] Add /clinical_history route to app_router.dart
- [x] Add navigation trigger from AuthNotifier (go to /login or /clinical_history based on auth state)
- [x] GoRouter directly observes authProvider for auth state changes

### Shared dependencies used
- [x] httpServiceProvider — IDioWrapper (HTTP calls)
- [x] tokenStoreProvider — ITokenStore (delete token on logout)
- [x] appDatabaseProvider — IAppDatabase (session persistence for remember-me)
- [x] passwordHasherProvider — IPasswordHasher (password hashing)
- [x] guard() from shared/error/result_guard.dart (converts exceptions to FailureResult)
- [x] localizeError() — pure function in shared/error/error_localizer.dart (replaced ErrorPropagation)
- [x] clinicalHistoryStoreProvider — IClinicalHistoryStore (sembast storage)

### Tests
- [x] Unit tests: domain entities, usecases, datasource, repository, notifier, screens
- [x] Widget tests: login screen form behavior, error display, loading state
- [x] BDD tests: 11 scenarios from bdd.feature via gherkart
- [x] Integration: auth_login_successful_flow
- [x] Integration: auth_login_invalid_credentials_flow
- [x] Integration: auth_logout_flow
- [x] Integration: auth_auto_login_valid_token
