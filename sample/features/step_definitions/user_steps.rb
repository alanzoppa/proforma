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
  User.find(:first, :conditions => "first_name = '#{name}'").first_name.should == name
end

Given /^the (.*) field should still read "([^"]*)"$/ do |field,value| #text
  field = field.downcase.gsub(' ', '_')
  page.find("input#id_#{field}")[:value].should == value
end

Given /^the (.*) textarea should still read "([^"]*)"$/ do |field,value| #textarea
  field = field.downcase.gsub(' ', '_')
  page.find("textarea#id_#{field}").text.should == value
end

Given /^the (.*) field should still be set to "([^"]*)"$/ do |field,value| #select
  field = field.downcase.gsub(' ', '_')
  page.find("#id_#{field} option[selected=selected]").text.should == value
end

Given /^the (.*) field should (.*) be checked$/ do |field,state| #select
  field = field.downcase.gsub(' ', '_')
  case state
  when "still"
    page.find("input#id_#{field}")[:checked].should == true
  when "not"
    page.find("input#id_#{field}")[:checked].should_not == true
  end
end

Given /^"([^"]*)" should still be chosen as the (.*)$/ do |value,field| #radio
  field = field.downcase.gsub(' ', '_')
  slugged_value = value.downcase.gsub(' ', '_')
  page.find("#id_#{field}_#{slugged_value}")[:checked].should == "checked"
end

    
