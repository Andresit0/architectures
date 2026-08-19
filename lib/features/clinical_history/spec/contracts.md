endpoints:
  - method: GET
    path: /user/clinical-history
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
          clinical_history:
            type: array
            required: true
            description: List of clinical history encounters, parsed via ClinicalHistoryListResponseDto
            items:
              type: object
              properties:
                id: string
                encounter_number: string
                service: object { code: string, name: string, category: string }
                facility: object { id: string, name: string, city: string }
                professional: object { id: string, fullname: string, specialty: string } | null
                encounter_date: string
                created_at: string (ISO 8601) | null
                updated_at: string (ISO 8601) | null
                published_at: string (ISO 8601) | null
                summary: string | null
                description: string | null
                diagnosis: array of { code: string, name: string }
                observations: array of string
                attachments: array of { id: string, type: string, name: string, size_bytes: int, url: string }
                state: object { code: string, label: string } | null
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
      - Wire DTOs are REUSED from lib/core/network/contracts/ (ClinicalHistoryDto + 6 sub-DTOs, ClinicalHistoryListResponseDto). The feature defines NO new DTOs.
      - Response is parsed with ClinicalHistoryListResponseDto.fromJson then mapped with ClinicalHistoryMapper.fromDtoList (lib/core/network/contracts/clinical_history_mapper.dart).
      - Domain entities are REUSED from lib/shared/models/clinical_history/ (ClinicalHistoryEntity + 6 sub-entities). The feature defines NO new entities.
      - Remote call made via httpServiceProvider (IDioWrapper.get) with sla: EndpointSla.standard. NEVER import raw dio.
      - Add the endpoint to AppUries in lib/core/network/api_endpoints.dart (Uri get clinicalHistory => _base.replace(path: '$_userPath/clinical-history')).
      - Offline behavior: repository tries remote first; on network-related failure falls back to local cache (IClinicalHistoryStore via clinicalHistoryStoreProvider); on remote success writes through to the cache (write-through).
      - Cache-hydration contract: the cache is populated by the auth feature at login (auth's responsibility, not this feature's). This feature only reads and refreshes it.
      - Local cache access via clinicalHistoryStoreProvider -> IClinicalHistoryStore (storeAll/loadAll) in lib/core/database/tables/clinical_history_providers.dart.
