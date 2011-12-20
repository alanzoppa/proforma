$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A form with fields who have interdependent validations" do
  before :each do
    class MultipleValidationTextFieldForm < Form
      @@first_number = TextField.new("First Number")
      @@second_number = TextField.new("Second Number")

      def cleaned_first_number(datum)
        raise FieldValidationError.new("Please enter an integer") unless datum == "0" || datum.to_i != 0
        return datum.to_i
      end

      def cleaned_second_number(datum)
        raise FieldValidationError.new("Please enter an integer") unless datum == "0" || datum.to_i != 0
        return datum.to_i
      end

      def cleaned_form(data)
        if self.cleaned_data[:first_number] + self.cleaned_data[:second_number] != 10
          raise FormValidationError.new("First Number and Second Number must add up to 10")
        end
        return data
      end

    end

  end


end
