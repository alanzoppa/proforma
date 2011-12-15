module Validation

  def _validate_required_fields(data)
    raise "You can only validate a Hash" unless data.class == Hash
    @raw_data = dup_hash_with_string_keys(data)

    @fields.each do |field|
      field_data = @raw_data[field.name.to_s]
      #puts field_data.class if field.class == CheckboxField
      field.complain_about_invalid_data(field_data) unless field_data.nil?
      field.valid = false if field.required? && !field.filled?(field_data)
    end
  end

  def is_valid?
    return @fields.all? {|field| field.valid? == true}
  end
end


module FieldValidation
  def required?
    self.required
  end

  def valid?
    self.valid
  end
end
