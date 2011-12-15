$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A text form with required validations" do
  before do
    class RegexForm < Form
      @@text_field = TextField.new(label_text="Herp some derps", attributes=nil, opts={:regex=>/^foo/})
    end
  end

  it "should complain when input doesn't match the passed RegExp" do
    invalid_input_form = RegexForm.new({'text_field' => "bar"})
    invalid_input_form.get_instance(:text_field).errors.should include "'Herp some derps' contains invalid input"
  end

  it "should not complain when input matches the passed RegExp" do
    valid_input_form = RegexForm.new({'text_field' => "foobar"})
    valid_input_form.get_instance(:text_field).errors.length.should == 0
  end
end




describe "A text form with required validations and custom error messages" do
  before do
    class CustomRegexForm < Form
      @@text_field = TextField.new(label_text="Herp some derps", attributes=nil, opts={:regex=>/^foo/, :regex_error => "Entry should start with 'foo'"})
    end
  end

  it "should complain when input doesn't match the passed RegExp" do
    invalid_input_form = CustomRegexForm.new({'text_field' => "bar"})
    invalid_input_form.get_instance(:text_field).errors.should include "Entry should start with 'foo'"
  end

  it "should not complain when input matches the passed RegExp" do
    valid_input_form = CustomRegexForm.new({'text_field' => "foobar"})
    valid_input_form.get_instance(:text_field).errors.length.should == 0
  end
end

