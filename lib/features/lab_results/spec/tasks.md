## Lab Results — Implementation Tasks

### Shared Kernel (core, done BEFORE feature tests)
- [ ] Create lib/shared/models/lab_results/lab_result_kind.dart (enum numeric/text + fromCode fallback to text)
- [ ] Create lib/shared/models/lab_results/lab_result_status.dart (enum normal/high/low/unknown + deriveLabResultStatus(double?, LabResultReferenceRangeEntity?))
- [ ] Create lib/shared/models/lab_results/lab_result_reference_range_entity.dart (@freezed: low, high)
- [ ] Create lib/shared/models/lab_results/lab_result_value_entity.dart (@freezed: date, value double?, textValue String?)
- [ ] Create lib/shared/models/lab_results/lab_result_entity.dart (@freezed: id, testCode, testName, category, unit?, kind, referenceRange?, values; `status` getter from LATEST value)
- [ ] Export all five in lib/shared/models/_models.lib.dart (Rule: shared/models imported only via the barrel)
- [ ] Create lib/shared/interfaces/i_lab_results_store.dart (ISP split: ILabResultsReader.loadAll, ILabResultsWriter.storeAll/deleteAll, ILabResultsStore implements both) + export in lib/shared/interfaces/_interfaces.lib.dart

### Core database
- [ ] Create lib/core/database/serializers/lab_results_serializer.dart (LabResultsSerializer.toMap/fromMap; round-trip guarded by test)
- [ ] Create lib/core/database/tables/lab_results.dart (LabResults implements ILabResultsStore; StoreRef 'lab_results'; storeAll replaces all, loadAll maps all, deleteAll clears)
- [ ] Create lib/core/database/tables/lab_results_providers.dart (labResultsStoreProvider = Provider<ILabResultsStore>, wiring appDatabaseProvider like clinical_history_providers.dart)
- [ ] Cache lifecycle: NO clear on logout; wiped only by ResetAccountUseCase (resetDatabase) — verify nothing in auth touches the lab_results store

### Chart wrapper seam (Phase D.0.6 — wrapper TDD before feature tests)
- [ ] Run Package Audit: detect missing fl_chart wrapper → app-cp-package flow (test RED → lib/core/services/charts/fl_chart_wrapper.dart GREEN)
- [ ] Create lib/core/services/charts/fl_chart_wrapper.dart (ITrendChart seam: renders line chart with reference-range band + legible axes; API captured in generated_api_contract.md)
- [ ] Create lib/core/services/charts/charts_providers.dart (trendChartProvider = Provider<ITrendChart>)
- [ ] Add lib/core/services/charts/ to _services.lib.dart barrel as needed
- [ ] Add 'package:fl_chart' to Rule 6 allow-list in test/architecture/dependency_rules_test.dart

### Web/CORS fix (conditional, required for dev server on web)
- [ ] lib/core/network/dio_wrapper.dart: map browser unknown / failed-fetch errors to NoConnectionException (conditional, only when platform is web)

### Domain
- [ ] Create lib/features/lab_results/domain/datasources/i_lab_results_remote_datasource.dart (ILabResultsRemoteDatasource: loadRemote — no Result, no core imports)
- [ ] Create lib/features/lab_results/domain/datasources/i_lab_results_local_datasource.dart (ILabResultsLocalDatasource: loadLocal, storeLocal — no Result, no core imports)
- [ ] Create lib/features/lab_results/domain/repositories/i_lab_results_repository.dart (loadLabResults, refreshLabResults → Future<Result<List<LabResultEntity>>>)
- [ ] Create lib/features/lab_results/domain/usecases/load_lab_results_usecase.dart (delegates to repository.loadLabResults())
- [ ] Create lib/features/lab_results/domain/usecases/refresh_lab_results_usecase.dart (delegates to repository.refreshLabResults())
- [ ] Create lib/features/lab_results/domain/value_objects/period.dart (Period enum: threeMonths/sixMonths/oneYear/all + duration + co-located pure function filterByPeriod(List<LabResultValueEntity>, Period) — relative to most recent data date; all/null → unchanged; NO labelKey — UI localizes via l10n)
- [ ] NO new entities in the feature — reuse lib/shared/models/_models.lib.dart (LabResultEntity + sub-entities)

