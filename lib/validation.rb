# This isn't reused anywhere
# It's abstracted into a module to promote readability

module Validation

  def _run_simple_validations(data)
    # Set the Field's valid bit to false if a required field doesn't pass its local definition of filled?
    @fields.each do |field|
      field_data = @raw_data[field.name]
      field.default_validation(field_data) if field.respond_to?(:default_validation)
      field.complain_about_invalid_data(field_data) unless field_data.nil?
      field.invalidate! if field.required? && !field.filled?(field_data)
      field.length_validation(field_data) if field.respond_to?(:length_validation)
    end
  end

  def _run_whole_form_validations(data)
    @errors = Hash.new
    self.valid = true #default
    begin
      self.cleaned_form(data) if self.respond_to?(:cleaned_form)
    rescue FormValidationError => error_message
      self.invalidate!(error_message)
    end
  end

  def invalidate!(error_message)
    # This will make it difficult if you want to validate a field called 'form'
    @errors[:form] = error_message.to_s
    @valid = false
  end

  def valid?
    # If the valid bit is true for all fields, the form is valid
    return @fields.all? {|field| field.valid? == true} && self.valid
  end

  def _collect_errors
    @fields.each { |f| @errors[f.name] = f.errors unless f.errors.empty?  }
  end

  def _run_regex_validations(data)
    @fields.each do |field|
      field_data = @raw_data[field.name]
      field.regex_invalidate!(field.name) unless field.regex_matching_or_unset?(field_data)
    end
  end

  def _run_custom_validations(data)
    @fields.each do |field|
      field_data = @raw_data[field.name]
      begin
        @_cleaned_data[field.name] = self.send("cleaned_#{field.name}", field_data) if self.respond_to?("cleaned_#{field.name}")
      rescue FieldValidationError => error_message
        field.custom_invalidate!(error_message.to_s, field.name)
      end
    end
  end

  def cleaned_data
    raise InvalidFormError.new("Cleaned data is not available on an invalid form.") unless self.valid?
    return @_cleaned_data
  end

  def _raise_usage_validations
    raise FormImplementationError.new("Fields cannot be named 'form'") if @fields.any? {|field| field.name == :form}
  end
end


module FieldValidation
  def required?
    self.required
  end

  def valid?
    self.valid
  end

  def regex_invalidate!(field_name)
    @valid = false
    @errors << @opts[:regex_error]
    @_cleaned_data.delete(field_name) if @_cleaned_data && !@_cleaned_data[field_name].nil?
  end

  def custom_invalidate!(error_message, field_name)
    @valid = false
    @errors << error_message
    @_cleaned_data.delete(field_name) if @_cleaned_data && !@_cleaned_data[field_name].nil?
  end

  def regex_matching_or_unset?(field_data)
    # No need to invalidate if there is no regex set
    return @opts[:regex].nil? || !field_data.match(@opts[:regex]).nil?
  end

  def complain_about_invalid_data(datum)
    raise ArgumentError.new("A #{self.class} expects a #{String} as validation input") unless datum.class == String
  end

  def filled?(datum)
    #If this returns true, the field is filled
    !datum.nil? && !datum.empty?
  end

  def invalidate!
    @valid = false
    @errors << @opts[:required_error]
  end

  def length_validation(datum)
    measurable_datum = datum.to_s
    if @opts[:max_length] && measurable_datum.length > @opts[:max_length]
      self.valid = false
      @errors << @opts[:max_length_error]
    elsif @opts[:min_length] && measurable_datum.length < @opts[:min_length]
      self.valid = false
      @errors << @opts[:min_length_error]
    end
  end


end
