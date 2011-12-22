class RegistrationForm < Form
  @@first_name = TextField.new("First Name", nil, :required=>true, :min_length=>2, :max_length=>50)
  @@middle_initial = TextField.new("Middle Initial", nil, :max_length=>1)
  @@last_name = ChoiceField.new("Choose a family", ['Capulet', 'Montague'], nil, :required=>true)
  @@gender_choice = RadioChoiceField.new("Choose your gender", ["Male", "Female"], nil, :required=>true)
  @@bio = TextAreaField.new("Bio", nil, :required=>true, :min_length=>10, :max_length=>300)
  @@cat = CheckboxField.new("Are you a cat?", :checked => :checked )

  def redefine_defaults
    { :wrapper => :div, :wrapper_attributes => {:class => :field}, :hash_wrapper => :user }
  end

  def cleaned_bio(datum)
    raise FieldValidationError.new("Only Veronans allowed!") unless datum.match("Veronan")
    return datum
  end

end

#rails g scaffold User first_name:string middle_initial:string last_name:string gender_choice:string bio:text cat:boolean
