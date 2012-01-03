$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A Form with required fields" do
  before do
    class MaxLengthFieldsForm < Form
      @@length_form = TextField.new(label_text="Herp some derps", {:required=>true, :max_length => 5, :min_length => 3})
    end
  end

  it "should allow submissions with 3-5 characters" do
    valid_form1 = MaxLengthFieldsForm.new(:length_form => "abc")
    valid_form1.valid?.should be_true
    valid_form2 = MaxLengthFieldsForm.new(:length_form => "abcd")
    valid_form2.valid?.should be_true
    valid_form3 = MaxLengthFieldsForm.new(:length_form => "abcde")
    valid_form3.valid?.should be_true
  end

  it "should not allow submissions with more than the specified character length" do
    invalid_form = MaxLengthFieldsForm.new(:length_form => "abcdef")
    invalid_form.valid?.should be_false
  end

  it "should return the default max length error message" do
    invalid_form = MaxLengthFieldsForm.new(:length_form => "abcdef")
    invalid_form.get_instance(:length_form).errors.should include "Input is limited to 5 characters."
  end

  it "should not allow submissions less than the specified character length" do
    invalid_form = MaxLengthFieldsForm.new(:length_form => "ab")
    invalid_form.valid?.should be_false
  end 

  it "should return the default max length error message" do
    invalid_form = MaxLengthFieldsForm.new(:length_form => "ab")
    invalid_form.get_instance(:length_form).errors.should include "Input must be at least 3 characters."
  end

end