### Infrastructure
- [ ] Create lib/features/lab_results/infrastructure/dtos/lab_result_dto.dart (+ sub-DTOs + lab_results_list_response_dto.dart) — feature-private, hand-written DTOs (manual fromJson/toJson, no codegen)
- [ ] Create lib/features/lab_results/infrastructure/dtos/lab_results_mapper.dart (LabResultsMapper.fromDtoList; enforces exactly one of value/textValue per kind)
- [ ] Create lib/features/lab_results/infrastructure/datasources/lab_results_remote_datasource_impl.dart
      (LabResultsRemoteDatasourceImpl implements ILabResultsRemoteDatasource; takes IDioWrapper + AppUries)
      - loadRemote(): IDioWrapper.get(AppUries().labResults, sla: EndpointSla.standard) → LabResultsListResponseDto.fromJson → LabResultsMapper.fromDtoList
      - Never import raw dio; Bearer + 401 handled by AuthInterceptor on httpServiceProvider
- [ ] Create lib/features/lab_results/infrastructure/datasources/lab_results_local_datasource_impl.dart
      (LabResultsLocalDatasourceImpl implements ILabResultsLocalDatasource; takes ILabResultsStore)
      - loadLocal() → store.loadAll(); storeLocal() → store.storeAll()
- [ ] Create lib/features/lab_results/infrastructure/repositories/lab_results_repository_impl.dart
      (LabResultsRepositoryImpl implements ILabResultsRepository; takes IRemote + ILocal)
      - loadLabResults(): fetchOrFallback(remote, local (raw; null when cache empty), onRemoteSuccess: _storeCache('load')) — helper owns boundary guarding; _storeCache best-effort (try/catch Exception + ILogger stackTrace)
      - refreshLabResults(): guard(() async { remote; await _storeCache('refresh'); return list; }) — NO cache fallback
      - Errors via guard() from shared/error/result_guard.dart

### Presentation
- [ ] Create lib/features/lab_results/presentation/notifiers/lab_results_state.dart
      (sealed @freezed LabResultsState: Initial / Loading / Loaded(results, selectedTestId, period) / Failure(AppError); NO ._() constructor)
- [ ] Create lib/features/lab_results/presentation/notifiers/lab_results_refresh_error_provider.dart (Notifier<AppError?>, mirror of clinicalHistoryRefreshErrorProvider)
- [ ] Create lib/features/lab_results/presentation/notifiers/lab_results_notifier.dart
      (@riverpod class LabResultsNotifier; build() → Initial; load()/refresh() via usecase + fold; selectTest(id)/setPeriod(p) mutate Loaded without reload; re-validate selectedTestId after load/refresh; refresh failure from Loaded keeps results + emits refresh error)
- [ ] Create lib/features/lab_results/di/lab_results_provider.dart
      (@riverpod chain: _remoteDatasource(httpServiceProvider + appUriesProvider) + _localDatasource(labResultsStoreProvider) → labResultsRepositoryProvider → load/refresh usecase providers → labResultsProvider)
      (Re-export trendChartProvider; re-export appNavigatorProvider only if the feature navigates imperatively — expected NOT needed)
- [ ] Create lib/features/lab_results/presentation/utils/lab_value_formatter.dart (or extend design_system/app_formatters.dart with formatLabValue: up to 2 decimals, no trailing zeros)
- [ ] Create lib/features/lab_results/presentation/widgets/lab_results_test_selector.dart (chips/segmented list of NUMERIC tests only; hidden when no numeric tests)
- [ ] Create lib/features/lab_results/presentation/widgets/lab_results_period_filter.dart (3 months / 6 months / 1 year / All; hidden when all results non-numeric)
- [ ] Create lib/features/lab_results/presentation/widgets/lab_results_card.dart (M3 card: test name, latest UNFILTERED value + unit, status chip for numeric; latest text value + NO chip for non-numeric)
- [ ] Create lib/features/lab_results/presentation/mappers/lab_result_chart_mapper.dart (Entity → TrendChartData: points/xLabels/reference band/tooltips; formatDate/statusLabel/referenceRangeLabel callbacks — no l10n leak; presentation-layer mapper, espejo de infrastructure/mappers en la frontera UI)
- [ ] Create lib/features/lab_results/presentation/widgets/lab_results_chart_pane.dart (ITrendChart via trendChartProvider; delegates data building to LabResultChartMapper; filtered points + reference-range band; tooltip on touch → date, value+unit, range, status)
- [ ] Create lib/features/lab_results/presentation/widgets/lab_results_non_numeric_list.dart (flat list of all non-numeric tests, each showing its latest text value — period-independent; no filterByPeriod)
- [ ] Create lib/features/lab_results/presentation/screens/lab_results_screen.dart
      (ConsumerWidget; AppBar title l10n labResults; body switch: Loading → SkeletonList; Loaded → selector + period filter + chart pane + cards + RefreshIndicator + non-numeric section; empty → EmptyState (icon + labResultsEmpty + retry); Failure → ErrorState + floating snackbar via ref.listen; refresh failure keeps results + snackbar; initial triggers load() once)
