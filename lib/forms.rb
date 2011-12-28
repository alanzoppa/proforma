require 'validation'
require 'exceptions'
require 'getters'
require 'formhash'

class Form
  include TestModule if $test_env
  include Validation
  include Getters
  attr_accessor :fields, :errors, :valid

  def initialize(data=nil)
    _define_defaults
    _initialize_fields
    _prepare_getters
    _raise_usage_validations
    unless data.nil? # Read: If it's time to do some validation
      raise ArgumentError.new("You can only validate a Hash") unless data.class.ancestors.include?(Hash)
      @raw_data = FormHash.import(data) # Rails creates POST hashes with string keys
      @_cleaned_data = @raw_data.dup
      _run_simple_validations
      _run_regex_validations
      _run_custom_validations
      _run_whole_form_validations
      _collect_errors #Must be last
    end
  end

  def _define_defaults
    # defaults for @settings below
    @settings = {:wrapper => :p, :wrapper_attributes => nil}
    @settings = @settings.merge(redefine_defaults) if respond_to? :redefine_defaults
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
    field.hash_wrapper_name = "#{@settings[:hash_wrapper]}[#{field_name}]" unless @settings[:hash_wrapper].nil?
    field.form_settings = @settings
    @fields << field
  end
 
  def to_html(tag=@settings[:wrapper], attributes=@settings[:wrapper_attributes])
    output = String.new
    unless @errors.nil? or @errors[:form].nil?
      error_list = @errors[:form].map {|error| wrap_tag(error, :li)}.join
      output += wrap_tag(error_list, :ul, :class => :form_errors)
    end
    @fields.each do |field|
      output += wrap_tag(field.to_full_html, tag, attributes)
    end
    return output
  end
  
end
