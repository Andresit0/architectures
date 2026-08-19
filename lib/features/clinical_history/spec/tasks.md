## Clinical History — Implementation Tasks

### Domain
- [ ] Create lib/features/clinical_history/domain/datasources/i_clinical_history_remote_datasource.dart
      (IClinicalHistoryRemoteDatasource: loadRemote only — no Result, no core imports)
- [ ] Create lib/features/clinical_history/domain/datasources/i_clinical_history_local_datasource.dart
      (IClinicalHistoryLocalDatasource: loadLocal, storeLocal — no Result, no core imports)
- [ ] Create lib/features/clinical_history/domain/repositories/i_clinical_history_repository.dart
      (IClinicalHistoryRepository: loadClinicalHistories, refreshClinicalHistories returning Future<Result<List<ClinicalHistoryEntity>>>)
- [ ] Create lib/features/clinical_history/domain/usecases/load_clinical_histories_usecase.dart
      (LoadClinicalHistoriesUseCase.call() -> repository.loadClinicalHistories())
- [ ] Create lib/features/clinical_history/domain/usecases/refresh_clinical_histories_usecase.dart
      (RefreshClinicalHistoriesUseCase.call() -> repository.refreshClinicalHistories())
- [ ] NO new entities — reuse lib/shared/models/_models.lib.dart (ClinicalHistoryEntity + 6 sub-entities)

### Infrastructure
- [ ] Create lib/features/clinical_history/infrastructure/datasources/clinical_history_remote_datasource_impl.dart
      (ClinicalHistoryRemoteDatasourceImpl implements IClinicalHistoryRemoteDatasource; takes IDioWrapper)
      - loadRemote(): IDioWrapper.get(AppUries().clinicalHistory, sla: EndpointSla.standard) -> ClinicalHistoryListResponseDto.fromJson -> ClinicalHistoryMapper.fromDtoList
      - Never import raw dio; remote datasource uses httpServiceProvider (Bearer + 401 handled by AuthInterceptor)
- [ ] Create lib/features/clinical_history/infrastructure/datasources/clinical_history_local_datasource_impl.dart
      (ClinicalHistoryLocalDatasourceImpl implements IClinicalHistoryLocalDatasource; takes IClinicalHistoryStore)
      - loadLocal(): adapter over IClinicalHistoryStore.loadAll()
      - storeLocal(): adapter over IClinicalHistoryStore.storeAll()
- [ ] Create lib/features/clinical_history/infrastructure/repositories/clinical_history_repository_impl.dart
      (ClinicalHistoryRepositoryImpl implements IClinicalHistoryRepository; takes IClinicalHistoryRemoteDatasource + IClinicalHistoryLocalDatasource)
      - loadClinicalHistories(): fetchOrFallback(remote: loadRemote (raw tear-off), local: loadLocal (raw; null cuando cache vacía), onRemoteSuccess: _storeCache('load')) — el helper guarda las 3 fronteras; _storeCache es best-effort (try/catch Exception + log con stackTrace)
      - refreshClinicalHistories(): guard(() async { final list = await _ds.loadRemote(); await _storeCache('refresh'); return list; })
      - Errors via guard() from shared/error/result_guard.dart; telemetría de DataOrigin via ILogger inyectado

### Presentation
- [ ] Create lib/features/clinical_history/presentation/notifiers/clinical_history_state.dart
      (sealed @freezed ClinicalHistoryState: ClinicalHistoryInitial / ClinicalHistoryLoading / ClinicalHistoryLoaded(List<ClinicalHistoryEntity>) / ClinicalHistoryFailure(AppError); NO ._() constructor)
- [ ] Create lib/features/clinical_history/presentation/notifiers/clinical_history_notifier.dart
      (@riverpod class ClinicalHistoryNotifier; build() -> initial; load() uses ref.read(loadClinicalHistoriesUseCaseProvider).call() + fold; refresh() uses ref.read(refreshClinicalHistoriesUseCaseProvider).call() + fold; reset())
- [ ] Create lib/features/clinical_history/di/clinical_history_provider.dart
      (@riverpod chain: _clinicalHistoryRemoteDatasourceProvider(httpServiceProvider + appUriesProvider) + _clinicalHistoryLocalDatasourceProvider(clinicalHistoryStoreProvider) -> clinicalHistoryRepositoryProvider -> loadClinicalHistoriesUseCaseProvider + refreshClinicalHistoriesUseCaseProvider -> clinicalHistoryProvider)
