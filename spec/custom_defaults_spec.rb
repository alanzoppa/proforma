$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'

describe "instantiating a form with custom defaults" do
  before do
    class CustomValidationForm < Form
      @@description_of_the_derps = TextField.new("Herp some derps", :help_text => "Explain how derps were herped.")
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"])
      @@cat = CheckboxField.new("Are you a cat?", :checked => :checked )
      @@family = ChoiceField.new("Choose a family", ['Capulet', 'Montague', "Other"])
    end
  end

  it "should set the value of the description_of_the_derps field as given" do
    @custom_defaults_spec = CustomValidationForm.new.with_defaults(
      :description_of_the_derps => "derps were herped effectively"
    )
    @custom_defaults_spec.get_instance(:description_of_the_derps).to_html
  end
end

  #it "should set the value of the gender_choice field as given"
  #it "should set the value of the cat field as given"
  #it "should set the value of the family field as given"
