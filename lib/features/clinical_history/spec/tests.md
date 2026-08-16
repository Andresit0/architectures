tests:
  unit:
    - name: clinical_history_remote_datasource_loadRemote_success_returns_entities
      layer: infrastructure
      given: IDioWrapper.get returns a map {"clinical_history": [<ClinicalHistoryDto JSON>]}
      when: ClinicalHistoryRemoteDatasourceImpl.loadRemote() is called
      then: Returns List<ClinicalHistoryEntity> parsed via ClinicalHistoryListResponseDto + ClinicalHistoryMapper.fromDtoList

    - name: clinical_history_remote_datasource_loadRemote_401_throws_ApiException
      layer: infrastructure
      given: IDioWrapper.get throws ApiException(401)
      when: ClinicalHistoryRemoteDatasourceImpl.loadRemote() is called
      then: Propagates ApiException (no try/catch in datasource)

    - name: clinical_history_remote_datasource_loadRemote_network_failure_throws_NoConnectionException
      layer: infrastructure
      given: IDioWrapper.get throws NoConnectionException
      when: ClinicalHistoryRemoteDatasourceImpl.loadRemote() is called
      then: Propagates NoConnectionException

    - name: clinical_history_remote_datasource_loadRemote_non_json_response_throws_UnexpectedResponseException
      layer: infrastructure
      given: IDioWrapper.get returns a non-JSON-object body
      when: ClinicalHistoryRemoteDatasourceImpl.loadRemote() is called
      then: Throws UnexpectedResponseException with a descriptive details message

    - name: clinical_history_remote_datasource_loadRemote_uses_EndpointSla_standard
      layer: infrastructure
      given: A valid load request
      when: ClinicalHistoryRemoteDatasourceImpl.loadRemote() is called
      then: Uses EndpointSla.standard for the GET

    - name: clinical_history_local_datasource_loadLocal_returns_cached_entities
      layer: infrastructure
      given: IClinicalHistoryStore.loadAll() returns cached entities
      when: ClinicalHistoryLocalDatasourceImpl.loadLocal() is called
      then: Returns the cached List<ClinicalHistoryEntity>

    - name: clinical_history_local_datasource_storeLocal_delegates_to_store
      layer: infrastructure
      given: A list of ClinicalHistoryEntity
      when: ClinicalHistoryLocalDatasourceImpl.storeLocal(entities) is called
      then: IClinicalHistoryStore.storeAll(entities) is invoked

    - name: clinical_history_repository_load_remote_success_returns_success_and_writes_through
      layer: infrastructure
      given: Datasource.loadRemote() returns a valid list and storeLocal() succeeds
      when: ClinicalHistoryRepositoryImpl.loadClinicalHistories() is called
      then: Returns Success(list) and storeLocal is called (write-through)

    - name: clinical_history_repository_load_network_failure_falls_back_to_cache
      layer: infrastructure
      given: Datasource.loadRemote() throws NoConnectionException and loadLocal() returns cached data
      when: ClinicalHistoryRepositoryImpl.loadClinicalHistories() is called
      then: Returns Success(cached list) and storeLocal is NOT called

    - name: clinical_history_repository_load_network_failure_no_cache_returns_failure
      layer: infrastructure
      given: Datasource.loadRemote() throws NoConnectionException and loadLocal() returns empty list
      when: ClinicalHistoryRepositoryImpl.loadClinicalHistories() is called
      then: Returns Failure(NetworkError)

    - name: clinical_history_repository_load_api_error_does_not_fall_back_to_cache
      layer: infrastructure
      given: Datasource.loadRemote() throws ApiException(401) and cache has data
      when: ClinicalHistoryRepositoryImpl.loadClinicalHistories() is called
      then: Returns Failure(ApiError) (only network-related errors fall back to cache)

    - name: clinical_history_repository_refresh_success_returns_success_and_writes_through
      layer: infrastructure
      given: Datasource.loadRemote() returns a valid list
      when: ClinicalHistoryRepositoryImpl.refreshClinicalHistories() is called
      then: Returns Success(list) and storeLocal is called

    - name: clinical_history_repository_refresh_failure_returns_failure_no_cache_fallback
      layer: infrastructure
      given: Datasource.loadRemote() throws NoConnectionException and cache has data
      when: ClinicalHistoryRepositoryImpl.refreshClinicalHistories() is called
      then: Returns Failure(NetworkError) (refresh never falls back to cache)

    - name: clinical_history_usecase_load_delegates_to_repository
      layer: domain
      given: IClinicalHistoryRepository is mocked to return Success(list)
      when: LoadClinicalHistoriesUseCase.call() is called
      then: Delegates to repository.loadClinicalHistories() and returns the result unchanged

    - name: clinical_history_usecase_load_repository_failure_returns_failure
      layer: domain
      given: IClinicalHistoryRepository returns Failure(NetworkError)
      when: LoadClinicalHistoriesUseCase.call() is called
      then: Returns Failure(NetworkError)

    - name: clinical_history_usecase_refresh_delegates_to_repository
      layer: domain
      given: IClinicalHistoryRepository is mocked to return Success(list)
      when: RefreshClinicalHistoriesUseCase.call() is called
      then: Delegates to repository.refreshClinicalHistories() and returns the result unchanged

    - name: clinical_history_notifier_load_success_sets_loaded_state
      layer: presentation
      given: LoadClinicalHistoriesUseCase returns Success([entity1, entity2])
      when: ClinicalHistoryNotifier.load() is called
      then: State becomes ClinicalHistoryLoaded with the two entities

    - name: clinical_history_notifier_load_failure_sets_failure_state
      layer: presentation
      given: LoadClinicalHistoriesUseCase returns Failure(NetworkError)
      when: ClinicalHistoryNotifier.load() is called
      then: State becomes ClinicalHistoryFailure(NetworkError)

    - name: clinical_history_notifier_load_empty_list_sets_loaded_with_empty_list
      layer: presentation
      given: LoadClinicalHistoriesUseCase returns Success([])
      when: ClinicalHistoryNotifier.load() is called
      then: State becomes ClinicalHistoryLoaded with an empty list

    - name: clinical_history_notifier_refresh_success_replaces_loaded_state
      layer: presentation
      given: State is ClinicalHistoryLoaded with old list and RefreshClinicalHistoriesUseCase returns Success(new list)
      when: ClinicalHistoryNotifier.refresh() is called
      then: State becomes ClinicalHistoryLoaded with the new list

    - name: clinical_history_notifier_refresh_failure_from_loaded_keeps_list_and_emits_error
      layer: presentation
      given: State is ClinicalHistoryLoaded with a list and RefreshClinicalHistoriesUseCase returns Failure(NetworkError)
      when: ClinicalHistoryNotifier.refresh() is called
      then: State stays ClinicalHistoryLoaded with the same list and clinicalHistoryRefreshErrorProvider emits NetworkError

    - name: clinical_history_notifier_refresh_failure_without_list_sets_failure_state
      layer: presentation
      given: No list loaded and RefreshClinicalHistoriesUseCase returns Failure(NetworkError)
      when: ClinicalHistoryNotifier.refresh() is called
      then: State becomes ClinicalHistoryFailure(NetworkError)

    - name: clinical_history_notifier_reset_returns_initial_state
      layer: presentation
      given: State is ClinicalHistoryFailure(error)
      when: ClinicalHistoryNotifier.reset() is called
      then: State becomes ClinicalHistoryInitial

    - name: clinical_history_state_initial_is_default
      layer: presentation
      given: A new ClinicalHistoryNotifier is built
      when: build() runs
      then: State is ClinicalHistoryInitial

    - name: clinical_history_status_fromCode_maps_and_falls_back
      layer: domain
      given: Raw wire codes ready / pending / closed / unknown / null / mixed-case
      when: ClinicalHistoryStatus.fromCode(code) is called
      then: Maps ready→ready, pending→pending, closed→closed, case-insensitive, null/unknown→unknown

  widget:
    - name: clinical_history_screen_shows_skeleton_loading
      given: The notifier is in ClinicalHistoryLoading state
      when: The screen renders
      then: SkeletonList from design_system is displayed (placeholder cards, not a spinner)

    - name: clinical_history_screen_shows_list_of_cards
      given: The notifier is in ClinicalHistoryLoaded with two encounters
      when: The screen renders
      then: Two encounter cards are visible showing service.name, facility.name + facility.city, encounterDate (formatted) and state.label
      and: A header count (clinicalHistoryCount) is shown

    - name: clinical_history_screen_tap_card_expands_details
      given: The notifier is in ClinicalHistoryLoaded with one encounter
      when: The user taps the encounter card
      then: Inline details appear: professional.fullname/specialty, summary, description, diagnosis code/name, observations, attachments name/type
      and: Tapping again collapses the details

    - name: clinical_history_screen_empty_list_shows_empty_state_and_retry
      given: The notifier is in ClinicalHistoryLoaded with an empty list
      when: The screen renders
      then: The empty-state message is shown
      and: A retry button that calls load() is visible

    - name: clinical_history_screen_failure_shows_localized_snackbar_and_error_state
      given: The notifier transitions to ClinicalHistoryFailure(NetworkError)
      when: The screen renders
      then: A floating snackbar with localizeError(error) and an ErrorState body are shown
      and: The notifier is NOT reset (failure must not return to Initial — it would create an infinite load→fail→reset loop offline)

    - name: clinical_history_screen_refresh_failure_keeps_list_and_shows_snackbar
      given: The list is loaded and clinicalHistoryRefreshErrorProvider emits NetworkError (failed pull-to-refresh)
      when: The screen renders
      then: The encounter cards remain visible and a localized error snackbar is shown (no ErrorState)

    - name: clinical_history_card_state_chip_typed_color
      given: An encounter with state code "ready"
      when: The card renders
      then: The state InfoChip uses the typed-status color (AppColors.success)

    - name: clinical_history_screen_wraps_list_in_refresh_indicator
      given: The notifier is in ClinicalHistoryLoaded
      when: The screen renders
      then: A RefreshIndicator wrapping the ListView is present

    - name: clinical_history_screen_appbar_has_title_and_logout
      given: The screen renders with an onLogout callback
      when: The AppBar builds
      then: The title is l10n clinicalHistory and a logout button (l10n logout) calls onLogout

  integration:
    - name: clinical_history_load_shows_list
      scenario: Load shows the list with service, facility, date and state
      fake_repositories:
        - IClinicalHistoryRepository
      given: The app boots with a fake IClinicalHistoryRepository returning two encounters
      when: The user navigates to /clinical_history
      then: Two encounter cards show service name, facility name and city, date and state label

    - name: clinical_history_empty_state_with_retry
      scenario: Empty history shows an empty state with retry
      fake_repositories:
        - IClinicalHistoryRepository
      given: The app boots with a fake repository returning an empty list
      when: The user navigates to /clinical_history
      then: The empty-state message and a retry button are shown

    - name: clinical_history_pull_to_refresh
      scenario: Pull to refresh reloads from the server
      fake_repositories:
        - IClinicalHistoryRepository
      given: The app shows the loaded list from a fake repository
      when: The user pulls down to refresh
      then: The repository.refreshClinicalHistories() is invoked and the list updates

    - name: clinical_history_offline_shows_cache
      scenario: Offline with cached data shows the cache
      fake_repositories:
        - IClinicalHistoryRepository
      given: A fake repository that fails remote and serves cached data
      when: The user navigates to /clinical_history
      then: The cached encounters are shown instead of an error

    - name: clinical_history_network_failure_retry
      scenario: Network failure shows a localized error and allows retry
      fake_repositories:
        - IClinicalHistoryRepository
      given: A fake repository returning Failure(NetworkError) with no cache
      when: The user navigates to /clinical_history
      then: A localized error snackbar is shown and a retry action is available

    - name: clinical_history_refresh_failure_keeps_cache
      scenario: Pull to refresh offline keeps the cached list
      fake_repositories:
        - IClinicalHistoryRepository
      given: A fake repository returning Success on load and Failure(NetworkError) on refresh
      when: The user pulls down to refresh
      then: The cached encounter cards remain visible and a localized error snackbar is shown

