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

  Scenario: Jerk who doesn't use proper punctuation
    Given I am on the "new user" page
    And I enter "herpington" as my First Name
    And I enter "b" as my Middle Initial
    And I select "Capulet" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "normal veronan cat" as my Bio
    And I affirm that I am a cat
    And I submit the User form
    Then a user named "Herpington" should be saved

  Scenario: Creating a user without supplying a name
    Given I am on the "new user" page
    And I enter "" as my First Name
    And I enter "" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Veronan" as my Bio
    And I deny that I am a cat
    And I submit the User form
    Then an error reading "Input must be at least 2 characters." should be displayed on the First Name field
    And there should be exactly 1 error displayed on the First Name field
    And the First Name field should still read ""
    And the Middle Initial field should still read ""
    And the Last Name field should still be set to "Montague"
    And "Male" should still be chosen as the Gender Choice
    And the Bio textarea should still read "Just your average Veronan"
    And the Cat field should not be checked 

  Scenario: Creating a user with too short of a first name
    Given I am on the "new user" page
    And I enter "I" as my First Name
    And I enter "" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Veronan" as my Bio
    And I deny that I am a cat
    And I submit the User form
    Then an error reading "Input must be at least 2 characters." should be displayed on the First Name field
    And there should be exactly 1 error displayed on the First Name field
    And the First Name field should still read "I"
    And the Middle Initial field should still read ""
    And the Last Name field should still be set to "Montague"
    And "Male" should still be chosen as the Gender Choice
    And the Bio textarea should still read "Just your average Veronan"
    And the Cat field should not be checked 

  Scenario: Creating a user who is not from Verona
    Given I am on the "new user" page
    And I enter "Jim" as my First Name
    And I enter "B" as my Middle Initial
    And I select "Montague" as my Last Name
    And I choose "Male" as my gender choice
    And I enter "Just your average Sicilian" as my Bio
    And I affirm that I am a cat
    And I submit the User form
    Then an error reading "Only Veronans allowed!" should be displayed on the Bio field
    And the First Name field should still read "Jim"
    And the Middle Initial field should still read "B"
    And the Last Name field should still be set to "Montague"
    And "Male" should still be chosen as the Gender Choice
    And the Bio textarea should still read "Just your average Sicilian"
    And the Cat field should still be checked 
    And there should be exactly 1 error displayed on the Bio field 

  Scenario: Creating a female cat
    Given I am on the "new user" page
    And I enter "Herpina" as my First Name
    And I enter "B" as my Middle Initial
    And I select "Capulet" as my Last Name
    And I choose "Female" as my gender choice
    And I enter "normal veronan cat" as my Bio
    And I affirm that I am a cat
    And I submit the User form
    Then an error reading "Male cats only!" should be displayed on the main error list
    And there should be exactly 1 error displayed on the main error list
    And there should be exactly 0 errors displayed on the Bio field
    And the First Name field should still read "Herpina"
    And the Middle Initial field should still read "B"
    And the Last Name field should still be set to "Capulet"
    And "Female" should still be chosen as the Gender Choice
    And the Bio textarea should still read "normal veronan cat"
    And the Cat field should still be checked 
