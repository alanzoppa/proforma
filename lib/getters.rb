# This isn't reused anywhere
# It's abstracted into a module to promote readability

module Getters
  def _prepare_getters
    @queryable_structures = Hash.new
    @fields.each do |field|
      @queryable_structures[field.name.to_sym] = {
        :field => field.to_html,
        :label_tag => field.label_tag,
        :help_text => field.help_text,
        :errors => field.errors,
        :instance => field
      }
    end
  end

  def get_group field
    return @queryable_structures[field.to_sym]
  end

  def get(type, field)
    return get_group(field.to_sym)[type.to_sym]
  end

  def get_field field
    return get_group(field)[:field]
  end

  def get_instance instance
    return get_group(instance)[:instance]
  end

  def get_label_tag field
    return get_group(field)[:label_tag]
  end

  def get_help_text field
    return get_group(field)[:help_text]
  end

  def get_errors field
    return get_group(field)[:errors]
  end
end
