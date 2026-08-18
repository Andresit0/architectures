endpoints:
  - method: GET
    path: /user/clinical-history/lab-results
    request:
      headers:
        Authorization:
          format: "Bearer <token>"
          required: true
          description: Added automatically by the AuthInterceptor on httpServiceProvider — the feature never adds it manually
      query_params: none
    responses:
      200:
        body:
          lab_results:
            type: array
            required: true
            description: List of lab results parsed via LabResultsListResponseDto (feature-private, infrastructure/dtos). Each item is either a numeric series or a non-numeric (text) series.
            items:
              type: object
              properties:
                id: string
                test_code: string
                test_name: string
                category: string
                unit: string | null (null for non-numeric results)
                kind: "numeric" | "text" (discriminator)
                reference_range: object { low: number, high: number } | null (null → no band, status Unknown)
                values:
                  type: array of
                    date: string (ISO 8601 date)
                    value: number (kind == numeric) | string (kind == text)
      401:
        error: unauthorized
        description: Handled by AuthInterceptor (retry then force logout) — not this feature's concern
      500:
        error: internal_server_error
        description: Unexpected server error — surfaces as localized server error via localizeError()
    timeout: 15s
    sla: standard
    auth: bearer_token (via httpServiceProvider)
    notes:
      - Wire DTOs are feature-private in lib/features/lab_results/infrastructure/dtos/ (LabResultDto, LabResultValueDto, LabResultReferenceRangeDto, LabResultsListResponseDto) + LabResultsMapper in the same folder. They are NOT moved to core/network/contracts/ because only this feature consumes them (contracts/ is reserved for DTOs shared by 2+ features).
      - Domain entities are REUSED from lib/shared/models/lab_results/ (LabResultEntity, LabResultValueEntity, LabResultReferenceRangeEntity, LabResultKind, LabResultStatus). The feature defines NO new entities.
      - Remote call made via httpServiceProvider (IDioWrapper.get) with sla: EndpointSla.standard. NEVER import raw dio.
      - Add the endpoint to AppUries in lib/core/network/api_endpoints.dart (Uri get labResults => _base.replace(path: '$_userPath/clinical-history/lab-results')) + IEndpointConfig.
      - Offline behavior: repository tries remote first (fetchOrFallback); on network-related failure falls back to local cache (ILabResultsStore via labResultsStoreProvider); on remote success writes through to the cache (write-through).
      - Cache lifecycle: logout does NOT clear the lab_results cache; only ResetAccountUseCase wipes it (LocalAuthDatasourceImpl.resetAccount() → resetDatabase()). The store is a pure I/O adapter, it never clears itself.
      - Local cache access via labResultsStoreProvider -> ILabResultsStore (storeAll/loadAll/deleteAll) in lib/core/database/tables/lab_results_providers.dart; serializer LabResultsSerializer in lib/core/database/serializers/lab_results_serializer.dart.
      - Web/CORS note: dio_wrapper.dart must map browser unknown / failed-fetch errors to NoConnectionException (conditional change required for the developer's web server; done in the wrapper, not the feature).
      - Mock JSON file: lib/features/lab_results/spec/samples/lab_results_200.json (contract documentation only — the app never loads it).