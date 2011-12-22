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
      _run_simple_validations(data)
      _run_regex_validations(data)
      _run_custom_validations(data)
      _run_whole_form_validations(data)
      _collect_errors #Should be last
    end
  end

  def _define_defaults
    # defaults for @settings below
    @settings = {:wrapper => :p, :wrapper_attributes => nil, :pretty_print => true}
    @settings = @settings.merge(redefine_defaults) if respond_to? :redefine_defaults
    @pretty_print = @settings[:pretty_print]
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
    field.attach_names!(field_name) if field.respond_to?(:attach_names!)
    field.pretty_print = @pretty_print
    field.help_text_tag = @settings[:help_text_tag] unless @settings[:help_text_tag].nil?
    field.help_text_class = @settings[:help_text_class] unless @settings[:help_text_class].nil?
    field.error_tag = @settings[:error_tag] unless @settings[:error_tag].nil?
    field.error_class = @settings[:error_class] unless @settings[:error_class].nil?
    @fields << field
  end
 
  def to_html(tag=@settings[:wrapper], attributes=@settings[:wrapper_attributes])
    output = String.new
    output += wrap_tag(@errors[:form], :div, :class => :errors) unless @errors.nil? or @errors[:form].nil?
    @fields.each do |field|
      if @pretty_print
        output += "\n" unless @errors.nil? or @errors[:form].nil?
        field_contents = "\n#{indent(field.to_full_html)}\n"
        output += wrap_tag(field_contents, tag, attributes)
        output += "\n" unless field == @fields.last and @fields.length > 1
      else
        output += wrap_tag(field.to_labeled_html, tag, attributes)
      end
    end
    return output
  end
  
end