- [ ] Run app-barrel skill for new folders (domain, infrastructure, presentation, dtos) after files exist

### Navigation (Phase D.10 — app-agent-nav-wirer)
- [ ] Add AppRoute.labResults(path: '/clinical-history/lab-results', name: 'lab-results') to lib/shared/router/app_route.dart
- [ ] Add nested GoRoute under AppRoute.clinicalHistory in lib/app/router/app_router.dart → LabResultsScreen (route is behind AuthGuard via the parent)
- [ ] Add "Lab Results" AppBar action to lib/features/clinical_history/presentation/screens/clinical_history_screen.dart that navigates via the IAppNavigator seam (ref.read(appNavigatorProvider).go(AppRoute.labResults)) — clinical_history re-exports appNavigatorProvider in its di/
- [ ] Existing-test impact (accepted): flatten nested routes in test/app/router/app_router_test.dart; add lab-results deep-link case to test/app/router/go_router_deep_link_test.dart; regenerate clinical_history golden (AppBar gains the new action)

### Shared dependencies / core changes
- [ ] Add Uri get labResults to lib/core/network/api_endpoints.dart + IEndpointConfig (path: /user/clinical-history/lab-results)
- [ ] Reuse labResultsStoreProvider (ILabResultsStore) — lib/core/database/tables/lab_results_providers.dart
- [ ] Reuse httpServiceProvider (IDioWrapper, Bearer + AuthInterceptor) — NOT authDioProvider
- [ ] Reuse shared/error/_error.lib.dart (guard, Result, fold, AppError) + shared/functions/online_first.dart (fetchOrFallback, online-first)
- [ ] Reuse lib/design_system/_design.lib.dart — LoadingIndicator, SkeletonList, EmptyState, ErrorState, InfoChip
- [ ] Reuse trendChartProvider (ITrendChart seam) via feature di re-export — NEVER package:fl_chart in feature code
- [ ] l10n: add labResults + labResultsEmpty + labResultsPeriod* + labResultsStatus* + labResultsChartTitle + labResultsOtherTests + labResultsSelectTest (+ optional keys) to lib/l10n/app_en.arb + app_es.arb; run gen-l10n to regenerate lib/l10n/app_localizations*.dart

### Tests
- [ ] Core: test/core/database/lab_results_serializer_test.dart (round-trip guard)
- [ ] Unit tests per tests.md (remote/local datasources, repository load/refresh, usecases, notifier, state, value objects filterByPeriod, deriveLabResultStatus, status getter)
- [ ] Widget tests per tests.md (loading, loaded, selector, chart pane with mocked ITrendChart, period filter, all-non-numeric, empty, failure snackbar, refresh indicator, cards, formatter)
- [ ] Golden tests per tests.md @ Phase D.8.5: lab_results_screen_loading/loaded/empty + committed fixtures in test/features/lab_results/presentation/screens/goldens/ + `flutter test --tags golden` (ITrendChart faked, never real fl_chart)
- [ ] BDD: test/bdd/lab_results_bdd_test.dart — 6 scenarios from bdd.feature via gherkart
- [ ] Integration: integration_test/lab_results_integration_test.dart — 6 scenarios (fake ILabResultsRepository), executed on device (deferral NOT accepted, D.10.6)

### UI/UX polish (10/10 iteration)
- [ ] Screen: ref.listen on labResultsRefreshErrorProvider → localized floating snackbar (body unchanged)
- [ ] Status chip color from LabResultStatus (no magic strings; AppColors success/warning/danger + neutral for unknown)
- [ ] Chart tooltip: formatted date (formatClinicalDate), value + unit, reference range low–high, derived status label
- [ ] Semantics/labels: l10n labResultsSelectTest, labResultsRefresh (RefreshIndicator semanticsLabel), labResultsLatestValue (card latest-value label) — labResultsOpen superseded by clinicalHistoryLabResults