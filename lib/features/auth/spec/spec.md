feature: auth
actors:
  - Patient
description: Authentication system supporting email/password login, token-based session management, auto-login from stored credentials, and secure logout.
rules:
  - Password is SHA-256 hashed client-side before being sent to the server.
  - Invalid credentials always return HTTP 401 with no distinction between "user not found" and "wrong password".
  - "Remember me" checkbox is unchecked by default.
  - Token refresh is attempted before auto re-login.
  - On logout, secure storage AND sembast database (session, clinical_history) are cleared.
flows:
  - name: manual_login
    steps:
      - User enters email and password on login screen.
      - System hashes password client-side with SHA-256.
      - System POSTs email + passwordHash to /user/login.
      - On 200: system stores token in secure storage, stores patient info and clinical history in sembast, and navigates to /clinical_history.
      - On 401: system shows "Invalid credentials" error.
      - On network error: system shows appropriate failure message.
      - If "Remember me" is checked, system also saves session (patient fullname + token) to sembast and stores clinical history in sembast.
  - name: auto_login_from_stored_credentials
    steps:
      - App starts.
      - System checks for stored token.
      - If token exists and is not expired, system navigates to /clinical_history.
      - If token is expired, system POSTs to /user/refreshtoken with current token as Bearer.
      - If refresh succeeds, system stores new token and navigates to /clinical_history.
      - If refresh fails with 401, system attempts auto re-login with stored email + passwordHash.
      - If re-login succeeds, system stores new token and navigates to /clinical_history.
      - If re-login also fails, system clears secure storage and shows login screen.
      - If no token or no stored credentials, system shows login screen.
  - name: logout
    steps:
      - User taps logout button.
      - System clears secure storage (token, email, passwordHash).
      - System clears sembast database (patient, attentions).
      - System navigates to login screen.
edge_cases:
  - Token expired mid-session: not handled here (deferred to interceptor).
  - No stored credentials on refresh failure: show login screen, no re-login attempt.
  - Network error during refresh: treat as failure, fall through to re-login attempt.
  - "Remember me" unchecked: email and passwordHash are NOT persisted.
  - App started with no token: login screen shown directly.
  - App started with valid token: navigated directly to /clinical_history.
success_criteria:
  - Patient can log in with valid email and password.
  - Patient sees "Invalid credentials" on bad credentials.
  - Patient is automatically logged in on app restart if "Remember me" was checked.
  - Patient is logged out and all data cleared on explicit logout.
  - Token refresh happens transparently before attempting re-login.
