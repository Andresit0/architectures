feature: lab_results
actors:
  - Authenticated Patient
description: Authenticated patient views their lab results (numeric tests as trend charts with reference-range bands, non-numeric tests as a flat list), loaded online-first from a dedicated endpoint with offline cache fallback, a period filter, and pull-to-refresh.
rules:
  - Only authenticated patients can access the lab results screen (route is behind AuthGuard, nested under /clinical-history).
  - Lab results are loaded from GET /user/clinical-history/lab-results with Bearer authentication. The app contains NO demo/seed data; the sample JSON in spec/samples/ is contract documentation only.
  - Loading is online-first: remote first, cache fallback ONLY on a genuine connectivity failure (no connection / server unreachable), and write-through to the local cache on remote success.
  - Pull-to-refresh is strictly remote; on failure the loaded results stay visible and a localized error snackbar is shown (no data loss, no cache fallback).
  - Logout does NOT clear the lab_results cache; only an account reset (ResetAccountUseCase) wipes it.
  - Each result is either a numeric series (dates + values → trend chart with reference-range band) or a non-numeric series (text/qualitative values → flat list).
  - Status is derived per value against the reference range: above high → High, below low → Low, within range → Normal, no range → Unknown.
  - The screen shows a test selector plus a period filter, per-test cards showing the latest value and a status chip, loading/loaded/empty/failure states, and pull-to-refresh.
  - The test selector lists ONLY numeric tests; selecting one renders its trend chart in the chart pane. All non-numeric tests render as a separate flat-list section below the chart.
  - When ALL results are non-numeric, the selector and period filter are hidden entirely; only the flat list of all non-numeric tests is shown.
  - The period filter offers 3 months / 6 months / 1 year / All, relative to the most recent data date, default All. It filters the chart data points and the flat-list values; the card's latest value and status chip ALWAYS use the most recent unfiltered value.
  - Touching a chart point shows a tooltip with the formatted date, the value with its unit, the reference range (low–high), and the derived status (Normal/High/Low).
  - Numeric values show up to 2 decimals with no unnecessary trailing zeros, plus the test's unit.
  - Chart appearance is finalized during the wrapper implementation spike; minimum requirements are a visible reference-range band and legible axes.
  - Numeric tests show a status chip derived from the latest value vs the reference range; non-numeric tests show NO chip — only the latest textual value.
  - An empty server response shows an icon + a localized message ("No hay resultados de laboratorio") + a retry button, using the EmptyState pattern from design_system.
  - A new AppBar action "Lab Results" in the clinical history screen navigates to the lab results screen at /clinical-history/lab-results (feature never imports features/clinical_history).
  - Failure messages are localized via localizeError() — never raw error.message.
  - Charts are accessed ONLY via the ITrendChart wrapper seam (core/services/charts/, trendChartProvider); feature code never imports package:fl_chart directly.
flows:
  - name: view_lab_results
    steps:
      - Patient is authenticated on the clinical history screen and taps the "Lab Results" AppBar action.
      - System navigates to /clinical-history/lab-results.
      - Screen requests the results (online-first: remote first, cache fallback only on a genuine connectivity failure).
      - On success: system shows the test selector, period filter (default All), per-test cards and chart pane, and writes the data through to the local cache.
      - On connectivity failure with cached data: system shows the cached results.
      - On failure without cache: system shows a localized error and allows retry.
  - name: select_numeric_test
    steps:
      - Patient is viewing the loaded results.
      - Patient selects a numeric test in the selector.
      - System renders the selected test's trend chart in the chart pane, filtered by the active period, with its reference-range band (when present).
  - name: change_period
    steps:
      - Patient is viewing the loaded results with at least one numeric test.
      - Patient picks 3 months / 6 months / 1 year / All.
      - System re-filters the chart data points and the flat-list values relative to the most recent data date.
      - The per-test cards keep showing the latest unfiltered value and status chip.
  - name: view_tooltip
    steps:
      - Patient is viewing a numeric test's chart.
      - Patient touches a data point.
      - System shows a tooltip with the formatted date, value + unit, reference range (low–high), and derived status.
  - name: pull_to_refresh
    steps:
      - Patient is viewing the loaded results.
      - Patient pulls down to refresh.
      - System performs a forced network fetch and writes through the cache.
      - On success: results update with fresh data (selection re-validated against the new set).
      - On failure: system keeps the loaded results visible and shows a localized error snackbar.
edge_cases:
  - All results non-numeric: selector and period filter are hidden; only the flat list of all non-numeric tests is shown.
  - A numeric result has no reference range: its status is Unknown, the card shows no status chip (or an Unknown chip), and the chart renders without a band.
  - A numeric result has fewer than two data points: the chart renders with what exists (no crash); tooltip still works per point.
  - No cached data and no network: show localized network error with retry.
  - Empty remote list with empty cache: show empty state (icon + message + retry), EmptyState from design_system.
  - Refresh failure while results are shown: do not discard visible data; keep the list and show a snackbar.
  - 401 during load/refresh: AuthInterceptor retries / force-logs-out (deferred to interceptor, not this feature).
  - Refresh returns a set that no longer contains the selected test: selection falls back to the first numeric test (or clears the chart pane when none remain).
  - Logout: session cleared but lab_results cache retained; next authenticated visit re-loads online and falls back to the same cache only on a genuine connectivity failure.
  - Account reset: lab_results cache is wiped along with the rest of the local database.
  - Values equal to the boundary (value == low or value == high) are Normal.
success_criteria:
  - Patient reaches /clinical-history/lab-results from the clinical history AppBar action and sees their lab results.
  - Numeric tests render as trend charts with a visible reference-range band; non-numeric tests render as a flat list.
  - Selecting a numeric test updates the chart pane; the period filter re-filters chart points and flat-list values while cards keep the latest unfiltered value and status.
  - Pull-to-refresh updates results from the server and the cache; on failure the loaded results stay visible with a localized snackbar.
  - Offline with cached data still renders the results; offline without cache shows a localized error with retry.
  - Empty results show the EmptyState pattern with a retry action.
  - Feature code contains zero imports from package:fl_chart, features/clinical_history, or app/ (Rules 6/11, enforced by CI).
  - The cache is not cleared on logout and is wiped on account reset.