Feature: Adding purchases
  I want to be able to create purchases

  Scenario: Creating a purchase
    Given I am on the "new purchase" page
    When I submit a purchase called "Anything" that costs "5.00"
    Then a purchase called "Anything" that costs "5.00" should be saved

  Scenario: Attempting to submit without filling in the 'cost' field
    Given I am on the "New Purchase" page
    And I enter a $50 purchase
    And I name my purchase ""
    Then submit the Purchase form
    Then an error reading "'Purchase' is required." should be displayed

  Scenario: Creating a purchase over $100
    Given I am on the "New Purchase" page
    And I enter a $101 purchase
    And I name my purchase "Some other thing"
    Then submit the Purchase form
    Then an error reading "There is a $100 limit." should be displayed

  Scenario: Creating an otherwise valid purchase named Chumpy
    Given I am on the "New Purchase" page
    And I enter a $99 purchase
    And I name my purchase "Chumpy"
    Then submit the Purchase form
    Then an error reading "You cannot name a puchase 'Chumpy.'" should be displayed

  Scenario: Creating an overpriced purchase named Chumpy
    Given I am on the "New Purchase" page
    And I enter a $200 purchase
    And I name my purchase "Chumpy"
    Then submit the Purchase form
    Then an error reading "This is right out!" should be displayed
