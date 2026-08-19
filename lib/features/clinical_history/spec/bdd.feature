Feature: Clinical History

  Background:
    Given the user is authenticated and viewing /clinical_history

  Scenario: Load shows the list with service, facility, date and state
    Given the server responds with two clinical history encounters
    When the user opens the clinical history screen
    Then the screen shows a list of two encounter cards
    And each card shows the service name, facility name and city, encounter date and state label
    And the data is written through to the local cache

  Scenario: Empty history shows an empty state with retry
    Given the server responds with an empty clinical history list
    When the user opens the clinical history screen
    Then the screen shows an empty state message
    And the user can tap a retry button that reloads the list

  Scenario: Pull to refresh reloads from the server
    Given the user is viewing the loaded clinical history list
    When the user pulls down to refresh
    Then the screen requests the server again
    And the list updates with the fresh server data
    And the fresh data is written through to the local cache

  Scenario: Offline with cached data shows the cache
    Given the device has no network connectivity
    And the local cache contains previously stored encounters
    When the user opens the clinical history screen
    Then the screen shows the cached encounters instead of an error

  Scenario: Network failure shows a localized error and allows retry
    Given the device has no network connectivity
    And the local cache is empty
    When the user opens the clinical history screen
    Then the screen shows a localized error snackbar
    And the user can retry loading the list

  Scenario: Pull to refresh offline keeps the cached list
    Given the user is viewing the loaded clinical history list
    And the server fails when refreshing
    When the user pulls down to refresh
    Then the cached encounters remain visible
    And a localized error snackbar is shown
