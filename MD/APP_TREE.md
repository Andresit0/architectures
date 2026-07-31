.
├── app
│   ├── app_initializer.dart
│   ├── di
│   │   ├── _providers.lib.dart    ← composition root barrel (11 exports)
│   │   ├── auth
│   │   │   └── auth_provider.dart
│   │   ├── error_localizer_factory.dart
│   │   ├── network
│   │   │   ├── auth_interceptor_impl.dart
│   │   │   └── dio_provider.dart
│   │   └── router
│   │       └── router_provider.dart
│   └── router
│       ├── app_route.dart
│       ├── app_router.dart
│       └── guards
│           └── auth_guard.dart
├── core
│   ├── config
│   │   ├── app_environment.dart
│   │   └── environment_provider.dart
│   ├── database
│   │   ├── _database.lib.dart
│   │   ├── app_database.dart
│   │   ├── app_database_provider.dart
│   │   ├── database_encrypt.dart
│   │   ├── secure_storage_key_service.dart
│   │   ├── sembast_db_wrapper.dart
│   │   ├── serializers
│   │   │   ├── clinical_history_serializer.dart
│   │   │   └── patient_serializer.dart
│   │   └── tables
│   │       ├── clinical_history.dart
│   │       └── patient_info.dart
│   ├── network
│   │   ├── _network.lib.dart
│   │   ├── api_endpoints.dart
│   │   ├── connectivity
│   │   │   ├── connectivity_providers.dart
│   │   │   ├── i_internet_connection_checker.dart
│   │   │   ├── internet_connection_checker_impl.dart
│   │   │   ├── internet_service.dart
│   │   │   └── server_reachability_strategy.dart
│   │   ├── dio
│   │   │   ├── dio_multipart_builder.dart
│   │   │   ├── dio_providers.dart
│   │   │   ├── dio_response_parser.dart
│   │   │   ├── dio_wrapper.dart
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
│   ├── services
│   │   ├── _services.lib.dart
│   │   ├── auth
│   │   │   ├── auth_observer.dart
│   │   │   ├── i_credential_store.dart
│   │   │   ├── i_token_verifier.dart
│   │   │   ├── jwt_token_expiry_checker.dart
│   │   │   ├── jwt_wrapper.dart
│   │   │   ├── secure_credential_store.dart
│   │   │   ├── secure_token_store.dart
│   │   │   └── token_providers.dart
│   │   ├── crypto
│   │   │   ├── bcrypt_wrapper.dart
│   │   │   ├── i_password_hasher.dart
│   │   │   └── password_hasher_provider.dart
│   │   ├── device
│   │   │   ├── jailbreak_detection_wrapper.dart
│   │   │   ├── jailbreak_provider.dart
│   │   │   ├── path_provider_provider.dart
│   │   │   └── path_provider_wrapper.dart
│   │   └── storage
│   │       ├── secure_storage_wrapper.dart

