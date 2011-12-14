$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A Form with required fields" do
  before do
    class TextFieldForm < Form
      @@text_field = TextField.new(label_text="Herp some derps", attributes=nil, help_text=nil, required=true)
      @@stupid = CheckboxField.new("Check here if stupid", attributes=nil, help_text=nil, required=false)
    end

    class CheckboxTextFieldForm < Form
      @@text_field = TextField.new(label_text="Herp some derps", attributes=nil, help_text=nil, required=true)
      @@stupid = CheckboxField.new("Check here if stupid", attributes=nil, help_text=nil, required=true)
    end

    @invalid_form = TextFieldForm.new({:text_field => ""})
    @valid_form = TextFieldForm.new({:text_field => "Any string"})
  end
 
  it "should complain if you intialize with something other than a Hash or nil" do
    lambda { TextFieldForm.new("anything else") }.should raise_error(RuntimeError, "You can only validate a Hash")
  end

  it "should be valid if the text field is filled" do
    @valid_form.is_valid?.should be_true
  end

  it "should be valid if all required fields are the required type" do
    @valid_textfield_form = TextFieldForm.new({:text_field => "Any string", :stupid => false})
    @valid_textfield_form.is_valid?.should be_true
  end

  it "should be valid if all required fields are filled" do
    @valid_checkbox_form = CheckboxTextFieldForm.new({:text_field => "Any string", :stupid => true})
    @valid_checkbox_form.is_valid?.should be_true
  end

  it "should complain if the text field is not filled" do
    @invalid_form.is_valid?.should be_false
  end

  it "should be indifferent to strings or symbols as keys" do
    @also_a_valid_form = TextFieldForm.new({'text_field' => "Any string"})
    @also_a_valid_form.is_valid?.should be_true
  end

  it "should complain if a required box is unchecked" do
    @valid_checkbox_form = CheckboxTextFieldForm.new({:text_field => "Any string", :stupid => false})
    @valid_checkbox_form.is_valid?.should be_false
  end

  it "should complain if data is invalid for a given field" do
    lambda { CheckboxTextFieldForm.new({:text_field => 123, :stupid => false}) }.should raise_error(ArgumentError)
    lambda { CheckboxTextFieldForm.new({:text_field => "some string", :stupid => "false"}) }.should raise_error(ArgumentError)
  end

  it "should not complain about nil data on a non-required field" do
    lambda { TextFieldForm.new({:text_field => 'any string', :stupid => nil}) }.should_not raise_error(ArgumentError)
  end

end

describe "A Form with a required ChoiceField" do
  before do
    class RequiredChoiceForm < Form
      @@surname = ChoiceField.new("Choose a family", ['Capulet', 'Montague'], attributes=nil, help_text=nil, required=true)
    end

  end

  it "should complain if the type for validation is incorrect" do
    lambda { RequiredChoiceForm.new({:surname => 1234567890}) }.should raise_error ArgumentError
    lambda { RequiredChoiceForm.new({:surname => ["array", :of, "whatever"]}) }.should raise_error ArgumentError
  end

  it "should complain if no data is entered" do
    @invalid_required_choice_form = RequiredChoiceForm.new({:surname => "something else"})
    @invalid_required_choice_form.is_valid?.should be_false
  end

  it "should be valid if an available family name is chosen" do
    @valid_required_choice_form = RequiredChoiceForm.new({:surname => 'Capulet'})
    @another_valid_required_choice_form = RequiredChoiceForm.new({:surname => 'Montague'})
    @valid_required_choice_form.is_valid?.should be_true
    @another_valid_required_choice_form.is_valid?.should be_true
  end

  it "should complain if something else is input somehow" do
    @invalid_required_choice_form = RequiredChoiceForm.new({:surname => 'anything else'})
    @invalid_required_choice_form.is_valid?.should be_false
  end

end
