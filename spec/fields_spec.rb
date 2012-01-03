$: << File.dirname(__FILE__)
$test_env = true

require "../lib/proforma"


describe "A Low level TextField" do

  before do
    class DerpForm < Form
      @@derp_field = TextField.new("Herp some derps", :max_length=>2)
    end
    @derp_field = DerpForm.new.fields[0]
  end

  it "should assign its name based on the class variable name" do
    @derp_field._noko_first(:input)[:name].should == 'derp_field'
  end

  it "should assign its id based on the class variable name" do
    @derp_field._noko_first(:input)[:id].should == 'id_derp_field'
  end

  it "should base the field type on the assigning class" do
    @derp_field._noko_first(:input)[:type].should == 'text'
  end

  it "should be able to template basic field types" do
    @derp_field.to_html.should == "<input type='text' name='derp_field' id='id_derp_field' />"
  end

  it "should generate its own labels" do
    @derp_field.label_tag.should == "<label for='id_derp_field'>Herp some derps</label>"
    @derp_field.label_text.should == "Herp some derps"
  end

  it "should re-insert values if validation fails" do
    d = DerpForm.new(:derp_field=>"abc")
    d._noko_first(:input)[:value].should == 'abc'
  end

end

describe "A Checkbox field" do
  before do
    class UglinessForm < Form
      @@ugly = CheckboxField.new("Check here if ugly")
      @@stupid = CheckboxField.new("Check here if stupid")

      def cleaned_form(datum)
        raise FormValidationError.new("This form is never valid")
      end
    end
    @ugliness_form = UglinessForm.new
    @ugly_field = @ugliness_form.fields[0]
    @stupid_field = @ugliness_form.fields[1]

  end

  it "should have the checkbox type" do
    @ugly_field._noko_first(:input)[:type].should == "checkbox"
    @stupid_field._noko_first(:input)[:type].should == "checkbox"
  end

  it "should generate its own labels" do
    @stupid_field.label_text.should == "Check here if stupid"
    @ugly_field.label_text.should == "Check here if ugly"
  end

  it "should give its label tag an input id based 'for'" do
    @ugly_field._noko_label_tag[:for].should == "id_ugly"
    @stupid_field._noko_label_tag[:for].should == "id_stupid"
  end

  it "should render correctly" do
    @stupid_field.to_labeled_html.should == "<input type='checkbox' name='stupid' id='id_stupid' /><label for='id_stupid'>Check here if stupid</label>"
  end

  it "should retain posted values" do
    u = UglinessForm.new(:stupid => "on", :ugly=> "on")
    #puts u.to_html
  end

end


describe "A Low level Form" do

  before do
    class LoginForm < Form
      @@username = TextField.new("Username")
      @@password = TextField.new("Password", :html_attributes => {:class => :pw})
      @@herp = "derp"
    end
    @login_form = LoginForm.new

  end

  it "should correctly report its fields in the defined order" do
    fields_as_strings = @login_form.fields.map {|f| f.to_html}
    fields_as_strings.should == [
      "<input type='text' name='username' id='id_username' />",
      "<input class='pw' type='text' name='password' id='id_password' />",
    ]
  end

  it "should accept a hash of attributes" do
    class OptInForm < Form
      @@future_communications = CheckboxField.new("Would you like to receive future communications", :html_attributes => {:checked => :checked} )
    end
    @opt_in_form = OptInForm.new

    fields_as_strings = @opt_in_form.fields.map {|f| f.to_html}
    fields_as_strings.should == [
      "<input checked='checked' type='checkbox' name='future_communications' id='id_future_communications' />"
    ]
  end

end


describe "A Form containing RadioFields" do
  before do
    class GenderForm < Form
      @@gender = RadioChoiceField.new("Choose your gender", ["Male", "Female"])
    end

    @gender_form = GenderForm.new
    @gender_field = @gender_form.fields[0]
  end

  it "should create a fieldset with an id based on the class var" do
    @gender_field._noko_first(:fieldset)[:id].should == 'id_gender'
  end

  it "should create a legend from the label text" do
    @gender_field._noko_first(:legend).content.should == "Choose your gender"
  end

end


describe "A Form containing ChoiceFields" do
  before do
    class FamilyForm < Form
      @@surname = ChoiceField.new("Choose a family", ['Capulet', 'Montague'])
    end

    @family_form = FamilyForm.new
    @surname_field = @family_form.fields[0]
  end

  it "should generate a list of html options" do
    @surname_field._html_options.should == "<option value='Capulet'>Capulet</option><option value='Montague'>Montague</option>"
  end

  it "should generate a complete select field" do
    field = @surname_field._noko_first(:select)
    field[:id].should == @surname_field.html_id.to_s
    field[:name].should == 'surname'
  end

end


describe "A field with custom wrappers" do
  before do
    class CustomNameVarForm < Form
      @@description_of_derps = TextField.new("Herp some derps")
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"])
      @@cat = CheckboxField.new("Are you a cat?", :html_attributes => {:checked => :checked} )
      @@family = ChoiceField.new("Choose a family", ['Capulet', 'Montague', "Other"])

      def redefine_defaults
        {:hash_wrapper => :something}
      end
    end
  end

  it "should create 4 fields" do
    b = CustomNameVarForm.new
    b.fields.length.should == 4
  end

  it "should let the user configure the hash wrapper around name attributes" do
    c = CustomNameVarForm.new
    c.fields.each do |field|
      #puts field.to_html
      field.to_html.match(/name='something\[#{field.name}\]'/).should_not be_nil
    end
  end
end


describe "A Textarea field" do
  before do
    class TextAreaForm < Form
      @@bio = TextAreaField.new("Herp some derps", :help_text => "Fill in this form", :min_length => 2)
    end

    @form = TextAreaForm.new
    @textarea = @form._noko_first(:textarea)
  end

  it "should render a <textarea> tag" do
    @textarea.should_not be_nil
  end

  it "should not have a type attribute by default" do
    @textarea[:type].should be_nil
  end

  it "should name itself properly" do
    @textarea[:name].should == 'bio'
  end
  
  it "generate its own id" do
    @textarea[:id].should == 'id_bio'
  end

  it "should regenerate values after posts" do
    posted_form = TextAreaForm.new({:bio => 'a'})
    posted_form.valid?.should be_false
    posted_form._noko_first(:textarea).content.should == 'a'
  end

end
