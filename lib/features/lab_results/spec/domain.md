models:
  - name: LabResultEntity
    layer: domain
    file: shared/models/lab_results/lab_result_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      id:
        type: String
        json_key: id
        required: true
      testCode:
        type: String
        json_key: test_code
        required: true
      testName:
        type: String
        json_key: test_name
        required: true
      category:
        type: String
        json_key: category
        required: true
      unit:
        type: String?
        json_key: unit
        required: false
      kind:
        type: LabResultKind
        json_key: kind
        required: true
      referenceRange:
        type: LabResultReferenceRangeEntity?
        json_key: reference_range
        required: false
      values:
        type: List<LabResultValueEntity>
        json_key: values
        required: true
    notes:
      - REUSED from shared/models — the feature MUST NOT create a new entity file.
      - Import via package:clean_architecture_sdd_harness/shared/models/_models.lib.dart.
      - Exposes a `status` getter → LabResultStatus derived from the LATEST (most recent date) value vs referenceRange (additive; schema unchanged).
      - Persisted by core/database (LabResultsSerializer) — this is why it lives in the Shared Kernel, not the feature.
      - kind == LabResultKind.text → values carry textValue; kind == LabResultKind.numeric → values carry value.

  - name: LabResultValueEntity
    layer: domain
    file: shared/models/lab_results/lab_result_value_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      date:
        type: DateTime
        json_key: date
        required: true
      value:
        type: double?
        json_key: value
        required: false
      textValue:
        type: String?
        json_key: text_value
        required: false
    notes:
      - REUSED from shared/models. No new entity file.
      - Exactly one of value/textValue is non-null per the parent result's kind: numeric → value, text → textValue. Enforced by the mapper/serializer round-trip.

  - name: LabResultReferenceRangeEntity
    layer: domain
    file: shared/models/lab_results/lab_result_reference_range_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      low:
        type: double
        json_key: low
        required: true
      high:
        type: double
        json_key: high
        required: true
    notes:
      - REUSED from shared/models. No new entity file.
      - null on the parent result → no chart band, status Unknown.

  - name: LabResultKind
    layer: domain
    file: shared/models/lab_results/lab_result_kind.dart
    annotations: ["enum"]
    reused: true
    fields: none
    notes:
      - numeric / text. Raw wire values "numeric" | "text", unknown falls back to text.
      - REUSED from shared/models (exported via _models.lib.dart). Pure Dart, no codegen.

  - name: LabResultStatus
    layer: domain
    file: shared/models/lab_results/lab_result_status.dart
    annotations: ["enum"]
    reused: true
    fields: none
    notes:
      - normal / high / low / unknown. Derived per value vs reference range: value > high → high; value < low → low; within (inclusive) → normal; no range → unknown.
      - Pure function deriveLabResultStatus(double? value, LabResultReferenceRangeEntity? range) in the same file — pure Dart, no codegen.
      - REUSED from shared/models (exported via _models.lib.dart). UI localizes the label via l10n, never hardcodes.

  - name: Period
    layer: domain
    file: features/lab_results/domain/value_objects/period.dart
    annotations: ["enum"]
    reused: false
    fields: none
    notes:
      - threeMonths / sixMonths / oneYear / all. Default all.
      - Pure Dart value object in the FEATURE (not shared) — only this feature consumes it.
      - Provides a duration used by filterByPeriod (pure function CO-LOCATED in the same file — mirrors deriveLabResultStatus). UI localizes the label via l10n, never hardcodes.

  - name: LabResultsState
    layer: presentation
    file: features/lab_results/presentation/notifiers/lab_results_state.dart
    annotations: ["@freezed", "sealed"]
    variants:
      LabResultsInitial:
        fields: none
        description: Initial idle state before the first load. The screen triggers load() when it sees this state.
      LabResultsLoading:
        fields: none
        description: A load or refresh is in progress.
      LabResultsLoaded:
        fields:
          results: List<LabResultEntity>
          selectedTestId: String?
          period: Period
        description: The results were loaded (remote, cache, or refresh). Holds the UI selection so the screen is driven by one state machine.
      LabResultsFailure:
        fields:
          error: AppError
        description: Loading or refreshing failed; UI localizes via localizeError().
    notes:
      - No ._() private constructor on the state (rule from confirmed assumptions).
      - Selection (selectedTestId + period) lives in the state; the notifier exposes selectTest(id)/setPeriod(p) that update the state WITHOUT reloading.
      - After a load/refresh the notifier re-validates selectedTestId against the new set (falls back to the first numeric test, or null when none remain).
      - Period filtering is derived in presentation via the pure function filterByPeriod() from the domain value object.

pure_functions:
  - name: filterByPeriod
    file: features/lab_results/domain/value_objects/period.dart
    signature: "List<LabResultValueEntity> filterByPeriod(List<LabResultValueEntity> values, Period period)"
    notes:
      - Co-located with the Period enum in period.dart (pattern: deriveLabResultStatus in lab_result_status.dart).
      - Filters values relative to the MOST RECENT data date of the full unfiltered list (max date); keeps values within [mostRecent - period.duration, mostRecent]; Period.all (or a null duration) returns values unchanged.
      - Applied to the selected test's chart data points. NEVER applied to the card's latest value/status chip nor to the non-numeric flat list (both always show the most recent unfiltered value — the flat list is period-independent).
      - Pure Dart, no codegen, no Result.

