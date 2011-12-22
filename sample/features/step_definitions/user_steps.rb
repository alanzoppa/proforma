Given /^I enter "([^"]*)" as my (.*)$/ do |value, label|
  fill_in label, :with => value
end

Given /^I select "([^"]*)" as my (.*)$/ do |value, label|
  label = label.downcase.gsub(' ', '_')
  select value, :from => "id_#{label}"
end

Given /^I choose "([^"]*)" as my (.*)$/ do |value, label|
  label = label.downcase.gsub(' ', '_')
  value = value.downcase.gsub(' ', '_')
  choose "id_#{label}_#{value}"
end

Given /^I (.*) that I am a cat$/ do |bool|
  if bool == "deny"
    uncheck "id_cat"
  elsif bool = "affirm"
    check "id_cat"
  end
end

Given /^a user named "([^"]*)" should be saved$/ do |name|
  puts User.find :all
  #User.find(:first, :conditions => "first_name = '#{name}'").first_name.should == name
end
