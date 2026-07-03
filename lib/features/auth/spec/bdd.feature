Feature: Auth

  Background:
    Given the app is installed and the user has network connectivity

  Scenario: Successful login with valid credentials
    Given the user is on the login screen
    When the user enters valid email and password and taps login
    Then the system POSTs email and passwordHash to /user/login
    And the system stores the token in secure storage
    And the system stores patient and clinical history in sembast
    And the system navigates to /clinical_history

  Scenario: Login with invalid credentials
    Given the user is on the login screen
    When the user enters invalid email or password and taps login
    Then the system receives HTTP 401
    And the system shows "Invalid credentials" error
    And the user remains on the login screen

  Scenario: Login with network error
    Given the user is on the login screen
    When the user taps login and there is no network connectivity
    Then the system shows a network failure message
    And the user remains on the login screen

  Scenario: Remember me persists credentials
    Given the user is on the login screen
    When the user enters valid credentials, checks "Remember me", and taps login
    Then the system stores email and passwordHash alongside the token in secure storage
    And the system navigates to /clinical_history

  Scenario: App start with valid stored token
    Given the user has a valid stored token
    When the app starts
    Then the system navigates directly to /clinical_history
    And the user does not see the login screen

  Scenario: App start with expired token and successful refresh
    Given the user has an expired stored token
    When the app starts
    Then the system POSTs to /user/refreshtoken with the current token as Bearer
    And the system stores the new token
    And the system navigates to /clinical_history

  Scenario: App start with expired token, failed refresh, successful re-login
    Given the user has an expired stored token and stored credentials
    When the app starts
    Then the system POSTs to /user/refreshtoken and receives 401
    And the system POSTs email and passwordHash to /user/login
    And the system stores the new token
    And the system navigates to /clinical_history

  Scenario: App start with expired token, failed refresh, failed re-login
    Given the user has an expired stored token and stored credentials
    When the app starts
    Then the system POSTs to /user/refreshtoken and receives 401
    And the system POSTs email and passwordHash to /user/login and also receives 401
    And the system clears secure storage
    And the user sees the login screen

  Scenario: App start with no stored credentials
    Given the user has no stored token and no stored credentials
    When the app starts
    Then the user sees the login screen

  Scenario: Explicit logout
    Given the user is authenticated and viewing /clinical_history
    When the user taps the logout button
    Then the system clears secure storage
    And the system clears sembast database
    And the user sees the login screen

  Scenario: Remember me unchecked after login
    Given the user is on the login screen
    When the user enters valid credentials, leaves "Remember me" unchecked, and taps login
    Then the system does NOT store email or passwordHash in secure storage
    And the system navigates to /clinical_history
