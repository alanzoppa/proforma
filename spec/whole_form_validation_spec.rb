$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A from with fields who have interdependent validations" do
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

  it "should be invalid if the whole form validation doesn't pass" do
    form = MultipleValidationTextFieldForm.new({:first_number => "2", :second_number => "7"})
    form.valid?.should be_false
  end

  it "should record an error as Form.errors[:form]" do
    form = MultipleValidationTextFieldForm.new({:first_number => "2", :second_number => "7"})
    form.errors[:form].should == "First Number and Second Number must add up to 10"
  end

  it "should not complain if the numbers sum to 10" do
    form = MultipleValidationTextFieldForm.new({:first_number => "3", :second_number => "7"})
    form.valid?.should be_true
    form.errors.empty?.should be_true
  end


end
