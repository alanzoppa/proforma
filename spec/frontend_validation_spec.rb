$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'



describe "A Form with required fields" do
  before :each do
    class FrontendValidationForm < Form
      @@last_name = TextField.new("Enter your name", :default=>"Jones", :required => true)
      @@party = ChoiceField.new("Choose a family", ["", 'Tory', 'Labour'], :default=>"Labour", :required => true)
      @@about_me = TextAreaField.new("Brief bio", :default=>"Nothing important", :required => true)
      @@cat = CheckboxField.new("Are you a cat?", :required => true )
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"], :required => true)

      def redefine_defaults
        {:frontend_validation => true}
      end
    end

    @frontend_validation_form = FrontendValidationForm.new
  end

  it "should add 'required' as a CSS class to required text fields" do
    @frontend_validation_form.get_instance(:last_name)._noko_first(:input)[:class].should =~ /\brequired\b/
  end
 
  it "should add 'required' as a CSS class to required choice fields" do
    @frontend_validation_form.get_instance(:party)._noko_first(:select)[:class].should == "required"
  end

  it "should add 'required' as a CSS class to required textareas" do
    @frontend_validation_form.get_instance(:about_me)._noko_first(:textarea)[:class].should == "required"
  end

  it "should add 'required' as a CSS class to required checkboxes" do
    @frontend_validation_form.get_instance(:cat)._noko_first(:input)[:class].should == "required"
  end

  it "should add 'required' as a CSS class to required checkboxes" do
    @frontend_validation_form.get_instance(:gender_choice)._noko_first(:input)[:class].should == "required"
  end
end


describe "A from with lazy regex validations" do

  before :each do
    class RegistrationForm < Form
      @@first_name = TextField.new("Enter your name",
                                   :default=>"Fred",
                                   :regex => /^F/,
                                   :regex_error => "First names must start with \"F\"",
                                   :min_length => 2,
                                  )
      @@middle_initial = TextField.new("Middle Initial", :max_length=>1)
      @@last_name = ChoiceField.new("Choose a family", ['Capulet', 'Montague'], :required=>true)
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"], :required=>true)
      @@bio = TextAreaField.new("Bio", :required=>true, :min_length=>10, :max_length=>300, :regex => /Veronan/i, :regex_error => "Only Veronans allowed!")
      @@cat = CheckboxField.new("Are you a cat?", :html_attributes => {:checked => :checked} )

      def redefine_defaults
        { :wrapper => :div, :wrapper_attributes => {:class => :field}, :hash_wrapper => :user, :frontend_validation => true}
      end

      def cleaned_form(data)
        raise FormValidationError.new("Male cats only!") if data[:gender_choice] == "Female" && data[:cat]
        data[:first_name].capitalize!
        data[:middle_initial].capitalize!
        return data
      end

    end

    @registration_form = RegistrationForm.new
  end

  it "should include data-regex attributes on text fields when @opts[:frontend_validation] == true" do
    @registration_form.get_instance(:first_name)._noko_first(:input)['data-regex'].should == "/^F/"
  end

  it "should include data-regex_error attributes on text fields when @opts[:frontend_validation] == true" do
    @registration_form.get_instance(:first_name)._noko_first(:input)['data-regex_error'].should == "First names must start with \"F\""
  end

  it "should include data-min_length attributes on text fields when @opts[:frontend_validation] == true" do
    @registration_form.get_instance(:first_name)._noko_first(:input)['data-min_length'].should == "2"
  end

  it "should include data-max_length attributes on text fields when @opts[:frontend_validation] == true" do
    @registration_form.get_instance(:middle_initial)._noko_first(:input)['data-max_length'].should == "1"
  end

  it "should include data-min_length attributes on textareas when @opts[:frontend_validation] == true" do
    @registration_form.get_instance(:bio)._noko_first(:textarea)['data-min_length'].should == "10"
  end

  it "should include data-max_length attributes on textareas when @opts[:frontend_validation] == true" do
    @registration_form.get_instance(:bio)._noko_first(:textarea)['data-max_length'].should == "300"
  end




end
