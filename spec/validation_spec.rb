$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A Form with a TextField" do
  before do
    class TextFieldForm < Form
      @@text_field = TextField.new(label_text="Herp some derps", attributes=nil, help_text=nil, required='true')
    end

    @invalid_form = TextFieldForm.new({:text_field => ""})
    @valid_form = TextFieldForm.new({:text_field => "Any string"})
  end
 
  it "should complain if you intialize with something other than a Hash or nil" do
    lambda { TextFieldForm.new("anything else") }.should raise_error(RuntimeError, "You can only validate a Hash")
  end

  it "should not complain if the text field is filled" do
    @valid_form.is_valid?.should be_true
  end

  it "should complain if the text field is not filled" do
    @invalid_form.is_valid?.should be_false
  end
end
