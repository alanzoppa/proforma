module Validation

  def _validate_required_fields(data)
    raise ArgumentError.new("You can only validate a Hash") unless data.class == Hash
    @raw_data = dup_hash_with_string_keys(data) # Rails creates POST hashes with string keys

    # Set the Field's valid bit to false if a required field doesn't pass its local definition of filled?
    @fields.each do |field|
      field_data = @raw_data[field.name.to_s]
      field.complain_about_invalid_data(field_data) unless field_data.nil?
      field.invalidate! if field.required? && !field.filled?(field_data)
    end
  end

  def is_valid?
    # If the valid bit is true for all fields, the form is valid
    return @fields.all? {|field| field.valid? == true}
  end

  def _collect_errors
    @errors = Hash.new
    @fields.each do |f|
      @errors[f.name] = f.errors unless f.errors.empty?
    end
  end

  def _run_regex_validations(data)
    @fields.each do |field|
      field_data = @raw_data[field.name.to_s]
      field.regex_invalidate! unless field.regex_matching_or_unset?(field_data)
    end
  end
end


module FieldValidation
  def required?
    self.required
  end

  def valid?
    self.valid
  end

  def regex_invalidate!
    @valid = false
    @errors << @opts[:regex_error]
  end

  def regex_matching_or_unset?(field_data)
    # No need to invalidate if there is no regex set
    return @opts[:regex].nil? || !field_data.match(@opts[:regex]).nil?
  end
end
