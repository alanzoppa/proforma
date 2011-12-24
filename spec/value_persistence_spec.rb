$: << File.dirname(__FILE__)
$test_env = true

require "../lib/proforma"


describe "A field rendered after post" do
  before do

    class RegistrationForm < Form
      @@first_name = TextField.new("First Name", nil, :min_length=>2, :max_length=>50)
      @@middle_initial = TextField.new("Middle Initial", nil, :max_length=>1)
      @@last_name = ChoiceField.new("Choose a family", ['Capulet', 'Montague'], nil, :required=>true)
      @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"], nil, :required=>true)
      @@bio = TextAreaField.new("Bio")
      @@cat = CheckboxField.new("Are you a cat?", :checked => :checked )
      @@dog = CheckboxField.new("Are you a dog?")

      def redefine_defaults
        { :wrapper => :div, :wrapper_attributes => {:class => :field}, :hash_wrapper => :user }
      end

      def cleaned_form(data)
        raise FormValidationError.new("Male cats only!") if data[:gender_choice] == "Female" && data[:cat]
        data[:first_name].capitalize!
        data[:middle_initial].capitalize!
        return data
      end

    end

    @invalid_registration_form = RegistrationForm.new({:first_name => "Alan",
                             :middle_initial => "A",
                             :last_name => "Capulet",
                             :gender_choice => "Male",
                             :bio => "Chap from England",
                             :dog => "on" })
  end

  #it "should do that" do
    #puts @invalid_registration_form.to_html
  #end

  it "should keep the value for both TextFields" do
    @invalid_registration_form._noko_first('#id_first_name')['value'].should == "Alan"
    @invalid_registration_form._noko_first('#id_middle_initial')['value'].should == "A"
  end

  it "should persist the last name selection" do
    @invalid_registration_form._noko_first('#id_last_name option')['selected'].should == "selected"
  end

  it "should persist the gender choice" do
    @invalid_registration_form._noko_first('#id_gender_choice_male')['checked'].should == "checked"
  end

  it "should let the gender_choice fields keep their attributes" do
    @invalid_registration_form._noko_first('#id_gender_choice_male')['value'].should == "Male"
  end

  it "should persist the value of the bio field" do
    @invalid_registration_form._noko_first('#id_bio').content.should == "Chap from England"
  end

  it "should persist the state of the cat field" do
    @invalid_registration_form._noko_first('#id_cat')[:checked].should be_nil
  end

  it "should persist the state of the dog field" do
    @invalid_registration_form._noko_first('#id_dog')[:checked].should_not be_nil
  end






end

#rails g scaffold User first_name:string middle_initial:string last_name:string gender_choice:string bio:text cat:boolean
