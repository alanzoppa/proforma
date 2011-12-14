module Validation

  def _validate_required_fields(data)
    raise "You can only validate a Hash" unless data.class == Hash
    @raw_data = data

    self.fields.each do |field|
      if @raw_data[field.name].empty? && field.required?
        field.valid = false
      end
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
