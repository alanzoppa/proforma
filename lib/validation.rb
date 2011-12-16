module Validation

  def _run_default_validations(data)
    @fields.each do |field|
      field.default_validation(data[field.name]) if field.respond_to?(:default_validation)
    end
  end

  def _validate_required_fields(data)
    # Set the Field's valid bit to false if a required field doesn't pass its local definition of filled?
    @fields.each do |field|
      field_data = @raw_data[field.name.to_s]
      field.complain_about_invalid_data(field_data) unless field_data.nil?
      field.invalidate! if field.required? && !field.filled?(field_data)
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
      field_data = @raw_data[field.name.to_s]
      field.regex_invalidate!(field.name.to_s) unless field.regex_matching_or_unset?(field_data)
    end
  end

  def _run_custom_validations(data)
    @fields.each do |field|
      field_data = @raw_data[field.name.to_s]
      begin
        @_cleaned_data[field.name.to_s] = self.send("cleaned_#{field.name}", field_data) if self.respond_to?("cleaned_#{field.name}")
      rescue FieldValidationError => error_message
        field.custom_invalidate!(error_message.to_s, field.name.to_s)
      end
    end
  end

  def cleaned_data
    raise InvalidFormError.new("Cleaned data is not available on an invalid form.") unless self.valid?
    output_hash = Hash.new
    @_cleaned_data.each { |k,v| output_hash[k.to_sym] = v } #back to symbol keys
    return output_hash
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
end