- [ ] Create lib/features/clinical_history/presentation/screens/clinical_history_screen.dart
      (ConsumerWidget; AppBar title l10n clinicalHistory + logout button via onLogout callback — NEVER import features/auth; body switch on state: loading -> SkeletonList (design_system); loaded -> header count (l10n clinicalHistoryCount) + RefreshIndicator + ListView of M3 cards; empty -> EmptyState (l10n clinicalHistoryEmpty + retry); error -> ErrorState (localizeError + retry) + floating snackbar via ref.listen; failure does NOT reset)
      (Screen triggers load() when state is ClinicalHistoryInitial — first build only; no reload loop on failure)
- [ ] Create lib/features/clinical_history/presentation/widgets/clinical_history_card.dart
      (M3 Card.outlined, tap to expand/collapse with AnimatedSize + AnimatedRotation chevron; header shows avatar by service.category, service.name, facility.name + facility.city, formatted encounterDate (formatClinicalDate), state InfoChip (color by code); expanded sections with l10n clinicalHistoryDetails* labels: professional fullname/specialty, summary, description, diagnosis code/name, observations bullets, attachments icon + name + type + size (formatBytes))
- [ ] Run app-barrel skill for new folders (domain, infrastructure, presentation) after files exist

### Navigation (Phase D.10b — NOT this phase)
- [ ] Rewire AppRoute.clinicalHistory in lib/app/router/app_router.dart to ClinicalHistoryScreen (replace ClinicalHistoryPlaceholderScreen import from features/auth)
- [ ] Pass onLogout callback when constructing ClinicalHistoryScreen (logout stays in the caller/route — feature does not import auth)

### Shared dependencies / core changes
- [ ] Add Uri get clinicalHistory to lib/core/network/api_endpoints.dart (path: /user/clinical-history)
- [ ] Reuse clinicalHistoryStoreProvider (IClinicalHistoryStore) — lib/core/database/tables/clinical_history_providers.dart
- [ ] Reuse httpServiceProvider (IDioWrapper, Bearer + AuthInterceptor) — NOT authDioProvider
- [ ] Reuse lib/core/network/contracts/_contracts.lib.dart (ClinicalHistoryListResponseDto + ClinicalHistoryMapper) — no new DTOs
- [ ] Reuse shared/error/_error.lib.dart (guard, Result, fold, AppError) + shared/functions/online_first.dart (fetchOrFallback, online-first: remote first, cache fallback only on connectivity failure; helper owns boundary guarding)
- [ ] Reuse lib/design_system/_design.lib.dart — LoadingIndicator, SkeletonList, EmptyState, ErrorState, InfoChip + utils/app_formatters.dart (formatClinicalDate / formatBytes via intl)
- [ ] l10n: add clinicalHistoryEmpty + clinicalHistoryRetry + clinicalHistoryCount (plural ICU) + clinicalHistoryDetails* labels to lib/l10n/app_en.arb + app_es.arb; run gen-l10n to regenerate lib/l10n/app_localizations*.dart

### Tests
- [ ] Unit tests per tests.md (datasource, repository, usecases, notifier, state)
- [ ] Widget tests per tests.md (loading, list, expand/collapse, empty state, failure snackbar, refresh indicator, appbar)
- [ ] BDD: test/bdd/clinical_history_bdd_test.dart — 6 scenarios from bdd.feature via gherkart (incl. "Pull to refresh offline keeps the cached list")
- [ ] Integration: integration_test/clinical_history_integration_test.dart — 6 scenarios (fake IClinicalHistoryRepository)

### UI/UX polish — 10/10 iteration (M1/M2/M3)
- [ ] Create presentation/notifiers/clinical_history_refresh_error_provider.dart (Notifier<AppError?>, mirror of remember_me_provider)
- [ ] refresh() in ClinicalHistoryNotifier: failure from Loaded keeps the list and emits to clinicalHistoryRefreshErrorProvider; failure without a list → Failure
- [ ] Screen: ref.listen on clinicalHistoryRefreshErrorProvider → localized floating snackbar (body unchanged)
- [ ] Create shared/models/clinical_history/clinical_history_status.dart (enum ready/pending/closed/unknown + fromCode) + `status` getter on ClinicalHistoryStateEntity + export in _models.lib.dart
- [ ] Card: color the state InfoChip from ClinicalHistoryStatus (no magic strings)
- [ ] Card golden test (collapsed + expanded) — test/features/clinical_history/presentation/widgets/