├── design_system
│   ├── _design.lib.dart
│   ├── components
│   │   └── loading_indicator.dart
│   └── theme
│       ├── app_colors.dart
│       └── app_theme.dart
├── features
│   └── auth
│       ├── di
│       │   ├── auth_provider.dart
│       │   ├── auth_provider.g.dart
│       │   └── remember_me_provider.dart
│       ├── domain
│       │   ├── datasources
│       │   │   ├── i_auth_datasource.dart
│       │   │   └── i_local_auth_datasource.dart
│       │   ├── entities
│       │   │   ├── login_response_entity.dart
│       │   │   ├── login_response_entity.freezed.dart
│       │   │   ├── token_entity.dart
│       │   │   └── token_entity.freezed.dart
│       │   ├── repositories
│       │   │   └── i_auth_repository.dart
│       │   ├── services
│       │   │   ├── i_token_retry_service.dart
│       │   │   └── session_restoration_service.dart
│       │   ├── usecases
│       │   │   ├── clear_session_usecase.dart
│       │   │   ├── handle_401_usecase.dart
│       │   │   ├── login_usecase.dart
│       │   │   ├── refresh_token_usecase.dart
│       │   │   └── restore_session_usecase.dart
│       │   └── value_objects
│       │       ├── email.dart
│       │       ├── email.freezed.dart
│       │       ├── password.dart
│       │       ├── password.freezed.dart
│       │       ├── password_hash.dart
│       │       └── password_hash.freezed.dart
│       ├── infrastructure
│       │   ├── datasources
│       │   │   ├── auth_datasource_impl.dart
│       │   │   └── local_auth_datasource_impl.dart
│       │   ├── dtos
│       │   │   ├── _dtos.lib.dart
│       │   │   ├── clinical_history_attachment_dto.dart
│       │   │   ├── clinical_history_attachment_dto.freezed.dart
│       │   │   ├── clinical_history_attachment_dto.g.dart
│       │   │   ├── clinical_history_diagnosis_dto.dart
│       │   │   ├── clinical_history_diagnosis_dto.freezed.dart
│       │   │   ├── clinical_history_diagnosis_dto.g.dart
│       │   │   ├── clinical_history_dto.dart
│       │   │   ├── clinical_history_dto.freezed.dart
│       │   │   ├── clinical_history_dto.g.dart
│       │   │   ├── clinical_history_facility_dto.dart
│       │   │   ├── clinical_history_facility_dto.freezed.dart
│       │   │   ├── clinical_history_facility_dto.g.dart
│       │   │   ├── clinical_history_professional_dto.dart
│       │   │   ├── clinical_history_professional_dto.freezed.dart
│       │   │   ├── clinical_history_professional_dto.g.dart
│       │   │   ├── clinical_history_service_dto.dart
│       │   │   ├── clinical_history_service_dto.freezed.dart
│       │   │   ├── clinical_history_service_dto.g.dart
│       │   │   ├── clinical_history_state_dto.dart
│       │   │   ├── clinical_history_state_dto.freezed.dart
│       │   │   ├── clinical_history_state_dto.g.dart
│       │   │   ├── login_response_dto.dart
│       │   │   ├── login_response_dto.freezed.dart
│       │   │   ├── login_response_dto.g.dart
│       │   │   ├── patient_dto.dart
│       │   │   ├── patient_dto.freezed.dart
│       │   │   ├── patient_dto.g.dart
│       │   │   ├── token_dto.dart
│       │   │   ├── token_dto.freezed.dart
│       │   │   └── token_dto.g.dart
│       │   ├── mappers
│       │   │   ├── _mappers.lib.dart
│       │   │   └── auth_mapper.dart
│       │   ├── repositories
│       │   │   └── auth_repository_impl.dart
│       │   └── services
│       │       ├── dio_token_retry_service.dart
│       │       └── session_restoration_service_impl.dart
│       ├── presentation
│       │   ├── notifiers
│       │   │   ├── auth_notifier.dart
│       │   │   ├── auth_notifier.g.dart
│       │   │   ├── auth_state.dart
│       │   │   └── auth_state.freezed.dart
│       │   ├── screens
│       │   │   ├── clinical_history_placeholder_screen.dart
│       │   │   └── login_screen.dart
│       │   └── widgets
│       │       ├── _widgets.dart
│       │       ├── _widgets.lib.dart
│       │       ├── email_form_field.dart
│       │       ├── login_button.dart
│       │       └── password_form_field.dart
│       └── spec
│           ├── bdd.feature
│           ├── contracts.md
│           ├── domain.md
│           ├── spec.md
│           ├── tasks.md
│           └── tests.md
├── l10n
│   ├── app_en.arb
│   ├── app_es.arb
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_es.dart
├── main.dart
└── shared
    ├── error
    │   ├── _error.lib.dart
    │   ├── app_error.dart
    │   ├── error_localizer.dart
    │   ├── result.dart
    │   ├── result_guard.dart
    │   └── retry_result.dart
    ├── exceptions
    │   ├── _exceptions.lib.dart
    │   ├── api_exception.dart
    │   ├── device_security_exception.dart
    │   ├── no_connection_exception.dart
    │   ├── server_unreachable_exception.dart
    │   ├── timeout_exception.dart
    │   └── unexpected_response_exception.dart
    ├── functions
    │   └── offline_first_repository.dart
    ├── interfaces
    │   ├── _interfaces.lib.dart
    │   ├── i_app_database.dart
    │   ├── i_authentication_observer.dart
    │   ├── i_connectivity_checker.dart
    │   ├── i_credential_store.dart
    │   ├── i_password_hasher.dart
    │   ├── i_token_store.dart
    │   └── i_token_verifier.dart
    ├── models
    │   ├── _models.lib.dart
    │   ├── clinical_history
    │   │   ├── clinical_history_attachment_entity.dart
    │   │   ├── clinical_history_attachment_entity.freezed.dart
    │   │   ├── clinical_history_diagnosis_entity.dart
    │   │   ├── clinical_history_diagnosis_entity.freezed.dart
    │   │   ├── clinical_history_entity.dart
    │   │   ├── clinical_history_entity.freezed.dart
    │   │   ├── clinical_history_facility_entity.dart
    │   │   ├── clinical_history_facility_entity.freezed.dart
    │   │   ├── clinical_history_professional_entity.dart
    │   │   ├── clinical_history_professional_entity.freezed.dart
    │   │   ├── clinical_history_service_entity.dart
    │   │   ├── clinical_history_service_entity.freezed.dart
    │   │   ├── clinical_history_state_entity.dart
    │   │   └── clinical_history_state_entity.freezed.dart
    │   └── patient
    │       ├── patient_entity.dart
    │       └── patient_entity.freezed.dart

