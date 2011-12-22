Feature: Adding purchases
  I want to be able to create purchases

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
