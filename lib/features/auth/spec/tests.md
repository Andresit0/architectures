tests:
  unit:
    - name: auth_datasource_login_success_returns_patient_token_and_history
      layer: infrastructure
      given: Email and passwordHash are valid
      when: AuthDatasourceImpl.login(email, passwordHash) is called
      then: Returns LoginResponseEntity with patient, token, and clinical_history list

    - name: auth_datasource_login_401_throws_ApiException
      layer: infrastructure
      given: Email or passwordHash is invalid
      when: AuthDatasourceImpl.login(email, passwordHash) is called
      then: Throws ApiException with status 401

    - name: auth_datasource_refreshToken_success_returns_new_token
      layer: infrastructure
      given: A valid token exists
      when: AuthDatasourceImpl.refreshToken(token) is called
      then: Returns TokenEntity (extracted from response via AuthMapper.refreshTokenFromJson)

    - name: auth_datasource_refreshToken_401_throws_ApiException
      layer: infrastructure
      given: The token is expired or invalid
      when: AuthDatasourceImpl.refreshToken(token) is called
      then: Throws ApiException with status 401

    - name: auth_repository_login_success_returns_Right
      layer: infrastructure
      given: AuthDatasource returns a valid response
      when: AuthRepositoryImpl.login(email, passwordHash) is called
      then: Returns Right(LoginResponseEntity)

    - name: auth_repository_login_failure_returns_Left
      layer: infrastructure
      given: AuthDatasource throws ApiException
      when: AuthRepositoryImpl.login(email, passwordHash) is called
      then: Returns Left(ApiFailure)

    - name: auth_repository_refreshToken_success_returns_Right
      layer: infrastructure
      given: AuthDatasource returns a new token
      when: AuthRepositoryImpl.refreshToken(token) is called
      then: Returns Right(TokenEntity)

    - name: auth_repository_refreshToken_failure_returns_Left
      layer: infrastructure
      given: AuthDatasource throws ApiException
      when: AuthRepositoryImpl.refreshToken(token) is called
      then: Returns Left(ApiFailure)

    - name: auth_usecase_login_calls_repository
      layer: domain
      given: AuthRepository is mocked
      when: LoginUseCase.call(email, passwordHash) is called
      then: Delegates to AuthRepository.login and returns the result

    - name: auth_usecase_refreshToken_calls_repository
      layer: domain
      given: AuthRepository is mocked
      when: RefreshTokenUseCase.call(token) is called
      then: Delegates to AuthRepository.refreshToken and returns the result

    - name: auth_repository_saveSession_success_returns_Right
      layer: infrastructure
      given: All local storage services succeed
      when: AuthRepositoryImpl.saveSession(data, email, passwordHash) is called
      then: Returns Right(void) and all save methods are called
    - name: auth_repository_saveSession_failure_returns_UnexpectedFailure
      layer: infrastructure
      given: PatientInfo.save() throws an exception
      when: AuthRepositoryImpl.saveSession(data, email, passwordHash) is called
      then: Returns Left(UnexpectedFailure)
    - name: auth_repository_clearSession_success_returns_Right
      layer: infrastructure
      given: TokenService.deleteAll() and AppDatabase.resetDatabase() succeed
      when: AuthRepositoryImpl.clearSession() is called
      then: Returns Right(void) and both methods are called
    - name: auth_repository_clearSession_failure_returns_UnexpectedFailure
      layer: infrastructure
      given: TokenService.deleteAll() throws an exception
      when: AuthRepositoryImpl.clearSession() is called
      then: Returns Left(UnexpectedFailure)
    - name: auth_repository_restoreSession_valid_returns_Right_with_entity
      layer: infrastructure
      given: PatientInfo, TokenService, and ClinicalHistory return valid data
      when: AuthRepositoryImpl.restoreSession() is called
      then: Returns Right(LoginResponseEntity) with patient, token, and clinical history
    - name: auth_repository_restoreSession_no_patient_returns_null
      layer: infrastructure
      given: PatientInfo.load() returns null
      when: AuthRepositoryImpl.restoreSession() is called
      then: Returns Right(null)
    - name: auth_repository_restoreSession_expired_token_clears_and_returns_null
      layer: infrastructure
      given: Token is expired
      when: AuthRepositoryImpl.restoreSession() is called
      then: TokenService.deleteAll() is called and returns Right(null)
    - name: auth_repository_restoreSession_failure_returns_UnexpectedFailure
      layer: infrastructure
      given: PatientInfo.load() throws an exception
      when: AuthRepositoryImpl.restoreSession() is called
      then: Returns Left(UnexpectedFailure)

    - name: auth_usecase_saveSession_delegates_to_repository
      layer: domain
      given: AuthRepository is mocked
      when: SaveSessionUseCase.call(data, email, passwordHash) is called
      then: Delegates to AuthRepository.saveSession and returns the result
    - name: auth_usecase_saveSession_repository_failure_returns_Left
      layer: domain
      given: AuthRepository.saveSession returns Left(UnexpectedFailure)
      when: SaveSessionUseCase.call(data, email, passwordHash) is called
      then: Returns Left(UnexpectedFailure)
    - name: auth_usecase_clearSession_delegates_to_repository
      layer: domain
      given: AuthRepository is mocked
      when: ClearSessionUseCase.call() is called
      then: Delegates to AuthRepository.clearSession and returns the result
    - name: auth_usecase_clearSession_repository_failure_returns_Left
      layer: domain
      given: AuthRepository.clearSession returns Left(UnexpectedFailure)
      when: ClearSessionUseCase.call() is called
      then: Returns Left(UnexpectedFailure)
    - name: auth_usecase_restoreSession_valid_returns_Right
      layer: domain
      given: AuthRepository.restoreSession returns Right(LoginResponseEntity)
      when: RestoreSessionUseCase.call() is called
      then: Returns Right(LoginResponseEntity)
    - name: auth_usecase_restoreSession_no_session_returns_null
      layer: domain
      given: AuthRepository.restoreSession returns Right(null)
      when: RestoreSessionUseCase.call() is called
      then: Returns Right(null)
    - name: auth_usecase_restoreSession_failure_returns_Left
      layer: domain
      given: AuthRepository.restoreSession returns Left(UnexpectedFailure)
      when: RestoreSessionUseCase.call() is called
      then: Returns Left(UnexpectedFailure)

    - name: auth_notifier_login_success_sets_loaded_state
      layer: presentation
      given: LoginUseCase returns Right(LoginResponseEntity)
      when: AuthNotifier.login(email, password) is called
      then: State becomes AuthLoaded with the patient data, secure storage is written
    - name: auth_notifier_login_rememberMe_calls_saveSession
      layer: presentation
      given: LoginUseCase returns Right(LoginResponseEntity) and rememberMe is true
      when: AuthNotifier.login(email, password, rememberMe: true) is called
      then: SaveSessionUseCase.call() is called via repository
    - name: auth_notifier_login_rememberMe_and_saveSession_failure_sets_AuthFailure
      layer: presentation
      given: LoginUseCase returns Right(LoginResponseEntity) and saveSession returns Left(UnexpectedFailure)
      when: AuthNotifier.login(email, password, rememberMe: true) is called
      then: State becomes AuthFailure and navigation is blocked

    - name: auth_notifier_login_failure_sets_failure_state
      layer: presentation
      given: LoginUseCase returns Left(ApiFailure)
      when: AuthNotifier.login(email, password) is called
      then: State becomes AuthFailure with error message

    - name: auth_notifier_logout_success_clears_state
      layer: presentation
      given: ClearSessionUseCase returns Right(null)
      when: AuthNotifier.logout() is called
      then: State becomes AuthInitial, goRouterListenable.isAuthenticated becomes false
    - name: auth_notifier_logout_failure_sets_AuthFailure
      layer: presentation
      given: ClearSessionUseCase returns Left(UnexpectedFailure)
      when: AuthNotifier.logout() is called
      then: State becomes AuthFailure

    - name: auth_notifier_restoreSession_with_valid_session_sets_loaded
      layer: presentation
      given: RestoreSessionUseCase returns Right(LoginResponseEntity)
      when: AuthNotifier.restoreSession() is called
      then: State becomes AuthLoaded, goRouterListenable.isAuthenticated becomes true
    - name: auth_notifier_restoreSession_without_session_stays_initial
      layer: presentation
      given: RestoreSessionUseCase returns Right(null)
      when: AuthNotifier.restoreSession() is called
      then: State remains AuthInitial
    - name: auth_notifier_restoreSession_failure_sets_AuthFailure
      layer: presentation
      given: RestoreSessionUseCase returns Left(UnexpectedFailure)
      when: AuthNotifier.restoreSession() is called
      then: State becomes AuthFailure

  widget:
    - name: login_screen_shows_email_and_password_fields
      given: LoginScreen is rendered
      when: The screen loads
      then: Email TextField, password TextField, and login button are visible

    - name: login_screen_shows_remember_me_checkbox
      given: LoginScreen is rendered
      when: The screen loads
      then: "Remember me" checkbox is visible and unchecked by default

    - name: login_screen_shows_error_on_invalid_credentials
      given: LoginScreen is in AuthFailure state with error message
      when: The screen renders
      then: Error message is displayed

    - name: login_screen_shows_loading_indicator_during_login
      given: LoginScreen is in AuthLoading state
      when: The screen renders
      then: A CircularProgressIndicator is displayed

  integration:
    - name: auth_login_successful_flow
      scenario: Successful login with valid credentials
      fake_repositories:
        - IAuthRepository
      given: The app boots with a fake AuthRepository that returns a valid LoginResponseEntity
      when: The user enters valid email and password and taps login
      then: The app navigates to /clinical_history

    - name: auth_login_invalid_credentials_flow
      scenario: Login with invalid credentials
      fake_repositories:
        - IAuthRepository
      given: The app boots with a fake AuthRepository that returns Left(ApiFailure)
      when: The user enters invalid email or password and taps login
      then: The app shows "Invalid credentials" error on the login screen

    - name: auth_logout_flow
      scenario: Explicit logout
      fake_repositories:
        - IAuthRepository
      given: The app is on /clinical_history with a fake authenticated state
      when: The user taps the logout button
      then: The app navigates back to the login screen

    - name: auth_restore_session_valid
      scenario: App start with valid stored session
      fake_repositories:
        - IAuthRepository
      given: A valid session (fullname + token) exists in sembast and clinical history exists in sembast
      when: The app calls restoreSession
      then: The app navigates to /clinical_history without showing login

    - name: auth_restore_session_empty
      scenario: App start with no stored credentials
      fake_repositories:
        - IAuthRepository
      given: No session exists in sembast
      when: The app calls restoreSession
      then: The app stays on the login screen
