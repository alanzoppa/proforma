Feature: Adding users
  I want to be able to create users

  Scenario: Creating a new user
    Given I am on the "new user" page
    And I enter "Alan" as my First Name
    And I enter "" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Veronan" as my Bio
    And I deny that I am a cat
    And I submit the User form
    Then a user named "Alan" should be saved

  Scenario: Creating a user without supplying a name
    Given I am on the "new user" page
    And I enter "" as my First Name
    And I enter "" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Veronan" as my Bio
    And I deny that I am a cat
    And I submit the User form
    Then an error reading "'First Name' is required." should be displayed

  Scenario: Creating a user without supplying a name
    Given I am on the "new user" page
    And I enter "I" as my First Name
    And I enter "" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Veronan" as my Bio
    And I deny that I am a cat
    And I submit the User form
    Then an error reading "Input must be at least 2 characters." should be displayed

  Scenario: Creating a user without supplying a name
    Given I am on the "new user" page
    And I enter "Jim" as my First Name
    And I enter "B" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Sicilian" as my Bio
    And I affirm that I am a cat
    And I submit the User form
    Then an error reading "Only Veronans allowed!" should be displayed
