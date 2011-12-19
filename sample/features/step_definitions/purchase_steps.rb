#rake db:test:prepare

Given /^I am on the "([^"]*)" page$/ do |arg1|
  visit('/purchases/new')
end

When /^I input valid data$/ do
  fill_in 'Purchase', :with => "Anything"
  fill_in 'Cost', :with => "5.00"
  click_button "Create Purchase"
end

Then /^the object should be saved$/ do
  Purchase.find(:first, :conditions => "name = 'Anything' AND cost = 5.00").name.should == "Anything"
end
