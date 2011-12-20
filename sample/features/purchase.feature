Feature: Adding purchases
  I want to be able to create purchases

  Scenario: Creating a purchase
    Given I am on the "New" page
    When I input valid data
    Then the object should be saved

  Scenario: Attempting to submit without filling in the 'cost' field
    Given I am on the "New" page
    When I enter a $50 purchase
    Then submit the form
    Then the object should not be saved

  #Scenario: Creating a purchase over $100
    #Given I am on the "New" page
    #When I enter a $101 purchase
    #Then the object should not be saved

