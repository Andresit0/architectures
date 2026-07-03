.
├── features
│   └── auth
│       ├── domain
│       │   ├── datasources
│       │   │   ├── i_auth_datasource.dart
│       │   │   └── i_local_auth_datasource.dart
│       │   ├── entities
│       │   │   ├── login_response_entity.dart
│       │   │   └── token_entity.dart
│       │   ├── repositories
│       │   │   └── i_auth_repository.dart
│       │   └── usecases
│       │       ├── clear_session_usecase.dart
│       │       ├── login_usecase.dart
│       │       ├── refresh_token_usecase.dart
│       │       ├── restore_session_usecase.dart
│       │       └── save_session_usecase.dart
│       ├── infrastructure
│       │   ├── datasources
│       │   │   ├── auth_datasource_impl.dart
│       │   │   └── local_auth_datasource_impl.dart
│       │   ├── mappers
│       │   │   └── auth_mapper.dart
│       │   └── repositories
│       │       └── auth_repository_impl.dart
│       ├── presentation
│       │   ├── notifiers
│       │   │   ├── auth_notifier.dart
│       │   │   └── auth_state.dart
│       │   ├── providers
│       │   │   └── auth_provider.dart
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
├── main.dart
└── shared
    ├── configs
    │   ├── _configs.dart
    │   ├── _configs.lib.dart
    │   ├── app_routes.dart
    │   ├── colors.dart
    │   ├── theme.dart
    │   ├── uries.dart
    │   └── vars.dart
    ├── models
    │   ├── _models.dart
    │   ├── _models.lib.dart
    │   ├── patient
    │   │   └── patient_entity.dart
    │   └── clinical_history
    │       ├── clinical_history_attachment_entity.dart
    │       ├── clinical_history_diagnosis_entity.dart
    │       ├── clinical_history_entity.dart
    │       ├── clinical_history_facility_entity.dart
    │       ├── clinical_history_professional_entity.dart
    │       ├── clinical_history_service_entity.dart
    │       └── clinical_history_state_entity.dart
    ├── database
    │   ├── _database.dart
    │   ├── _database.lib.dart
    │   ├── app_database.dart
    │   ├── database_encrypt.dart
    │   ├── secure_storage_key_service.dart
    │   └── tables
    │       ├── clinical_history.dart
    │       └── patient_info.dart
    ├── exceptions
    │   ├── _exceptions.dart
    │   ├── _exceptions.lib.dart
    │   ├── api_exception.dart
    │   ├── api_failure.dart
    │   ├── failure.dart
    │   ├── no_connection_exception.dart
    │   ├── no_connection_failure.dart
    │   ├── server_unreachable_exception.dart
    │   ├── server_unreachable_failure.dart
    │   ├── unexpected_failure.dart
    │   ├── unexpected_response_exception.dart
    │   └── unexpected_response_failure.dart
    ├── functions
    │   ├── _function.dart
    │   ├── _function.lib.dart
    │   ├── cp_crypto.dart
    │   ├── cp_dio.dart
    │   ├── cp_encrypt.dart
    │   ├── cp_flutter_secure_storage.dart
    │   ├── cp_fpdart.dart
    │   ├── cp_go_router.dart
    │   ├── cp_logger.dart
    │   ├── cp_path_provider.dart
    │   ├── cp_sembast.dart
    │   ├── cp_share_plus.dart
    │   ├── failure_propagation.dart
    │   ├── internet_service.dart
    │   ├── offline_first_repository.dart
    │   ├── server_reachability_strategy.dart
    │   └── token_service.dart
    ├── interceptors
    │   ├── _interceptors.dart
    │   ├── _interceptors.lib.dart
    │   └── auth_interceptor.dart
    ├── jsons
    │   ├── _jsons.dart
    │   ├── _jsons.lib.dart
    │   └── auth_json.dart
    ├── providers
    │   ├── _providers.dart
    │   ├── _providers.lib.dart
    │   ├── dio_provider.dart
    │   ├── go_router_notifier_provider.dart
    │   ├── sembast_provider.dart
    │   └── token_provider.dart
    └── widgets
        ├── _widgets.dart
        ├── _widgets.lib.dart
        └── loading_indicator.dart
