$: << File.dirname(__FILE__)
$test_env = true

require "../lib/proforma"


describe "A Low level TextField" do

  before do
    class DerpForm < Form
      @@derp_field = TextField.new("Herp some derps")
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

end

describe "A Checkbox field" do
  before do
    class UglinessForm < Form
      @@ugly = CheckboxField.new("Check here if ugly")
      @@stupid = CheckboxField.new("Check here if stupid")
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

end

describe "A Low-level RadioField" do
  #tests low level behavior. RadioFields should not be used directly.

  before do
    class DerpForm < Form
      @@gender_choice = RadioField.new("Male")
    end
    @gender_choice = DerpForm.new.fields[1]
  end


  it "should have the radio type" do
    @gender_choice._noko_first(:input)[:type].should == "radio"
  end

  it "should be the class var name" do
    @gender_choice._noko_first(:input)[:name].should == "gender_choice"
  end

  it "should have a name-based id" do
    @gender_choice._noko_first(:input)[:id].should == "id_gender_choice_male"
  end

  it "should properly create label tags and associate them to the input tag" do
    @gender_choice._noko_label_tag[:for].should == 'id_gender_choice_male'
    @gender_choice._noko_label_tag[:for].should == @gender_choice._noko_first(:input)[:id]
  end

  it "should be aware of its label text" do
    @gender_choice.label_text.should == 'Male'
  end

  it "should generate inputs with associated labels" do
    @gender_choice.to_labeled_html.should == "  <input value='male' type='radio' name='gender_choice' id='id_gender_choice_male' /><label for='id_gender_choice_male'>Male</label>\n"
  end

end

describe "The symbolize method" do
  it "should replace spaces with underscores" do
    symbolize("foo bar baz").should == :foo_bar_baz
  end
end


describe "A Low level Form" do

  before do
    class LoginForm < Form
      @@username = TextField.new("Username")
      @@password = TextField.new("Password", :class => :pw)
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
      @@future_communications = CheckboxField.new("Would you like to receive future communications", :checked => :checked )
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
    @male_field = @gender_field.fields[0]
    @female_field = @gender_field.fields[1]
  end

  it "should have sub-fields that render correctly" do
    @male_field.to_html.should == "<input value='male' type='radio' name='gender' id='id_gender_male' />"
  end

  it "should assign values based on symbolized entries in the array" do
    @female_field._noko_first(:input)[:value].should == 'female'
    @male_field._noko_first(:input)[:value].should == 'male'
  end

  it "should assign create a type='radio' field for each Array member" do
    @male_field._noko_first(:input)[:type].should == 'radio'
    @female_field._noko_first(:input)[:type].should == 'radio'
  end

  it "should name them both based on the class var" do
    @male_field._noko_first(:input)[:name].should == 'gender'
    @female_field._noko_first(:input)[:name].should == 'gender'
  end

  it "should base their ids on the class var and value" do
    @male_field._noko_first(:input)[:id].should == 'id_gender_male'
    @female_field._noko_first(:input)[:id].should == 'id_gender_female'
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
    @surname_field._html_options.should == "\n  <option value='Capulet'>Capulet</option>\n  <option value='Montague'>Montague</option>"
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
      @@cat = CheckboxField.new("Are you a cat?", :checked => :checked )
      @@family = ChoiceField.new("Choose a family", ['Capulet', 'Montague', "Other"])

      def redefine_defaults
        @__settings[:hash_wrapper] = :something
      end
    end
  end

  it "should let the user configure the hash wrapper around name attributes" do
    c = CustomNameVarForm.new
    c.fields[0]._noko_first(:input)[:name].should == "something[description_of_derps]"
  end
end
