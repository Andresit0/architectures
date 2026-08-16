feature: clinical_history
actors:
  - Authenticated Patient
description: Authenticated patient views their clinical history as a list of encounters (service, facility, professional, date, summary, diagnosis, observations, attachments, state), loaded from a dedicated endpoint with offline cache fallback and pull-to-refresh.
rules:
  - Only authenticated patients can access the clinical history screen (route is behind AuthGuard).
  - The list is loaded from the dedicated endpoint GET /user/clinical-history with Bearer authentication.
  - If the network request fails for a connectivity reason and cached data exists, the cached list is shown instead.
  - On a successful network load, the fetched list is written through to the local cache (write-through) so it is available offline next time.
  - Pull-to-refresh forces a fresh network fetch and updates both the list and the cache.
  - Each encounter shows at least service name, facility name and city, encounter date, and state label.
  - Tapping an encounter expands inline details: professional (fullname/specialty), summary, description, diagnosis (code/name), observations, and attachments (name/type).
  - An empty list shows an empty-state message with a retry action.
  - Failure messages are localized via localizeError() — never raw error.message.
  - The logout action is injected via an onLogout callback — the feature never imports features/auth.
  - The cache is hydrated by auth at login (auth's concern, not this feature's).
flows:
  - name: view_clinical_history
    steps:
      - Patient is authenticated and the app navigates to /clinical-history.
      - Screen requests the encounter list (online-first: remote first, cache fallback only on a genuine connectivity failure).
      - On success: system shows the list of encounter cards and writes the data to the local cache.
      - On connectivity failure with cached data: system shows the cached list.
      - On failure without cache: system shows a localized error and allows retry.
  - name: pull_to_refresh
    steps:
      - Patient is viewing the loaded list.
      - Patient pulls down to refresh.
      - System performs a forced network fetch and writes through the cache.
      - On success: list updates with fresh data.
      - On failure: system keeps the screen stable and shows a localized error snackbar, then resets to allow retry.
  - name: view_encounter_details
    steps:
      - Patient taps an encounter card.
      - Card expands to reveal professional, summary, description, diagnosis, observations and attachments.
      - Patient taps again to collapse.
edge_cases:
  - No cached data and no network: show localized network error with retry.
  - Empty remote list with empty cache: show empty-state message with retry.
  - Non-empty cache with empty remote: remote list wins, cache is overwritten with the empty list.
  - 401 during refresh: AuthInterceptor retries / force-logs-out (deferred to interceptor, not this feature).
  - Refresh failure while a list is shown: do not discard visible data until the reset flow re-loads.
  - Missing optional fields (professional, summary, description, state): render the card without those sections.
success_criteria:
  - Patient sees their encounters (service, facility + city, date, state) after navigating to /clinical-history.
  - Pull-to-refresh updates the list from the server and the cache.
  - Offline with cached data still renders the list.
  - Network failure shows a localized snackbar and offers retry.
  - Empty history shows a friendly empty state with a retry action.
  - Feature code contains zero imports from features/auth.
