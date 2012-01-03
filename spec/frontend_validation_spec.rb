$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'



describe "A Form with a TextField" do
  before :each do
    class FrontendValidationForm < Form
      @@first_name = TextField.new("Enter your name", nil, :default=>"Fred", :regex => /^F/, :regex_error => "First names must start with \"F\"")
      @@last_name = TextField.new("Enter your name", nil, :default=>"Jones", :required => true)
      @@party = ChoiceField.new("Choose a family", ["", 'Tory', 'Labour'], nil, :default=>"Labour")
      @@about_me = TextAreaField.new("Brief bio", nil, :default=>"Nothing important")

      def redefine_defaults
        {:frontend_validation => true}
      end
    end

    @frontend_validation_form = FrontendValidationForm.new
  end

  it "should include data-regex attributes on text fields when @opts[:frontend_validation] == true" do
    @frontend_validation_form.get_instance(:first_name)._noko_first(:input)['data-regex'].should == "/^F/"
  end

  it "should include data-regex attributes on text fields when @opts[:frontend_validation] == true" do
    @frontend_validation_form.get_instance(:first_name)._noko_first(:input)['data-regex_error'].should == "First names must start with \"F\""
  end

  #it "should add 'required' as a CSS class to required fields" do
    #@frontend_validation_form.to_html
  #end
 
end