interfaces:
  - name: ILabResultsRemoteDatasource
    file: features/lab_results/domain/datasources/i_lab_results_remote_datasource.dart
    methods:
      - signature: "Future<List<LabResultEntity>> loadRemote()"
    notes:
      - Remote contract (GET /user/clinical-history/lab-results via httpServiceProvider + appUriesProvider).
      - No Result — wrapping happens in LabResultsRepositoryImpl via guard().

  - name: ILabResultsLocalDatasource
    file: features/lab_results/domain/datasources/i_lab_results_local_datasource.dart
    methods:
      - signature: "Future<List<LabResultEntity>> loadLocal()"
      - signature: "Future<void> storeLocal(List<LabResultEntity> entities)"
    notes:
      - Offline cache contract; adapter over ILabResultsStore (labResultsStoreProvider).
      - No Result — wrapping happens in LabResultsRepositoryImpl via guard().
      - The adapter never clears the cache — deletion is only reachable via account reset (auth's concern).

  - name: ILabResultsRepository
    file: features/lab_results/domain/repositories/i_lab_results_repository.dart
    methods:
      - signature: "Future<Result<List<LabResultEntity>>> loadLabResults()"
      - signature: "Future<Result<List<LabResultEntity>>> refreshLabResults()"
    notes:
      - loadLabResults is online-first: remote first, cache fallback ONLY on a genuine connectivity failure (no connection / server unreachable), write-through on success.
      - refreshLabResults forces the network, writes through on success, and does NOT fall back to cache on failure.
      - Both via fetchOrFallback/guard from shared/error + shared/functions/online_first.dart.

usecases:
  - name: LoadLabResultsUseCase
    constructor_args:
      - repository: ILabResultsRepository
    methods:
      - signature: "Future<Result<List<LabResultEntity>>> call()"
    notes:
      - Online-first load; delegates to repository.loadLabResults().

  - name: RefreshLabResultsUseCase
    constructor_args:
      - repository: ILabResultsRepository
    methods:
      - signature: "Future<Result<List<LabResultEntity>>> call()"
    notes:
      - Forces network + write-through; delegates to repository.refreshLabResults().

providers:
  - name: _labResultsRemoteDatasourceProvider (private)
    file: features/lab_results/di/lab_results_provider.dart
    type: Provider<ILabResultsRemoteDatasource>
    dependencies:
      - httpServiceProvider
      - appUriesProvider
  - name: _labResultsLocalDatasourceProvider (private)
    file: features/lab_results/di/lab_results_provider.dart
    type: Provider<ILabResultsLocalDatasource>
    dependencies:
      - labResultsStoreProvider
  - name: labResultsRepositoryProvider
    file: features/lab_results/di/lab_results_provider.dart
    type: Provider<ILabResultsRepository>
    dependencies:
      - _labResultsRemoteDatasourceProvider
      - _labResultsLocalDatasourceProvider
  - name: loadLabResultsUseCaseProvider
    file: features/lab_results/di/lab_results_provider.dart
    type: Provider<LoadLabResultsUseCase>
    dependencies:
      - labResultsRepositoryProvider
  - name: refreshLabResultsUseCaseProvider
    file: features/lab_results/di/lab_results_provider.dart
    type: Provider<RefreshLabResultsUseCase>
    dependencies:
      - labResultsRepositoryProvider
  - name: labResultsProvider
    file: features/lab_results/di/lab_results_provider.dart
    type: Notifier (code-gen @riverpod class, Notifier<LabResultsState>)
    dependencies:
      - loadLabResultsUseCaseProvider
      - refreshLabResultsUseCaseProvider
    notes:
      - build() -> LabResultsInitial. load()/refresh() fold Results; selectTest(id)/setPeriod(p) mutate the Loaded state without reloading.
  - name: labResultsRefreshErrorProvider (presentation UI-state)
    file: features/lab_results/presentation/notifiers/lab_results_refresh_error_provider.dart
    type: Notifier<AppError?> (code-gen @riverpod class)
    dependencies: none
    notes:
      - Transient error emitted when a pull-to-refresh fails while the last loaded results are kept visible (mirror of clinicalHistoryRefreshErrorProvider).
      - The list state machine is unchanged: refresh() failure from Loaded keeps the results and sets this provider; the screen listens for the snackbar.

di_re_exports:
  - symbol: trendChartProvider
    from: core/services/charts/charts_providers.dart
    type: Provider<ITrendChart>
    notes:
      - Re-exported by the feature di/ so presentation/ uses the wrapper seam and NEVER imports package:fl_chart (Rule 6 gains 'package:fl_chart' in test/architecture/dependency_rules_test.dart).
      - ITrendChart API is finalized in the wrapper spike (D.0.6) and captured in generated_api_contract.md; minimum surface renders a line chart with a reference-range band and legible axes.
  - symbol: appNavigatorProvider
    from: core/router/app_navigator_provider.dart
    type: Provider<IAppNavigator>
    notes:
      - Re-exported ONLY if the feature navigates imperatively. Expected NOT needed: back navigation is handled by the go_router shell and the entry point lives in the clinical history AppBar action (wired at D.10 via appNavigatorProvider.go(AppRoute.labResults) from the clinical_history screen).