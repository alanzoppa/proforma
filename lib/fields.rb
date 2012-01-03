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
    :form_settings,
    :required,
    :valid,
    :hash_wrapper_name,
    :post_data,
    :value,
    :validation_mode

  def initialize(label_text=nil, attributes=nil, opts={})
    @label_text, @attributes, = label_text, attributes
    _setup_options(opts)
    @help_text, @required = @opts[:help_text], @opts[:required]
    @type = self.class.to_s.gsub(/Field$/, '').downcase
    @valid = true
    @errors = Array.new
    @attributes ||= FormHash.new
  end

  def _setup_options(opts)
    @opts = ({
      :max_length_error => "Input is limited to #{opts[:max_length]} characters.",
      :min_length_error => "Input must be at least #{opts[:min_length]} characters.",
      :required_error => "'#{@label_text}' is required.",
      :regex_error => "'#{@label_text}' contains invalid input",
      :help_text_tag => :div,
      :help_text_class => :help_text,
      :error_tag => :ul,
      :error_class => :field_errors,
    }).merge(opts)
  end

  def _add_frontend_attributes
    @attributes['data-regex'] = @opts[:regex].inspect unless @opts[:regex].nil?
    @attributes['data-regex_error'] = @opts[:regex_error] unless @opts[:regex].nil?
    @attributes[:class] ||= ""
    #if required
      #@attributes[:class] += " required"
    #end
  end

  def html_id
    "id_#{@name}".to_sym
  end

  def to_html
    _add_frontend_attributes if @form_settings[:frontend_validation]
    value_pairs = @attributes.dup
    value_pairs[:type] = @type
    value_pairs[:name] ||= self.hash_wrapper_name
    value_pairs[:name] ||= self.name
    value_pairs[:id] = self.html_id
    value_pairs[:value] ||= @post_data unless @post_data.nil?
    value_pairs[:value] ||= @opts[:default] unless @opts[:default].nil?
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
      field_errors += wrap_tag(e, :li)
    end
    return wrap_tag(field_errors, @opts[:error_tag], :class => @opts[:error_class], :id => "#{html_id}_errors")
  end

  def help_text_html
    return "" if @help_text.nil? or @help_text.empty?
    field_help_text = wrap_tag(@help_text, @opts[:help_text_tag], :class => @opts[:help_text_class], :id => "#{html_id}_help_text")
    return field_help_text
  end

  def to_full_html
    return "#{error_html}#{to_labeled_html}#{help_text_html}"
  end
end

class TextField < Field
end

class TextAreaField < Field
  def to_html
    value_pairs = @attributes.dup
    value_pairs[:name] ||= self.hash_wrapper_name
    value_pairs[:name] ||= self.name
    value_pairs[:id] = self.html_id
    content ||= @post_data
    content ||= @opts[:default]
    return "<textarea #{flatten_attributes value_pairs}>#{content}</textarea>"
  end
end

class CheckboxField < Field
  def to_labeled_html
    @attributes ||= FormHash.new
    if @post_data
      @attributes[:checked] = :checked
    elsif @validation_mode
      @attributes.delete(:checked)
    end
    to_html + label_tag
  end

  def complain_about_invalid_data(datum)
    return if ["on", "off", nil, true, false, ""].include? datum
    raise ArgumentError.new("#{self.class} validation data must be a boolean.")
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

  def _is_selected?(v)
    @post_data && @post_data == v || @post_data.nil? && @opts[:default] == v
  end

  def _html_options
    html_options = @values.map { |v|
      tag_attributes = {:value => v}
      tag_attributes = tag_attributes.merge({:selected => "selected"}) if _is_selected?(v)
      tag = wrap_tag(v, :option, tag_attributes)
    }.join
  end

  def to_html
    usable_name ||= self.hash_wrapper_name
    usable_name ||= self.name
    option_fields = _html_options
    output = wrap_tag(option_fields, :select, {:id => html_id, :name => usable_name})
    return output
  end

  def default_validation(datum)
    unless @values.include?(datum) || datum.nil? || @opts[:accept_any_string]
      self.valid = false
      @errors << @opts[:default_validation_message]
    end
  end
end

class RadioChoiceField < Field
  attr_accessor :fields

  def initialize(label_text=nil, values=nil, attributes=nil, opts={})
    super(label_text, attributes, opts)
    @opts[:default_validation_message] ||= "Not an available choice"
    @values = values
  end

  def filled?(datum)
    @values.include?(datum)
  end

  def html_id
    "id_#{@name}"
  end

  def _html_options
    @values.map { |value| single_html_from_value(value) + single_label_tag_from_value(value) }.join
  end

  def fieldset_legend
    wrap_tag(label_text, :legend)
  end

  def to_html
    wrap_tag(fieldset_legend + self._html_options, :fieldset, {:id => html_id})
  end

  def default_validation(datum)
    unless @values.include?(datum) || datum.nil? || @opts[:accept_any_string]
      self.valid = false
      @errors << @opts[:default_validation_message]
    end
  end

  def single_html_from_value(value)
    value_pairs = @attributes.nil? ? Hash.new : @attributes.dup
    value_pairs.merge!({:type => :radio, :id => self.single_html_id(value), :value => value})
    value_pairs[:name] ||= self.hash_wrapper_name
    value_pairs[:name] ||= self.name
    value_pairs[:checked] = :checked if !@post_data.nil? && @post_data == value
    "<input #{flatten_attributes value_pairs} />"
  end

  def single_label_tag_from_value(value)
    wrap_tag(value, :label, {:for => single_html_id(value)})
  end

  def single_html_id(value)
    "id_#{@name}_#{value}".downcase
  end

end
