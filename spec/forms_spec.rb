$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'

describe "A Form with a TextField" do
  before do
    class TextFieldForm < Form
      @@text_field = TextField.new("Herp some derps")
    end
    @text_form = TextFieldForm.new
    @text_field = @text_form.fields[0]

    class DefaultAttributesForm < Form
      def redefine_defaults
        { :wrapper => :span, :wrapper_attributes => {:class => :some_herps} }
      end

      @@text_field = TextField.new("Herp some derps")
    end

    @default_attributes_form = DefaultAttributesForm.new
    @default_attributes_field = @default_attributes_form.fields[0]
  end


  it "should be able to select a Hash of field attributes" do
    @text_form.get_group(:text_field)[:field].should == "<input type='text' name='text_field' id='id_text_field' />"
  end

  it "should be able to select individual label tags" do
    @text_form.get_group(:text_field)[:label_tag].should == "<label for='id_text_field'>Herp some derps</label>"
  end

  it "should be able to get individual fields" do
    @text_form.get(:field, :text_field).should == "<input type='text' name='text_field' id='id_text_field' />"
  end

  it "should be able to get individual labels" do
    @text_form.get(:label_tag, :text_field).should == "<label for='id_text_field'>Herp some derps</label>"
  end

  it "should wrap fields with <p> tags by default" do
    @text_form.to_html.should == "<p>#{@text_field.to_labeled_html}</p>"
  end

  it "should wrap fields with anything else on request" do
    @text_form.to_html(:span).should == "<span>#{@text_field.to_labeled_html}</span>"
    @text_form.to_html(:div).should == "<div>#{@text_field.to_labeled_html}</div>"
  end

  it "should accept a hash of attributes for the wrapping tag" do
    @text_form.to_html(:p, {:class => :some_herps}).should == "<p class='some_herps'>#{@text_field.to_labeled_html}</p>"
    @text_form.to_html(:p, {:class => :some_herps, :id => "le_id"}).should == "<p class='some_herps' id='le_id'>#{@text_field.to_labeled_html}</p>"
  end

  it "should accept overrides to the defaults" do
    @default_attributes_form.to_html.should == "<span class='some_herps'>#{@text_field.to_labeled_html}</span>"
  end

end 


describe "A more complicated form with multiple fields" do

  before do
    class MoreComplicatedForm < Form
      @@description_of_derps = TextField.new("Herp some derps", nil, :help_text => "Explain how the derps were herped")
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"])
      @@cat = CheckboxField.new("Are you a cat?", :checked => :checked )
      @@family = ChoiceField.new("Choose a family", ['Capulet', 'Montague', "Other"])

      def redefine_defaults
        { :wrapper => :div, :wrapper_attributes => {:class => "more_complicated"} }
      end

    end

    @more_complicated_form = MoreComplicatedForm.new
    @description_of_derps_field = @more_complicated_form.get_field(:description_of_derps)
    @gender_choice_field = @more_complicated_form.get_field(:gender_choice)
    @cat_field = @more_complicated_form.get_group(:cat)[:field]
    @family_field = @more_complicated_form.get_field(:family)
  end

  it "should generate four <divs> with the class 'more_complicated'" do
    Nokogiri::HTML(@more_complicated_form.to_html).search('div.more_complicated').length.should == 4
  end

  it "should produce a properly formatted form" do
    @more_complicated_form.to_html.should == [
      "<div class='more_complicated'>",
      "<label for='id_description_of_derps'>Herp some derps</label><input type='text' name='description_of_derps' id='id_description_of_derps' />",
      "<div class='help_text' id='id_description_of_derps_help_text'>Explain how the derps were herped</div>",
      "</div>",
      "<div class='more_complicated'>",
      "<label for='id_gender_choice'>Choose your gender</label>",
      "<fieldset id='id_gender_choice'>",
      "<legend>Choose your gender</legend>",
      "<input type='radio' id='id_gender_choice_male' value='Male' name='gender_choice' /><label for='id_gender_choice_male'>Male</label>",
      "<input type='radio' id='id_gender_choice_female' value='Female' name='gender_choice' /><label for='id_gender_choice_female'>Female</label>",
      "</fieldset>",
      "</div>",
      "<div class='more_complicated'>",
      "<input checked='checked' type='checkbox' name='cat' id='id_cat' /><label for='id_cat'>Are you a cat?</label>",
      "</div>",
      "<div class='more_complicated'>",
      "<label for='id_family'>Choose a family</label>",
      "<select id='id_family' name='family'>",
      "<option value='Capulet'>Capulet</option>",
      "<option value='Montague'>Montague</option>",
      "<option value='Other'>Other</option>",
      "</select>",
      "</div>"].join
  end

end
