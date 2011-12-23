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
        if data[:first_number] == 1 && data[:second_number] == 9
          data = FormHash.import({:first_number => 5, :second_number => 5, :new_thing => "Chumpy"})
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
    form.errors[:form].should include "First Number and Second Number must add up to 10"
  end

  it "should not complain if the numbers sum to 10" do
    form = MultipleValidationTextFieldForm.new({:first_number => "3", :second_number => "7"})
    form.valid?.should be_true
    form.errors.empty?.should be_true
  end

  it "should preserve the coerced output of cleaned_whatever" do
    form = MultipleValidationTextFieldForm.new({:first_number => "3", :second_number => "7"})
    form.cleaned_data[:first_number].class.should == Fixnum
    form.cleaned_data[:second_number].class.should == Fixnum
  end

  it "should not render div.errors when the input is valid" do
    form = MultipleValidationTextFieldForm.new({:first_number => "3", :second_number => "7"})
    form._noko_first(:div).should be_nil
  end

  it "should print the errors, if any, by default" do
    form = MultipleValidationTextFieldForm.new({:first_number => "3", :second_number => "6"})
    form._noko_first(:ul)[:class].should == "form_errors"
    form._noko_first('ul.form_errors li').content.should include "First Number and Second Number must add up to 10"
  end

  it "should set both numbers to 5 and add stuff to cleaned data if the first is 1 and the second is 9" do
    form = MultipleValidationTextFieldForm.new({:first_number => "1", :second_number => "9"})
    form.cleaned_data[:first_number].should == 5
    form.cleaned_data[:second_number].should == 5
    form.cleaned_data[:new_thing].should == "Chumpy"
  end
end



describe "A form that shouldn't exist" do
  before do
    class FatallyFlawedForm < Form
      @@form = TextField.new("First Number")
    end
  end

  it "should raise an error if someone calls a field 'form'" do
    lambda { FatallyFlawedForm.new }.should raise_error(FormImplementationError, "Fields cannot be named 'form'")
  end

end
