$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'

describe "A form with custom validations" do
  before do
    class CustomValidationForm < Form
      @@description_of_the_derps = TextField.new("Herp some derps")
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"])
      @@cat = CheckboxField.new("Are you a cat?", :checked => :checked )
      @@family = ChoiceField.new("Choose a family", ['Capulet', 'Montague', "Other"])

      def cleaned_description_of_the_derps(datum)
        unless datum.split == ["one", "two", "three"]
          raise FieldValidationError.new("This is invalid input")
        end
        return datum
      end

    end

  end

  it "should have a validation error unless the input is 'one two three'" do
    invalid_form = CustomValidationForm.new({:description_of_the_derps => "two three four"})
    invalid_form.get_instance(:description_of_the_derps).errors.should include "This is invalid input"
  end

end
