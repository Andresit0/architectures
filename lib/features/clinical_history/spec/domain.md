models:
  - name: ClinicalHistoryEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      id:
        type: String
        json_key: id
        required: true
      encounterNumber:
        type: String
        json_key: encounter_number
        required: true
      service:
        type: ClinicalHistoryServiceEntity
        json_key: service
        required: true
      facility:
        type: ClinicalHistoryFacilityEntity
        json_key: facility
        required: true
      professional:
        type: ClinicalHistoryProfessionalEntity?
        json_key: professional
        required: false
      encounterDate:
        type: String
        json_key: encounter_date
        required: true
      createdAt:
        type: DateTime?
        json_key: created_at
        required: false
      updatedAt:
        type: DateTime?
        json_key: updated_at
        required: false
      publishedAt:
        type: DateTime?
        json_key: published_at
        required: false
      summary:
        type: String?
        json_key: summary
        required: false
      description:
        type: String?
        json_key: description
        required: false
      diagnosis:
        type: List<ClinicalHistoryDiagnosisEntity>
        json_key: diagnosis
        required: true
      observations:
        type: List<String>
        json_key: observations
        required: true
      attachments:
        type: List<ClinicalHistoryAttachmentEntity>
        json_key: attachments
        required: true
      state:
        type: ClinicalHistoryStateEntity?
        json_key: state
        required: false
    notes:
      - REUSED from shared/models — the feature MUST NOT create a new entity file.
      - Import via package:clean_architecture_sdd_harness/shared/models/_models.lib.dart.

  - name: ClinicalHistoryServiceEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_service_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      code: { type: String, json_key: code, required: true }
      name: { type: String, json_key: name, required: true }
      category: { type: String, json_key: category, required: true }
    notes:
      - REUSED from shared/models. No new entity file.

  - name: ClinicalHistoryFacilityEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_facility_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      id: { type: String, json_key: id, required: true }
      name: { type: String, json_key: name, required: true }
      city: { type: String, json_key: city, required: true }
    notes:
      - REUSED from shared/models. No new entity file.

  - name: ClinicalHistoryProfessionalEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_professional_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      id: { type: String, json_key: id, required: true }
      fullname: { type: String, json_key: fullname, required: true }
      specialty: { type: String, json_key: specialty, required: true }
    notes:
      - REUSED from shared/models. No new entity file.

  - name: ClinicalHistoryDiagnosisEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_diagnosis_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      code: { type: String, json_key: code, required: true }
      name: { type: String, json_key: name, required: true }
    notes:
      - REUSED from shared/models. No new entity file.

  - name: ClinicalHistoryAttachmentEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_attachment_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      id: { type: String, json_key: id, required: true }
      type: { type: String, json_key: type, required: true }
      name: { type: String, json_key: name, required: true }
      sizeBytes: { type: int, json_key: size_bytes, required: true }
      url: { type: String, json_key: url, required: true }
    notes:
      - REUSED from shared/models. No new entity file.

  - name: ClinicalHistoryStateEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_state_entity.dart
    annotations: ["@freezed"]
    reused: true
    fields:
      code: { type: String, json_key: code, required: true }
      label: { type: String, json_key: label, required: true }
    notes:
      - REUSED from shared/models. No new entity file.
      - Exposes a typed `status` getter → ClinicalHistoryStatus.fromCode(code) (additive; schema unchanged).

  - name: ClinicalHistoryStatus
    layer: domain
    file: shared/models/clinical_history/clinical_history_status.dart
    annotations: ["enum"]
    reused: true
    fields: none
    notes:
      - Typed status derived from the raw wire code: ready / pending / closed / unknown (fallback).
      - REUSED from shared/models (exported via _models.lib.dart). Pure Dart, no codegen.

  - name: ClinicalHistoryState
    layer: presentation
    file: features/clinical_history/presentation/notifiers/clinical_history_state.dart
    annotations: ["@freezed", "sealed"]
    variants:
      ClinicalHistoryInitial:
        fields: none
        description: Initial idle state before the first load. The screen triggers load() when it sees this state.
      ClinicalHistoryLoading:
        fields: none
        description: A load or refresh is in progress.
      ClinicalHistoryLoaded:
        fields:
          clinicalHistory: List<ClinicalHistoryEntity>
        description: The list of encounters was loaded (remote, cache, or refresh).
      ClinicalHistoryFailure:
        fields:
          error: AppError
        description: Loading or refreshing failed; UI localizes via localizeError().
    notes:
      - No ._() private constructor on the state (rule from confirmed assumptions).

