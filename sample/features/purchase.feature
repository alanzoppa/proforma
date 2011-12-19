Feature: My Account
  I want to be able to create purchases

  Scenario: Taking out money
    Given I am on the "New" page
    When I input valid data
    Then the object should be saved
    #Given I have an account
    #And it has a balance of 100
    #When I take out 10
    #Then my balance should be 90
