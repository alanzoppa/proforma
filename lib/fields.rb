$: << File.dirname(__FILE__)
require '../spec/test_module' if $test_env
require 'helpers'
require 'exceptions'
require 'validation'

class Field
  include TestModule if $test_env
  include FieldValidation
  attr_accessor :type,
    :label_text,
    :name,
    :help_text,
    :errors,
    :pretty_print,
    :required,
    :valid,
    :hash_wrapper_name,
    :help_text_tag,
    :help_text_class,
    :error_tag,
    :error_class

  def initialize(label_text=nil, attributes=nil, opts={})
    @label_text, @attributes, = label_text, attributes
    _setup_options(opts)
    @help_text, @required = @opts[:help_text], @opts[:required]
    @type = self.class.to_s.gsub(/Field$/, '').downcase
    @valid = true
    @errors = Array.new
  end

  def _setup_options(opts)
    @opts = ({
      #:help_text => nil,
      #:required => false,
      :max_length_error => "Input is limited to #{opts[:max_length]} characters.",
      :min_length_error => "Input must be at least #{opts[:min_length]} characters.",
      :required_error => "'#{@label_text}' is required.",
      :regex_error => "'#{@label_text}' contains invalid input"
    }).merge(opts)
    @help_text_tag = :div
    @help_text_class = :help_text
    @error_tag = :ul
    @error_class = :field_errors
  end

  def html_id
    "id_#{@name}".to_sym
  end

  def to_html
    value_pairs = @attributes.nil? ? Hash.new : @attributes.dup
    value_pairs[:type] = @type
    value_pairs[:name] ||= self.hash_wrapper_name
    value_pairs[:name] ||= self.name
    value_pairs[:id] = self.html_id
    "<input #{flatten_attributes value_pairs} />"
  end

  def label_tag
    wrap_tag(label_text, :label, {:for => html_id})
  end

  def to_labeled_html
    label_tag + to_html
  end

  def error_html
    return "" if @errors.nil? or @errors.empty?
    field_errors = String.new
    @errors.each do |e|
      if @pretty_print
        field_errors += "\n" + indent(wrap_tag(e, :li)) + "\n"
      else
        field_errors += wrap_tag(e, :div)
      end
    end
    return wrap_tag(field_errors, @error_tag, :class => @error_class, :id => "#{html_id}_errors")
  end

  def help_text_html
    return "" if @help_text.nil? or @help_text.empty?
    field_help_text = wrap_tag(@help_text, @help_text_tag, :class => @help_text_class, :id => "#{html_id}_help_text")
    field_help_text = "#{field_help_text}\n" if @pretty_print
    return field_help_text
  end

  def to_full_html
    if @pretty_print
      output = String.new
      output += error_html + "\n" unless error_html.empty?
      output += to_labeled_html + "\n"
      output += help_text_html + "\n" unless help_text_html.empty?
      return output
    end
    return "#{error_html}\n#{to_labeled_html}\n#{help_text_html}"
  end
end

class TextField < Field
end

class TextAreaField < Field
  def to_html
    value_pairs = @attributes.nil? ? Hash.new : @attributes.dup
    value_pairs[:name] ||= self.hash_wrapper_name
    value_pairs[:name] ||= self.name
    value_pairs[:id] = self.html_id
    return "<textarea #{flatten_attributes value_pairs}></textarea>"
  end
end

class CheckboxField < Field
  def to_labeled_html
    to_html + label_tag
  end

  def complain_about_invalid_data(datum)
    return if ["on", "off"].include? datum
    raise ArgumentError.new("#{self.class} validation data must be a boolean") unless [TrueClass, FalseClass].include?(datum.class)
  end

  def filled?(datum)
    datum.class == TrueClass
  end
end

class ChoiceField < Field
  def initialize(label_text=nil, values=nil, attributes=nil, opts={})
    super(label_text, attributes, opts)
    @opts[:default_validation_message] ||= "Not an available choice"
    @values = values
  end

  def filled?(datum)
    @values.include?(datum)
  end

  def _html_options
    html_options = @values.map { |v|
      tag = wrap_tag(v, :option, {:value => v})
      tag = "\n  #{tag}" if @pretty_print
    }.join
  end

  def to_html
    usable_name ||= self.hash_wrapper_name
    usable_name ||= self.name
    option_fields = _html_options + "\n" if @pretty_print
    output = wrap_tag(option_fields, :select, {:id => html_id, :name => usable_name})
    output = "\n" + output if @pretty_print
    return output
  end

  def default_validation(datum)
    unless @values.include?(datum) || datum.nil? || @opts[:accept_any_string]
      self.valid = false
      @errors << @opts[:default_validation_message]
    end
  end
end

class RadioField < Field
  def initialize(value=nil, attributes = Hash.new, opts={})
    super(label_text=nil, attributes=attributes, opts=opts)
    @label_text, @value = value, value
    @attributes[:value] = @value
  end

  def html_id
    "id_#{@name}_#{@value}".downcase
  end

  def to_labeled_html
    output = to_html + label_tag
    output = indent(output) + "\n" if @pretty_print
    return output
  end
end

class RadioChoiceField < Field
  attr_accessor :fields

  def initialize(label_text=nil, values=nil, attributes=nil, opts={})
    super(label_text, attributes, opts)
    @opts[:default_validation_message] ||= "Not an available choice"
    @values = values
    @fields = values.map { |value| RadioField.new(value) }
  end

  def filled?(datum)
    @values.include?(datum)
  end

  def html_id
    "id_#{@name}"
  end

  def attach_names! name
    @fields.each do |field|
      field.hash_wrapper_name = self.hash_wrapper_name
      field.name = name
    end
  end

  def _html_options
    @fields.map { |v|
      @pretty_print ? indent(v.to_labeled_html) + "\n" : v.to_labeled_html 
    }.join
  end

  def fieldset_legend
    tag = wrap_tag(label_text, :legend)
    @pretty_print ? "\n#{indent(tag)}\n" : tag
  end

  def to_html
    ( @pretty_print ? "\n" : "" ) + wrap_tag(fieldset_legend + self._html_options, :fieldset, {:id => html_id})
  end

  def default_validation(datum)
    unless @values.include?(datum) || datum.nil? || @opts[:accept_any_string]
      self.valid = false
      @errors << @opts[:default_validation_message]
    end
  end

end