interfaces:
  - name: IClinicalHistoryRemoteDatasource
    file: features/clinical_history/domain/datasources/i_clinical_history_remote_datasource.dart
    methods:
      - signature: "Future<List<ClinicalHistoryEntity>> loadRemote()"
    notes:
      - Remote contract (GET /user/clinical-history via httpServiceProvider).
      - No Result — wrapping happens in ClinicalHistoryRepositoryImpl via guard().

  - name: IClinicalHistoryLocalDatasource
    file: features/clinical_history/domain/datasources/i_clinical_history_local_datasource.dart
    methods:
      - signature: "Future<List<ClinicalHistoryEntity>> loadLocal()"
      - signature: "Future<void> storeLocal(List<ClinicalHistoryEntity> entities)"
    notes:
      - Offline cache contract; adapter over IClinicalHistoryStore (clinicalHistoryStoreProvider).
      - No Result — wrapping happens in ClinicalHistoryRepositoryImpl via guard().

  - name: IClinicalHistoryRepository
    file: features/clinical_history/domain/repositories/i_clinical_history_repository.dart
    methods:
      - signature: "Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories()"
      - signature: "Future<Result<List<ClinicalHistoryEntity>>> refreshClinicalHistories()"
    notes:
      - loadClinicalHistories is online-first: remote first, cache fallback ONLY on a genuine connectivity failure (no connection / server unreachable), write-through on success.
      - refreshClinicalHistories forces the network, writes through on success, and does NOT fall back to cache on failure.

usecases:
  - name: LoadClinicalHistoriesUseCase
    constructor_args:
      - repository: IClinicalHistoryRepository
    methods:
      - signature: "Future<Result<List<ClinicalHistoryEntity>>> call()"
    notes:
      - Online-first load; delegates to repository.loadClinicalHistories().

  - name: RefreshClinicalHistoriesUseCase
    constructor_args:
      - repository: IClinicalHistoryRepository
    methods:
      - signature: "Future<Result<List<ClinicalHistoryEntity>>> call()"
    notes:
      - Forces network + write-through; delegates to repository.refreshClinicalHistories().

providers:
  - name: _clinicalHistoryRemoteDatasourceProvider (private)
    file: features/clinical_history/di/clinical_history_provider.dart
    type: Provider<IClinicalHistoryRemoteDatasource>
    dependencies:
      - httpServiceProvider
      - appUriesProvider
  - name: _clinicalHistoryLocalDatasourceProvider (private)
    file: features/clinical_history/di/clinical_history_provider.dart
    type: Provider<IClinicalHistoryLocalDatasource>
    dependencies:
      - clinicalHistoryStoreProvider
  - name: clinicalHistoryRepositoryProvider
    file: features/clinical_history/di/clinical_history_provider.dart
    type: Provider<IClinicalHistoryRepository>
    dependencies:
      - _clinicalHistoryRemoteDatasourceProvider
      - _clinicalHistoryLocalDatasourceProvider
  - name: loadClinicalHistoriesUseCaseProvider
    file: features/clinical_history/di/clinical_history_provider.dart
    type: Provider<LoadClinicalHistoriesUseCase>
    dependencies:
      - clinicalHistoryRepositoryProvider
  - name: refreshClinicalHistoriesUseCaseProvider
    file: features/clinical_history/di/clinical_history_provider.dart
    type: Provider<RefreshClinicalHistoriesUseCase>
    dependencies:
      - clinicalHistoryRepositoryProvider
  - name: clinicalHistoryProvider
    file: features/clinical_history/di/clinical_history_provider.dart
    type: AsyncNotifierProvider? Notifier (code-gen @riverpod class)
    dependencies:
      - loadClinicalHistoriesUseCaseProvider
      - refreshClinicalHistoriesUseCaseProvider
  - name: clinicalHistoryRefreshErrorProvider (presentation UI-state)
    file: features/clinical_history/presentation/notifiers/clinical_history_refresh_error_provider.dart
    type: Notifier<AppError?> (code-gen @riverpod class)
    dependencies: none
    notes:
      - Transient error emitted when a pull-to-refresh fails while the last loaded list is kept visible (mirror of remember_me_provider).
      - The list state machine is unchanged: refresh() failure from Loaded keeps the list and sets this provider; the screen listens for the snackbar.
