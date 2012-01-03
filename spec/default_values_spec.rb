$: << File.dirname(__FILE__)
$test_env = true
require "../lib/proforma"


describe "A Form with default values via GET" do
  before do
    class DefaultValuesForm < Form
      @@first_name = TextField.new("Enter your name", :default=>"Fred")
      @@last_name = TextField.new("Enter your name", :default=>"Jones")
      @@party = ChoiceField.new("Choose a family", ["", 'Tory', 'Labour'], :default=>"Labour")
      @@about_me = TextAreaField.new("Brief bio", :default=>"Nothing important")
    end

    @default_values_get = DefaultValuesForm.new
  end

  it "should render default values on TextFields" do
    @default_values_get.get_instance(:first_name)._noko_first(:input)[:value].should == "Fred"
    @default_values_get.get_instance(:last_name)._noko_first(:input)[:value].should == "Jones"
  end

  it "should render default values on ChoiceFields" do
    @default_values_get.get_instance(:party)._noko_first('option[selected=selected]').content.should == "Labour"
  end

  it "should render default values on TextAreaFields" do
    @default_values_get.get_instance(:about_me)._noko_first(:textarea).content.should == "Nothing important"
  end

end



describe "A Form with default values via POST" do
  before do
    class DefaultValuesForm < Form
      @@first_name = TextField.new("Enter your name", :default=>"Fred")
      @@last_name = TextField.new("Enter your name", :default=>"Jones")
      @@party = ChoiceField.new("Choose a family", ["", 'Tory', 'Labour'], :default=>"Labour")
      @@about_me = TextAreaField.new("Brief bio", :default=>"Nothing important")
    end

    @default_values_post = DefaultValuesForm.new({
      :first_name => "Tom",
      :last_name => "Smith",
      :party => "",
      :about_me => "Important stuff",
      :other_thing => "Thing 3" })
  end

  it "should render posted values on TextFields" do
    @default_values_post.get_instance(:first_name)._noko_first(:input)[:value].should == "Tom"
    @default_values_post.get_instance(:last_name)._noko_first(:input)[:value].should == "Smith"
  end

  it "should render posted values on ChoiceFields" do
    @default_values_post.get_instance(:party)._noko_first('option[selected=selected]').content.should == ""
  end

  it "should render posted values on TextAreaFields" do
    @default_values_post.get_instance(:about_me)._noko_first(:textarea).content.should == "Important stuff"
  end

end
