tests:
  unit:
    - name: lab_results_remote_datasource_loadRemote_success_returns_entities
      layer: infrastructure
      given: IDioWrapper.get returns a map {"lab_results": [<LabResultDto JSON>]}
      when: LabResultsRemoteDatasourceImpl.loadRemote() is called
      then: Returns List<LabResultEntity> parsed via LabResultsListResponseDto + LabResultsMapper.fromDtoList

    - name: lab_results_remote_datasource_loadRemote_numeric_with_range_parses_range_and_values
      layer: infrastructure
      given: A numeric result JSON with reference_range {low, high} and numeric values
      when: loadRemote() is called
      then: kind == numeric, referenceRange populated, each value carries a double value and null textValue

    - name: lab_results_remote_datasource_loadRemote_numeric_without_range_parses_null_range
      layer: infrastructure
      given: A numeric result JSON with reference_range null
      when: loadRemote() is called
      then: referenceRange is null (status derivation later yields Unknown)

    - name: lab_results_remote_datasource_loadRemote_text_parses_text_values
      layer: infrastructure
      given: A result JSON with kind "text" and string values
      when: loadRemote() is called
      then: kind == text, each value carries textValue and null value, unit is null

    - name: lab_results_remote_datasource_loadRemote_401_throws_ApiException
      layer: infrastructure
      given: IDioWrapper.get throws ApiException(401)
      when: LabResultsRemoteDatasourceImpl.loadRemote() is called
      then: Propagates ApiException (no try/catch in datasource)

    - name: lab_results_remote_datasource_loadRemote_network_failure_throws_NoConnectionException
      layer: infrastructure
      given: IDioWrapper.get throws NoConnectionException
      when: LabResultsRemoteDatasourceImpl.loadRemote() is called
      then: Propagates NoConnectionException

    - name: lab_results_remote_datasource_loadRemote_non_json_response_throws_UnexpectedResponseException
      layer: infrastructure
      given: IDioWrapper.get returns a non-JSON-object body
      when: LabResultsRemoteDatasourceImpl.loadRemote() is called
      then: Throws UnexpectedResponseException with a descriptive details message

    - name: lab_results_remote_datasource_loadRemote_uses_EndpointSla_standard
      layer: infrastructure
      given: A valid load request
      when: LabResultsRemoteDatasourceImpl.loadRemote() is called
      then: Uses EndpointSla.standard for the GET

    - name: lab_results_local_datasource_loadLocal_returns_cached_entities
      layer: infrastructure
      given: ILabResultsStore.loadAll() returns cached entities
      when: LabResultsLocalDatasourceImpl.loadLocal() is called
      then: Returns the cached List<LabResultEntity>

    - name: lab_results_local_datasource_storeLocal_delegates_to_store
      layer: infrastructure
      given: A list of LabResultEntity
      when: LabResultsLocalDatasourceImpl.storeLocal(entities) is called
      then: ILabResultsStore.storeAll(entities) is invoked

    - name: lab_results_repository_load_remote_success_returns_success_and_writes_through
      layer: infrastructure
      given: Datasource.loadRemote() returns a valid list and storeLocal() succeeds
      when: LabResultsRepositoryImpl.loadLabResults() is called
      then: Returns Success(list) and storeLocal is called (write-through)

    - name: lab_results_repository_load_network_failure_falls_back_to_cache
      layer: infrastructure
      given: Datasource.loadRemote() throws NoConnectionException and loadLocal() returns cached data
      when: LabResultsRepositoryImpl.loadLabResults() is called
      then: Returns Success(cached list) and storeLocal is NOT called

    - name: lab_results_repository_load_network_failure_no_cache_returns_failure
      layer: infrastructure
      given: Datasource.loadRemote() throws NoConnectionException and loadLocal() returns empty list
      when: LabResultsRepositoryImpl.loadLabResults() is called
      then: Returns Failure(NetworkError)

    - name: lab_results_repository_load_api_error_does_not_fall_back_to_cache
      layer: infrastructure
      given: Datasource.loadRemote() throws ApiException(401) and cache has data
      when: LabResultsRepositoryImpl.loadLabResults() is called
      then: Returns Failure(ApiError) (only network-related errors fall back to cache)

    - name: lab_results_repository_refresh_success_returns_success_and_writes_through
      layer: infrastructure
      given: Datasource.loadRemote() returns a valid list
      when: LabResultsRepositoryImpl.refreshLabResults() is called
      then: Returns Success(list) and storeLocal is called

    - name: lab_results_repository_refresh_failure_returns_failure_no_cache_fallback
      layer: infrastructure
      given: Datasource.loadRemote() throws NoConnectionException and cache has data
      when: LabResultsRepositoryImpl.refreshLabResults() is called
      then: Returns Failure(NetworkError) (refresh never falls back to cache)

    - name: lab_results_usecase_load_delegates_to_repository
      layer: domain
      given: ILabResultsRepository is mocked to return Success(list)
      when: LoadLabResultsUseCase.call() is called
      then: Delegates to repository.loadLabResults() and returns the result unchanged

    - name: lab_results_usecase_load_repository_failure_returns_failure
      layer: domain
      given: ILabResultsRepository returns Failure(NetworkError)
      when: LoadLabResultsUseCase.call() is called
      then: Returns Failure(NetworkError)

    - name: lab_results_usecase_refresh_delegates_to_repository
      layer: domain
      given: ILabResultsRepository is mocked to return Success(list)
      when: RefreshLabResultsUseCase.call() is called
      then: Delegates to repository.refreshLabResults() and returns the result unchanged

    - name: period_filter_three_months_keeps_values_in_window
      layer: domain
      given: Values from 2025-12-01 to 2026-08-10 and Period.threeMonths
      when: filterByPeriod(values, period) is called
      then: Keeps only values within 3 months of the most recent date (2026-08-10)

    - name: period_filter_one_year_keeps_values_in_window
      layer: domain
      given: Values from 2025-12-01 to 2026-08-10 and Period.oneYear
      when: filterByPeriod(values, period) is called
      then: Keeps values within 1 year of the most recent date

    - name: period_filter_all_returns_values_unchanged
      layer: domain
      given: Any values and Period.all
      when: filterByPeriod(values, period) is called
      then: Returns the same list unchanged

    - name: period_filter_empty_list_returns_empty
      layer: domain
      given: An empty list and Period.threeMonths
      when: filterByPeriod(values, period) is called
      then: Returns an empty list (no crash on max of empty)

    - name: lab_result_status_derive_within_range_is_normal
      layer: domain
      given: value 14.8 with range {13.0, 17.0}
      when: deriveLabResultStatus(value, range) is called
      then: Returns LabResultStatus.normal

    - name: lab_result_status_derive_above_high_is_high
      layer: domain
      given: value 128.0 with range {70.0, 110.0}
      when: deriveLabResultStatus(value, range) is called
      then: Returns LabResultStatus.high

    - name: lab_result_status_derive_below_low_is_low
      layer: domain
      given: value 3.2 with range {3.5, 5.1}
      when: deriveLabResultStatus(value, range) is called
      then: Returns LabResultStatus.low

    - name: lab_result_status_derive_no_range_is_unknown
      layer: domain
      given: value 2.4 with range null (and null value)
      when: deriveLabResultStatus(value, range) is called
      then: Returns LabResultStatus.unknown

    - name: lab_result_status_derive_boundary_values_are_normal
      layer: domain
      given: value equal to low (13.0) and value equal to high (17.0)
      when: deriveLabResultStatus(value, range) is called
      then: Both return LabResultStatus.normal (inclusive bounds)

    - name: lab_result_entity_status_getter_uses_latest_value
      layer: domain
      given: A numeric LabResultEntity whose most recent value is above high and an older value is normal
      when: entity.status is read
      then: Returns LabResultStatus.high (latest value wins)

    - name: lab_result_serializer_roundtrip_preserves_entity
      layer: infrastructure
      given: A LabResultEntity with numeric + text values and a reference range
      when: LabResultsSerializer.toMap then fromMap is applied
      then: The round-tripped entity equals the original (guards schema consistency, mirror of clinical_history_serializer_test)

    - name: lab_results_notifier_load_success_sets_loaded_state_with_selection
      layer: presentation
      given: LoadLabResultsUseCase returns Success([numeric1, numeric2, text1])
      when: LabResultsNotifier.load() is called
      then: State becomes LabResultsLoaded(results, selectedTestId = first numeric test id, period = Period.all)

    - name: lab_results_notifier_load_failure_sets_failure_state
      layer: presentation
      given: LoadLabResultsUseCase returns Failure(NetworkError)
      when: LabResultsNotifier.load() is called
      then: State becomes LabResultsFailure(NetworkError)

    - name: lab_results_notifier_load_empty_list_sets_loaded_with_empty_list
      layer: presentation
      given: LoadLabResultsUseCase returns Success([])
      when: LabResultsNotifier.load() is called
      then: State becomes LabResultsLoaded([], selectedTestId = null, Period.all)

    - name: lab_results_notifier_select_test_updates_selection_without_reload
      layer: presentation
      given: State is LabResultsLoaded with two numeric tests
      when: LabResultsNotifier.selectTest(id) is called
      then: State stays Loaded with selectedTestId updated; no usecase call is made

    - name: lab_results_notifier_set_period_updates_period_without_reload
      layer: presentation
      given: State is LabResultsLoaded with period Period.all
      when: LabResultsNotifier.setPeriod(Period.sixMonths) is called
      then: State stays Loaded with period updated; no usecase call is made

    - name: lab_results_notifier_refresh_success_replaces_loaded_state_and_revalidates_selection
      layer: presentation
      given: State is Loaded with selectedTestId 'a' and RefreshLabResultsUseCase returns a new list that still contains 'a'
      when: LabResultsNotifier.refresh() is called
      then: State becomes Loaded with the new list and selectedTestId stays 'a'

    - name: lab_results_notifier_refresh_success_deselected_test_falls_back
      layer: presentation
      given: State is Loaded with selectedTestId 'a' and RefreshLabResultsUseCase returns a list without 'a' but with another numeric test 'b'
      when: LabResultsNotifier.refresh() is called
      then: selectedTestId becomes 'b' (first numeric test in the new set)

    - name: lab_results_notifier_refresh_failure_from_loaded_keeps_list_and_emits_error
      layer: presentation
      given: State is Loaded with results and RefreshLabResultsUseCase returns Failure(NetworkError)
      when: LabResultsNotifier.refresh() is called
      then: State stays Loaded with the same results and labResultsRefreshErrorProvider emits NetworkError

    - name: lab_results_notifier_refresh_failure_without_list_sets_failure_state
      layer: presentation
      given: No results loaded and RefreshLabResultsUseCase returns Failure(NetworkError)
      when: LabResultsNotifier.refresh() is called
      then: State becomes LabResultsFailure(NetworkError)

    - name: lab_results_notifier_reset_returns_initial_state
      layer: presentation
      given: State is LabResultsFailure(error)
      when: LabResultsNotifier.reset() is called
      then: State becomes LabResultsInitial

    - name: lab_results_state_initial_is_default
      layer: presentation
      given: A new LabResultsNotifier is built
      when: build() runs
      then: State is LabResultsInitial

  widget:
    - name: lab_results_screen_shows_skeleton_loading
      given: The notifier is in LabResultsLoading state
      when: The screen renders
      then: SkeletonList from design_system is displayed (placeholder cards, not a spinner)

    - name: lab_results_screen_loaded_shows_selector_period_and_cards
      given: The notifier is in LabResultsLoaded with mixed results (2 numeric with range, 1 numeric without range, 1 text)
      when: The screen renders
      then: A numeric test selector, a period filter (default All) and one card per numeric test are visible
      and: Each numeric card shows the latest value with unit and a status chip (Normal/High/Low/Unknown)
      and: The non-numeric test renders in a flat-list section below the chart pane with its latest text value and NO chip

    - name: lab_results_screen_select_numeric_test_renders_chart_pane
      given: The notifier is in LabResultsLoaded with numeric tests and a mocked ITrendChart
      when: The user selects a numeric test in the selector
      then: The chart pane renders via ITrendChart with that test's filtered points and its reference range (when present)

    - name: lab_results_screen_chart_pane_hides_when_no_numeric_selected
      given: The notifier is in LabResultsLoaded and selectedTestId is null (all results non-numeric)
      when: The screen renders
      then: The chart pane is hidden and only the flat list of all non-numeric tests is shown

    - name: lab_results_screen_all_non_numeric_hides_selector_and_period
      given: The notifier is in LabResultsLoaded with ONLY non-numeric results
      when: The screen renders
      then: The test selector and the period filter are hidden entirely
      and: A flat list of all non-numeric tests shows their latest textual values

    - name: lab_results_screen_period_filter_re_filters_points_and_flat_list
      given: The notifier is in LabResultsLoaded with results and period Period.all
      when: The user selects Period.sixMonths
      then: The chart pane and flat-list values update to the filtered set
      and: The per-test cards still show the latest UNFILTERED value and status chip

    - name: lab_results_screen_chart_tooltip_shows_date_value_unit_range_status
      given: A numeric test is rendered in the chart pane via mocked ITrendChart with a touch callback
      when: The user touches a data point
      then: A tooltip shows the formatted date, the value with its unit, the reference range (low–high) and the derived status

    - name: lab_results_screen_empty_list_shows_empty_state_and_retry
      given: The notifier is in LabResultsLoaded with an empty list
      when: The screen renders
      then: EmptyState shows an icon, the localized message "No hay resultados de laboratorio" (l10n labResultsEmpty)
      and: A retry button that calls load() is visible

    - name: lab_results_screen_failure_shows_localized_snackbar_and_error_state
      given: The notifier transitions to LabResultsFailure(NetworkError)
      when: The screen renders
      then: A floating snackbar with localizeError(error) and an ErrorState body are shown
      and: The notifier is NOT reset (failure must not return to Initial — would create an infinite load→fail→reset loop offline)

    - name: lab_results_screen_refresh_failure_keeps_results_and_shows_snackbar
      given: The results are loaded and labResultsRefreshErrorProvider emits NetworkError (failed pull-to-refresh)
      when: The screen renders
      then: The results remain visible and a localized error snackbar is shown (no ErrorState)

    - name: lab_results_screen_wraps_list_in_refresh_indicator
      given: The notifier is in LabResultsLoaded
      when: The screen renders
      then: A RefreshIndicator wrapping the scrollable content is present

    - name: lab_results_card_numeric_shows_value_unit_and_status_chip
      given: A numeric LabResultEntity with a reference range and a latest value
      when: The card renders
      then: The latest unfiltered value (up to 2 decimals, no trailing zeros) with its unit and a status chip are shown

    - name: lab_results_card_numeric_no_range_shows_unknown_chip
      given: A numeric LabResultEntity without a reference range
      when: The card renders
      then: The status chip shows Unknown (no range → unknown)

    - name: lab_results_card_non_numeric_shows_text_no_chip
      given: A text LabResultEntity
      when: The card renders
      then: The latest textual value is shown and NO status chip is rendered

    - name: lab_results_value_formatter_trims_trailing_zeros
      given: Values 2.0, 2.34, 3.5, 128.0
      when: formatLabValue(value) is called
      then: Returns "2", "2.34", "3.5", "128" (up to 2 decimals, no unnecessary trailing zeros)

  golden:
    - name: lab_results_screen_loading
      given: The notifier is in LabResultsLoading state; surface is 400x800 with the app theme and l10n
      when: The screen renders and the frame settles
      then: A golden image matching test/features/lab_results/presentation/screens/goldens/lab_results_screen_loading.png is produced
    - name: lab_results_screen_loaded
      given: The notifier is in LabResultsLoaded with a stable fixture (2 numeric with range, 1 numeric without range, 1 text), default selection and Period.all; ITrendChart is mocked deterministically (no real fl_chart rendering in the golden)
      when: The screen renders and the frame settles
      then: A golden image matching test/features/lab_results/presentation/screens/goldens/lab_results_screen_loaded.png is produced
    - name: lab_results_screen_empty
      given: The notifier is in LabResultsLoaded with an empty list
      when: The screen renders and the frame settles
      then: A golden image matching test/features/lab_results/presentation/screens/goldens/lab_results_screen_empty.png is produced
    notes:
      - GOLDEN tests are created at Phase D.8.5, NOT at All-Tests-First (planned here so they are spec'd before the freeze). Tag them `@golden` (dart_test.yaml) and run `flutter test --tags golden`.
      - The primary screen golden covers its STABLE visible states: minimum loading, loaded (with fixture data), empty. No failure golden (unstable snackbar timing).
      - ITrendChart is a fake in goldens — charts are never rendered by the real wrapper in tests (mirror of how presentation tests mock wrapper interfaces).

  integration:
    - name: lab_results_load_shows_numeric_cards_and_text_list
      scenario: Load shows numeric cards with status chips and a non-numeric flat list
      fake_repositories:
        - ILabResultsRepository
      given: The app boots with a fake ILabResultsRepository returning mixed results (numeric with/without range + text)
      when: The user navigates from the clinical history AppBar action to /clinical-history/lab-results
      then: The selector, period filter, numeric cards with status chips and the non-numeric flat list are shown
    - name: lab_results_select_numeric_test_renders_chart
      scenario: Selecting a numeric test renders its trend chart with a reference-range band
      fake_repositories:
        - ILabResultsRepository
      given: The app shows the loaded results from a fake repository
      when: The user selects a numeric test with a reference range
      then: The chart pane renders the trend chart with a visible reference-range band
    - name: lab_results_all_non_numeric_hides_selector
      scenario: All results non-numeric hides the selector and period filter
      fake_repositories:
        - ILabResultsRepository
      given: A fake repository returning only non-numeric results
      when: The user navigates to /clinical-history/lab-results
      then: The selector and period filter are hidden and the flat list of all non-numeric tests is shown
    - name: lab_results_empty_state_with_retry
      scenario: Empty results show an empty state with retry
      fake_repositories:
        - ILabResultsRepository
      given: A fake repository returning an empty list
      when: The user navigates to /clinical-history/lab-results
      then: The empty-state icon, message and retry button are shown
    - name: lab_results_pull_to_refresh
      scenario: Pull to refresh reloads from the server
      fake_repositories:
        - ILabResultsRepository
      given: The app shows the loaded results from a fake repository
      when: The user pulls down to refresh
      then: The repository.refreshLabResults() is invoked and the results update
    - name: lab_results_refresh_failure_keeps_results
      scenario: Pull to refresh failure keeps the loaded results and shows a localized error
      fake_repositories:
        - ILabResultsRepository
      given: A fake repository returning Success on load and Failure(NetworkError) on refresh
      when: The user pulls down to refresh
      then: The loaded results remain visible and a localized error snackbar is shown

l10n_keys:
  reused:
    - clinicalHistoryRetry — retry button label (already exists from clinical_history)
  new_required:
    - labResults — AppBar/screen title (en: "Lab Results"; es: "Resultados de laboratorio")
    - labResultsEmpty — empty-state message (en: "No lab results."; es: "No hay resultados de laboratorio")
    - labResultsPeriodLabel — period filter label (en: "Period"; es: "Periodo")
    - labResultsPeriodAll — (en: "All"; es: "Todo")
    - labResultsPeriod3Months — (en: "3 months"; es: "3 meses")
    - labResultsPeriod6Months — (en: "6 months"; es: "6 meses")
    - labResultsPeriod1Year — (en: "1 year"; es: "1 año")
    - labResultsStatusNormal — (en: "Normal"; es: "Normal")
    - labResultsStatusHigh — (en: "High"; es: "Alto")
    - labResultsStatusLow — (en: "Low"; es: "Bajo")
    - labResultsStatusUnknown — (en: "Unknown"; es: "Desconocido")
    - labResultsChartTitle — chart pane title (en: "Trend"; es: "Tendencia")
    - labResultsOtherTests — flat-list section title (en: "Other results"; es: "Otros resultados")
    - labResultsSelectTest — test selector semantics/label (en: "Select a test"; es: "Selecciona un análisis")
  new_optional:
    - labResultsLatestValue — card semantics label for the latest value (implemented, wired) (en: "Latest"; es: "Último")
    - labResultsReferenceRange — tooltip reference-range label (implemented, wired) (en: "Reference range"; es: "Rango de referencia")
    - labResultsRefresh — RefreshIndicator semanticsLabel (implemented, wired) (en: "Refresh results"; es: "Actualizar resultados")
    - (labResultsOpen — superseded by clinicalHistoryLabResults; removed from arb)
  notes:
    - Add the new_required keys (and new_optional labels) to lib/l10n/app_en.arb and lib/l10n/app_es.arb, then run gen-l10n to regenerate lib/l10n/app_localizations*.dart.