l10n_keys:
  reused:
    - clinicalHistory (AppBar title)
    - logout (logout button)
  new_required:
    - clinicalHistoryEmpty — empty-state message (en: "No clinical history records yet."; es: "Aún no hay registros de historial clínico.")
    - clinicalHistoryRetry — retry button label (en: "Retry"; es: "Reintentar")
    - clinicalHistoryCount — list header count with ICU plural (en: "{count, plural, =1{1 record} other{{count} records}}"; es: "{count, plural, =1{1 registro} other{{count} registros}}")
  new_optional:
    - clinicalHistoryDetailsProfessional — expanded-detail label "Professional"
    - clinicalHistoryDetailsSummary — expanded-detail label "Summary"
    - clinicalHistoryDetailsDescription — expanded-detail label "Description"
    - clinicalHistoryDetailsDiagnosis — expanded-detail label "Diagnosis"
    - clinicalHistoryDetailsObservations — expanded-detail label "Observations"
    - clinicalHistoryDetailsAttachments — expanded-detail label "Attachments"
    - clinicalHistoryDetailsExpand — Semantics hint "Show encounter details"
    - clinicalHistoryDetailsCollapse — Semantics hint "Hide encounter details"
  notes:
    - Add the new_required keys (and new_optional labels) to lib/l10n/app_es.arb, lib/l10n/app_en.arb, then run gen-l10n to regenerate lib/l10n/app_localizations*.dart.
