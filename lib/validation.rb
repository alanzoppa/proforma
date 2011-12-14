module Validation

  def _error_if_required_fields_missing
    @fields.each do |field|
      #raise "derp" if field.required == 'true'
    end
  end

  def is_valid?
    true
  end
end
