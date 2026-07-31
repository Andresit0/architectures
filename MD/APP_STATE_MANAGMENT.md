### State management

Riverpod v3. Use `@riverpod` (code-gen) for feature providers and manual `Provider<...>` for global/utility providers. Run `build_runner` after changing `@riverpod`-annotated files.

#### Global shared providers (exported via `_providers.lib.dart` barrel)

Global `keepAlive` providers are defined in `lib/core/` and `lib/app/di/`, exported via `_providers.lib.dart` in `lib/app/di/` (the composition root barrel).

| Provider | Type | Location |
|---|---|---|
| `httpServiceProvider` | `Provider<IDioWrapper>` | `app/di/network/dio_provider.dart` |
| `tokenStoreProvider` | `Provider<ITokenStore>` | `core/services/auth/token_providers.dart` |
| `appDatabaseProvider` | `Provider<IAppDatabase>` | `core/database/app_database_provider.dart` |
| `internetServiceProvider` | `Provider<IInternetService>` | `core/network/connectivity/connectivity_providers.dart` |
| *(removed)* `errorPropagation` | *(removed)* | Replaced by `localizeError()` in `shared/error/error_localizer.dart` |
| `clinicalHistoryStoreProvider` | `Provider<IClinicalHistoryStore>` | `core/database/tables/clinical_history.dart` |
| `patientInfoStoreProvider` | `Provider<IPatientInfoStore>` | `core/database/tables/patient_info.dart` |
| `passwordHasherProvider` | `Provider<IPasswordHasher>` | `core/services/crypto/password_hasher_provider.dart` |
| `connectivityCheckerProvider` | `Provider<IConnectivityChecker>` | `core/network/connectivity/connectivity_providers.dart` |
| `tokenVerifierProvider` | `Provider<ITokenVerifier>` | `core/services/auth/token_providers.dart` |
| `credentialStoreProvider` | `Provider<ICredentialStore>` | `core/services/auth/token_providers.dart` |
| `jwtWrapperProvider` | `Provider<IJwtWrapper>` | `core/services/auth/token_providers.dart` |
| `environmentProvider` | `Provider<AppEnvironment>` | `core/config/environment_provider.dart` |

- Feature code accesses providers by their direct name (e.g. `ref.watch(httpServiceProvider)`), imported from `_providers.lib.dart`.

#### ref.watch / ref.read / ref.listen — quick rule

| Method | Use when |
|---|---|
| `ref.watch` | Inside a functional provider body or widget/Notifier `build()` that needs to rebuild on change |
| `ref.read` | Inside callbacks, `initState`, or Notifier methods (one-shot actions, no reactivity needed) |
| `ref.listen` | Inside a Notifier `build()` to react to another provider without rebuilding the notifier |

> See **MD/APP_PROVIDERS.md** for the full inventory, canonical examples and access rules.