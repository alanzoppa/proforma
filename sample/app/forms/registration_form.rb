class RegistrationForm < Form
  @@first_name = TextField.new("First Name", :min_length=>2, :max_length=>50)
  @@middle_initial = TextField.new("Middle Initial", :max_length=>1)
  @@last_name = ChoiceField.new("Choose a family", ['Capulet', 'Montague'], :required=>true)
  @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"], :required=>true)
  @@bio = TextAreaField.new("Bio", :required=>true, :min_length=>10, :max_length=>300, :regex => /Veronan/i, :regex_error => "Only Veronans allowed!")
  @@cat = CheckboxField.new("Are you a cat?", :html_attributes => {:checked => :checked} )

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

#rails g scaffold User first_name:string middle_initial:string last_name:string gender_choice:string bio:text cat:boolean
