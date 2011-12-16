require 'validation'
require 'exceptions'

class Form
  include TestModule if $test_env
  include Validation
  attr_accessor :fields, :errors, :valid

  def initialize(data=nil)
    _define_defaults
    _initialize_fields
    _prepare_getters
    unless data.nil?
      raise ArgumentError.new("You can only validate a Hash") unless data.class == Hash
      @raw_data = dup_hash_with_string_keys(data).dup # Rails creates POST hashes with string keys
      @_cleaned_data = @raw_data.dup
      _run_default_validations(data)
      _validate_required_fields(data)
      _run_regex_validations(data)
      _run_custom_validations(data)
      _run_whole_form_validations(data)
      _collect_errors #Should be last
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
    self.class.class_variables.each do |var|
      field = self.class.send("class_variable_get", var).dup # the field itself
      field_name = var.to_s.gsub(/^@@/, '') # the field's name with the leading "@@" stripped
      _attach_field_attributes(field, field_name) if field.class.ancestors.include? Field
    end
  end

  def _attach_field_attributes(field, field_name)
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
        field_contents = "\n#{indent(field.to_labeled_html)}\n"
        output += wrap_tag(field_contents, tag, attributes)
        output = "#{output}\n" unless field == @fields.last and @fields.length > 1
      else
        output += wrap_tag(field.to_labeled_html, tag, attributes)
      end
    end
    return output
  end
  
end
