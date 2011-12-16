$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'

describe "A form with custom validations" do
  before :each do
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
    @invalid_custom_validation_form = CustomValidationForm.new({:description_of_the_derps => "two three four"})
    @invalid_custom_validation_form.get_instance(:description_of_the_derps).errors.should include "This is invalid input"
  end

  it "should raise an error on the cleaned_data attribute" do
    @invalid_custom_validation_form = CustomValidationForm.new({:description_of_the_derps => "two three four"})
    lambda { @invalid_custom_validation_form.cleaned_data }.should raise_error(InvalidFormError, "Cleaned data is not available on an invalid form.")
  end

  it "should accept input that passes the test" do
    @valid_form = CustomValidationForm.new({:description_of_the_derps => "one two three"})
    @valid_form.get_instance(:description_of_the_derps).errors.length.should == 0
  end

  it "should return cleaned_data for a valid form with only the validated field passed" do
    @valid_form1 = CustomValidationForm.new({:description_of_the_derps => "one two three"})
    @valid_form1.cleaned_data.should == {:description_of_the_derps => "one two three"}
  end

  it "should return cleaned_data for a valid form with multiple fields passed" do
    post_data = { :description_of_the_derps => "one two three", :gender_choice => "Male", :family => "Montague", :cat => true}
    @valid_form2 = CustomValidationForm.new(post_data)
    @valid_form2.cleaned_data.should == post_data
  end

end
