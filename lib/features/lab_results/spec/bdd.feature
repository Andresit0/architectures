Feature: Lab Results

  Background:
    Given the user is authenticated and has a clinical history with lab results

  Scenario: Load shows numeric cards with status chips and a non-numeric flat list
    Given the server responds with mixed lab results (numeric with a reference range, numeric without one, and non-numeric)
    When the user opens the lab results screen from the clinical history AppBar action
    Then the screen shows a numeric test selector and a period filter (default All)
    And a card per numeric test shows the latest value with its unit and a derived status chip (Normal/High/Low/Unknown)
    And all non-numeric tests render as a flat list section below the chart pane with their latest textual value and no status chip
    And the data is written through to the local cache

  Scenario: Selecting a numeric test renders its trend chart with a reference-range band
    Given the user is viewing the loaded lab results
    When the user selects a numeric test in the selector
    Then the chart pane renders that test's trend chart filtered by the active period
    And the chart shows a visible reference-range band when the test defines one

  Scenario: All results non-numeric hides the selector and period filter
    Given the server responds only with non-numeric lab results
    When the user opens the lab results screen
    Then the test selector and the period filter are hidden entirely
    And a flat list of all non-numeric tests is shown with their latest textual values

  Scenario: Empty results show an empty state with retry
    Given the server responds with an empty lab results list
    When the user opens the lab results screen
    Then the screen shows an icon and the localized message "No hay resultados de laboratorio"
    And the user can tap a retry button that reloads the results

  Scenario: Pull to refresh reloads from the server
    Given the user is viewing the loaded lab results
    When the user pulls down to refresh
    Then the screen requests the server again
    And the results update with the fresh server data
    And the fresh data is written through to the local cache

  Scenario: Pull to refresh failure keeps the loaded results and shows a localized error
    Given the user is viewing the loaded lab results
    And the server fails when refreshing
    When the user pulls down to refresh
    Then the loaded results remain visible
    And a localized error snackbar is shown