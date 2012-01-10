$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'

describe "instantiating a form with custom defaults" do
  before do
    class CustomValidationForm < Form
      @@description_of_the_derps = TextField.new("Herp some derps", :help_text => "Explain how derps were herped.")
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"])
      @@cat = CheckboxField.new("Are you a cat?", :html_attributes => {:checked => :checked} )
      @@family = ChoiceField.new("Choose a family", ['Capulet', 'Montague', "Other"])
      @@bio = TextAreaField.new("Bio")
    end
  end

  it "should set the value of the description_of_the_derps field as given" do
    @custom_defaults_form = CustomValidationForm.new.with_defaults( :description_of_the_derps => "derps were herped effectively")
    @custom_defaults_form.get_instance(:description_of_the_derps)._noko_first(:input)[:value].should == "derps were herped effectively"
  end

  it "should set the value of the bio field" do
    @custom_defaults_form = CustomValidationForm.new.with_defaults(:bio => "Blinded in The Event")
    @custom_defaults_form.get_instance(:bio)._noko_first(:textarea).content.should == "Blinded in The Event"
  end

  #it "should set the value of the gender_choice field as given" do
    #@custom_defaults_form = CustomValidationForm.new.with_defaults(:gender_choice => "Female")
    #puts @custom_defaults_form.get_instance(:gender_choice).to_html
  #end
  
  it "should null the checked value of the cat field if passed false" do
    @custom_defaults_form = CustomValidationForm.new.with_defaults( :cat => false )
    @custom_defaults_form.get_instance(:cat)._noko_first(:input)[:checked].should be_nil
  end

  it "should set the checked value of the cat field if passed true" do
    @custom_defaults_form = CustomValidationForm.new.with_defaults( :cat => true)
    @custom_defaults_form.get_instance(:cat)._noko_first(:input)[:checked].should == "checked"
  end

  it "should set the value of the family field as given" do
    @custom_defaults_form = CustomValidationForm.new.with_defaults(:family => "Montague")
    @custom_defaults_form.get_instance(:family)._noko_nth(:option, 1)[:selected].should == "selected"
  end
 

  #it "should set the value of the family field as given"



end


