#rake db:test:prepare

Given /^I am on the "([^"]*) ([^"]*)" page$/ do |action,controller|
  visit("/#{controller.downcase}s/#{action.downcase}")
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

Then /^I submit the (.*) form$/ do |model|
  click_button "Create #{model}"
end

#Then /^the object should not be saved$/ do
  #puts page.body
#end

Then /^an error reading "([^"]*)" should be displayed$/ do |error|
  page.body.should include error
end

Given /^an error reading "([^"]*)" should be displayed on the (.*) field$/ do |error, field|
  field = field.downcase.gsub(' ', '_')
  error_list = all("#id_#{field}_errors li").map {|e| e.text }
  error_list.should include error
end

Given /^there should be exactly (\d+) errors? displayed on the (.*) field$/ do |error_count, field|
  error_count = error_count.to_i
  field = field.downcase.gsub(' ', '_')
  error_list = all("#id_#{field}_errors li").map {|e| e.text }
  error_list.length.should == error_count
end

Given /^an error reading "([^"]*)" should be displayed on the main error list$/ do |error|
  error_list = all(".form_errors li").map {|e| e.text }
  error_list.should include error
end

Given /^there should be exactly (\d+) errors? displayed on the main error list$/ do |error_count|
  error_count = error_count.to_i
  error_list = all(".form_errors li").map {|e| e.text }
  error_list.length.should == error_count
end
