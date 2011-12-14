require 'validation'
require 'exceptions'

class Form
  include TestModule if $test_env
  include Validation
  attr_accessor :fields

  def initialize(data=nil)
    _define_defaults
    _initialize_fields
    _prepare_getters
    unless data.nil?
      _validate_required_fields(data)
    end
  end

  def redefine_defaults
    #redefine defaults per form by supering this
  end

  def _define_defaults
    # defaults for @__settings below
    @__settings = {:wrapper => :p, :wrapper_attributes => nil, :pretty_print => true}
    redefine_defaults
    @pretty_print = @__settings[:pretty_print]
  end

  def _initialize_fields
    @fields = Array.new
    self.class.class_variables.each { |v|
      # the field itself
      # the field's name cast as string with the leading "@@" stripped
      #
      field = self.class.send("class_variable_get", v).dup
      field_name = v.to_s.gsub(/^@@/, '')
      __flatten_fields(field, field_name)
    }
  end

  def __flatten_fields(field, field_name)
    #Ignore class vars which are not subclasses of Field
    ___attach_field_attributes(field, field_name) if field.class.ancestors.include? Field
  end

  def ___attach_field_attributes(field, field_name)
    field.name = field_name.to_sym
    field.attach_names!(field_name) if field.respond_to?(:attach_names!)
    field.pretty_print = @pretty_print
    @fields << field
  end

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
 
  def to_html(tag=@__settings[:wrapper], attributes=@__settings[:wrapper_attributes])
    output = String.new
    @fields.each do |field|
      if @pretty_print
        field_contents = field.to_labeled_html.indent.template("\n%s\n")
        output += wrap_tag(field_contents, tag, attributes)
        output = output.template("%s\n") unless field == @fields.last and @fields.length > 1
      else
        output += wrap_tag(field.to_labeled_html, tag, attributes)
      end
    end
    return output
  end
  
end
