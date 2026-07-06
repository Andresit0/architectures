endpoints:
  - method: POST
    path: /user/login
    request:
      headers:
        Content-Type:
          format: application/json
          required: true
      body:
        email:
          type: string
          required: true
          description: Patient email address
        passwordHash:
          type: string
          required: true
          description: SHA-256 hash of the patient's password
    responses:
      200:
        body:
          patient:
            type: object
            properties:
              name: string
              id: string
            description: Patient details (name, id)
          token:
            type: object
            properties:
              type: string
              key: string
              expires_in_hours: int
              expiration_date: string (ISO 8601, nullable)
          clinical_history:
            type: array
            description: List of clinical history entries
            items:
              type: object
              properties:
                id: string
                encounter_number: string
                service: object { code: string, name: string, category: string }
                facility: object { id: string, name: string, city: string }
                professional: object { id: string, fullname: string, specialty: string } | null
                encounter_date: string
                created_at: string (ISO 8601, nullable)
                updated_at: string (ISO 8601, nullable)
                published_at: string (ISO 8601, nullable)
                summary: string | null
                description: string | null
                diagnosis: array of { code: string, name: string }
                observations: array of string
                attachments: array of { id: string, type: string, name: string, size_bytes: int, url: string }
                state: { code: string, label: string } | null
      401:
        error: unauthorized
        description: Invalid credentials — no distinction between user not found and wrong password
      500:
        error: internal_server_error
        description: Unexpected server error
    timeout: 30s
    auth: none
    notes:
      - Password is hashed client-side before sending.
      - Mock JSON file: lib/shared/jsons/auth_json.dart -> authJson.loginResponse200
      - When rememberMe=true, session (fullname + token) is saved to sembast and clinical_history data is stored in sembast.
      - When rememberMe=false, neither session nor clinical history is persisted.

  - method: POST
    path: /user/refreshtoken
    request:
      headers:
        Authorization:
          format: "Bearer <token>"
          required: true
        Content-Type:
          format: application/json
          required: true
    responses:
      200:
        body:
          token:
            type: object
            properties:
              type: string
              key: string
              expires_in_hours: int
              expiration_date: string (ISO 8601, nullable)
      401:
        error: unauthorized
        description: Token is expired or invalid — triggers auto re-login if stored credentials exist
    timeout: 30s
    auth: bearer_token
    notes:
      - Called when the stored token is expired.
      - On 401 response, the system falls back to auto re-login with stored email + passwordHash.
