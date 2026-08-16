.
├── app
│   ├── app_initializer.dart
│   ├── widgets
│   │   ├── app_error_screen.dart ← 404 / navigation error (GoRouter.errorBuilder, error detail en debug, "go home" vía appNavigatorProvider)
│   │   ├── connectivity_banner.dart ← offline banner (Sin conexión), watches internetStatusProvider
│   │   └── device_security_blocked_screen.dart ← hard-stop en startup (jailbreak/root), sin navegación
│   ├── di
│   │   ├── auth
│   │   │   └── auth_observer_provider.dart ← authenticationObserverProvider (app-level)
│   │   ├── network
│   │   │   ├── auth_interceptor_impl.dart ← IAuthInterceptorProvider bridge → Handle401UseCase + onForceLogout + getToken
│   │   │   └── dio_overrides.dart ← dioOverrides(): binds authInterceptorProvider seam (merged in main.dart)
│   │   └── router
│   │       ├── go_router_navigator.dart ← GoRouterNavigator (única impl de IAppNavigator)
│   │       ├── router_overrides.dart ← routerOverrides(): binds appNavigatorProvider seam (merged in main.dart)
│   │       └── router_provider.dart ← goRouterProvider
│   └── router
│       ├── app_router.dart
│       └── guards
│           └── auth_guard.dart ← redirect con deep-link restore (?from=)
├── core
│   ├── config
│   │   ├── app_environment.dart
│   │   └── environment_provider.dart
│   ├── database
│   │   ├── app_database.dart
│   │   ├── app_database_provider.dart
│   │   ├── database_encrypt.dart   ← pure AES-256-CBC codec (no sembast types)
│   │   ├── i_app_database.dart     ← IAppDatabase + ISembastDb (sembast-typed infra abstraction)
│   │   ├── sembast_codec.dart      ← SembastCodec wrapper (public sembast API)
│   │   ├── secure_storage_key_service.dart
│   │   ├── sembast_db_wrapper.dart
│   │   ├── serializers
│   │   │   ├── clinical_history_serializer.dart
│   │   │   └── patient_serializer.dart
│   │   └── tables
│   │       ├── clinical_history.dart        ← ClinicalHistory impl (no providers — Rule 20)
│   │       ├── clinical_history_providers.dart ← clinicalHistoryStoreProvider
│   │       ├── patient_info.dart            ← PatientInfo impl (no providers — Rule 20)
│   │       └── patient_info_providers.dart  ← patientInfoStoreProvider
│   ├── network
│   │   ├── _network.lib.dart
│   │   ├── api_endpoints.dart
│   │   ├── connectivity
│   │   │   ├── connectivity_providers.dart ← internetServiceProvider, connectivityCheckerProvider
│   │   │   ├── i_internet_connection_checker_wrapper.dart
│   │   │   ├── internet_connection_checker_wrapper.dart
│   │   │   ├── internet_service.dart
│   │   │   └── server_reachability_strategy.dart
│   │   ├── contracts
│   │   │   ├── _contracts.lib.dart
│   │   │   ├── clinical_history_dto.dart (+ 6 sub-DTOs, .freezed/.g generated)
│   │   │   ├── clinical_history_list_response_dto.dart
│   │   │   ├── clinical_history_mapper.dart
│   │   │   └── patient_dto.dart (+ .freezed/.g) ← shared patient wire shape (auth login envelope)
│   │   ├── dio
│   │   │   ├── dio_multipart_builder.dart
│   │   │   ├── dio_providers.dart    ← authDioProvider, httpServiceProvider, authInterceptorProvider (seam)
│   │   │   ├── dio_response_parser.dart
│   │   │   ├── dio_wrapper.dart      ← IDioWrapper + DioWrapper
│   │   │   ├── http_response.dart
│   │   │   └── i_multipart_file.dart
│   │   ├── interceptors
│   │   │   ├── _interceptors.dart
│   │   │   ├── _interceptors.lib.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   └── i_auth_interceptor_provider.dart
│   │   ├── retry
│   │   │   ├── exponential_backoff.dart
│   │   │   └── retry_policy.dart
│   │   ├── security
│   │   │   └── certificate_pinner.dart
│   │   ├── timeouts
│   │   │   ├── _timeouts.lib.dart
│   │   │   ├── connection_profile.dart
│   │   │   └── endpoint_sla.dart
│   │   └── utils
│   │       └── uri_utils.dart
│   ├── router
│   │   └── app_navigator_provider.dart ← appNavigatorProvider (seam IAppNavigator, fail-fast; bind en routerOverrides)
│   └── services
│       ├── _services.lib.dart
│       ├── auth
│       │   ├── auth_observer.dart
│       │   ├── i_authentication_observer.dart
│       │   ├── jwt_token_expiry_checker.dart
│       │   ├── jwt_wrapper.dart
│       │   ├── secure_credential_store.dart
│       │   ├── secure_token_store.dart
│       │   └── token_providers.dart   ← tokenStoreProvider, credentialStoreProvider, tokenVerifierProvider, jwtWrapperProvider, secureStorageProvider
│       ├── crypto
│       │   ├── bcrypt_wrapper.dart
│       │   └── password_hasher_provider.dart
│       ├── device
│       │   ├── jailbreak_detection_wrapper.dart
│       │   ├── jailbreak_provider.dart
│       │   ├── path_provider_provider.dart
│       │   └── path_provider_wrapper.dart
│       ├── logging
│       │   ├── dev_logger.dart
│       │   └── logging_providers.dart   ← loggerProvider (observability seam)
│       └── storage
│           └── secure_storage_wrapper.dart
├── design_system
│   ├── _design.lib.dart
│   ├── components
│   │   ├── empty_state.dart
│   │   ├── error_state.dart
│   │   ├── info_chip.dart
│   │   ├── loading_indicator.dart
│   │   └── skeleton_list.dart
│   ├── theme
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils
│       └── app_formatters.dart        ← formatClinicalDate / formatBytes (intl, locale-aware)
├── features
│   ├── auth
│   │   ├── di
│   │   │   ├── auth_provider.dart    ← feature DI (imports core providers directly, NEVER app/)
│   │   │   └── auth_provider.g.dart
│   │   ├── domain
│   │   │   ├── datasources
│   │   │   │   ├── i_auth_remote_datasource.dart ← IAuthRemoteDatasource
│   │   │   │   └── i_local_auth_datasource.dart
│   │   │   ├── entities
│   │   │   │   ├── login_response_entity.dart
│   │   │   │   └── token_entity.dart
│   │   │   ├── repositories
│   │   │   │   ├── i_auth_repository.dart       ← remote contract (login, refreshToken)
│   │   │   │   └── i_local_auth_repository.dart ← local contract (saveSession, clearSession, resetAccount, restoreSession)
│   │   │   ├── services
│   │   │   │   └── (empty — shared helpers promoted to use cases)
│   │   │   ├── usecases
│   │   │   │   ├── clear_session_usecase.dart
│   │   │   │   ├── credential_login_usecase.dart ← stored-credentials re-login (shared by Handle401 + Restore)
│   │   │   │   ├── handle_401_usecase.dart
│   │   │   │   ├── login_usecase.dart
│   │   │   │   ├── refresh_token_usecase.dart
│   │   │   │   └── restore_session_usecase.dart
│   │   │   └── value_objects
│   │   │       ├── email.dart (+ .freezed)
│   │   │       ├── password.dart (+ .freezed)
│   │   │       └── password_hash.dart (+ .freezed)
│   │   ├── infrastructure
│   │   │   ├── datasources
│   │   │   │   ├── auth_datasource_impl.dart
│   │   │   │   └── local_auth_datasource_impl.dart ← dumb read (no policy)
│   │   │   ├── dtos
│   │   │   │   ├── _dtos.lib.dart
│   │   │   │   ├── login_response_dto.dart (+ .freezed/.g)
│   │   │   │   └── token_dto.dart (+ .freezed/.g)
│   │   │   ├── mappers
│   │   │   │   └── auth_mapper.dart
│   │   │   └── repositories
│   │   │       ├── auth_local_repository_impl.dart ← implements ILocalAuthRepository
│   │   │       └── auth_remote_repository_impl.dart ← implements IAuthRepository
│   │   ├── presentation
│   │   │   ├── notifiers
│   │   │   │   ├── auth_notifier.dart (+ .g)
│   │   │   │   ├── auth_state.dart (+ .freezed)
│   │   │   │   └── remember_me_provider.dart    ← UI state (remember-me checkbox)
│   │   │   ├── screens
│   │   │   │   └── login_screen.dart
│   │   │   └── widgets                     ← standalone files, explicit imports (no barrel)
│   │   │       ├── email_form_field.dart        ← delegates validation to Email VO
│   │   │       ├── login_button.dart
│   │   │       └── password_form_field.dart     ← delegates validation to Password VO
│   │   └── spec
│   │       ├── bdd.feature / contracts.md / domain.md / spec.md / tasks.md / tests.md
│   └── clinical_history
│       ├── di
│       │   ├── clinical_history_provider.dart    ← feature DI (imports core providers directly)
│       │   └── clinical_history_provider.g.dart
│       ├── domain
│       │   ├── datasources
│       │   │   ├── i_clinical_history_local_datasource.dart
│       │   │   └── i_clinical_history_remote_datasource.dart
│       │   ├── repositories
│       │   │   └── i_clinical_history_repository.dart
│       │   └── usecases
│       │       ├── load_clinical_histories_usecase.dart
│       │       └── refresh_clinical_histories_usecase.dart
│       ├── infrastructure
│       │   ├── datasources
│       │   │   ├── clinical_history_local_datasource_impl.dart
│       │   │   └── clinical_history_remote_datasource_impl.dart
│       │   └── repositories
│       │       └── clinical_history_repository_impl.dart
│       ├── presentation
│   │   ├── notifiers
│   │   │   ├── clinical_history_notifier.dart (+ .g)  ← provider: clinicalHistoryProvider (codegen)
│   │   │   ├── clinical_history_refresh_error_provider.dart (+ .g) ← refresh-error snackbar (UI-state)
│   │   │   └── clinical_history_state.dart (+ .freezed)
│       │   ├── screens
│       │   │   └── clinical_history_screen.dart
│       │   └── widgets                     ← standalone file, explicit imports (no barrel)
│       │       └── clinical_history_card.dart
│       └── spec
│           ├── bdd.feature / contracts.md / domain.md / spec.md / tasks.md / tests.md
│           └── generated_api_contract.md
├── l10n
│   ├── app_en.arb / app_es.arb
│   ├── app_localizations*.dart (generated)
│   └── error_localizer.dart   ← localizeError() (UI layer, NOT in shared/)
├── main.dart
└── shared
    ├── error
    │   ├── _error.lib.dart   ← domain-safe barrel (NO error_localizer)
    │   ├── app_error.dart
    │   ├── result.dart
    │   ├── result_guard.dart
    │   └── retry_result.dart
    ├── exceptions
    │   ├── _exceptions.lib.dart
    │   └── api / device_security / no_connection / server_unreachable / app_timeout / unexpected_response
    ├── functions
    │   └── online_first.dart
    ├── interfaces
    │   ├── _interfaces.lib.dart
    │   ├── i_app_navigator.dart          ← IAppNavigator (seam de navegación tipado, sin go_router)
    │   ├── i_clinical_history_store.dart
    │   ├── i_connectivity_checker.dart
    │   ├── i_credential_store.dart
    │   ├── i_logger.dart                 ← ILogger (seam de observabilidad — port de dominio)
    │   ├── i_password_hasher.dart
    │   ├── i_patient_info_store.dart
    │   ├── i_token_store.dart
    │   ├── i_token_verifier.dart
    │   └── i_usecase.dart               ← IUseCase<In,Out> + NoParams (contrato uniforme de usecases)
    ├── models                    ← Shared Kernel (DDD): domain models shared by ≥2 bounded contexts (features + core/database); no single feature owns them
    │   ├── _models.lib.dart
    │   ├── clinical_history/ (ClinicalHistoryEntity + 6 sub-entities + ClinicalHistoryStatus enum, freezed)
    │   └── patient/patient_entity.dart
    └── router
        └── app_route.dart               ← AppRoute (registro tipado de rutas, Shared Kernel, pure Dart)
