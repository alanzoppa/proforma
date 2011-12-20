#rake db:test:prepare

Given /^I am on the "([^"]*)" page$/ do |page|
  visit("/purchases/#{page.downcase}")
end

When /^I submit a purchase called "([^"]*)" that costs "([^"]*)"$/ do |purchase,cost|
  fill_in 'Purchase', :with => purchase
  fill_in 'Cost', :with => cost
  click_button "Create Purchase"
end

Then /^a purchase called "([^"]*)" that costs "([^"]*)" should be saved$/ do |purchase,cost|
  Purchase.find(:first, :conditions => "name = '#{purchase}' AND cost = #{cost.to_f}").name.should == "Anything"
end

And /^I enter a \$(\d+) purchase$/ do |cost|
  fill_in 'Cost', :with => cost.to_s
end

And /^I name my purchase "([^"]*)"$/ do |name|
  fill_in 'Purchase', :with => name
end

Then /^submit the form$/ do
  click_button "Create Purchase"
end

Then /^the object should not be saved$/ do
  puts page.body
end

Then /^an error reading "([^"]*)" should be displayed$/ do |error|
  page.body.should include error
end
