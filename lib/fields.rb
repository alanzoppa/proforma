$: << File.dirname(__FILE__)
require '../spec/test_module' if $test_env
require 'helpers'
require 'exceptions'
require 'validation'
require 'json'

class Field
  include TestModule if $test_env
  include FieldValidation
  attr_accessor :type,
    :label_text,
    :name,
    :help_text,
    :errors,
    :form_settings,
    :opts,
    :valid,
    :hash_wrapper_name,
    :post_data,
    :value,
    :validation_mode

  def initialize(label_text=nil, opts={})
    @label_text  = label_text
    _setup_options(opts)
    @help_text = @opts[:help_text]
    @type = self.class.to_s.gsub(/Field$/, '').downcase
    @valid = true
    @errors = Array.new
  end

  def _setup_options(opts)
    @opts = ({
      :max_length_error => "Input is limited to #{opts[:max_length]} characters.",
      :min_length_error => "Input must be at least #{opts[:min_length]} characters.",
      :required_class => :required,
      :required_error => "'#{@label_text}' is required.",
      :regex_error => "'#{@label_text}' contains invalid input",
      :help_text_tag => :div,
      :help_text_class => :help_text,
      :error_tag => :ul,
      :error_class => :field_errors,
      :html_attributes => FormHash.new
    }).merge(opts)
  end

  def _add_required_class_if_needed
    if required?
      @opts[:html_attributes][:class] ||= ""
      @opts[:html_attributes][:class] += " #{@opts[:required_class]}" unless @opts[:html_attributes][:class].match /\b#{@opts[:required_class]}\b/
    end
  end

  def _add_frontend_attributes
    @opts[:html_attributes]['data-regex'] = escape_single_quotes(@opts[:regex].inspect) unless @opts[:regex].nil?
    @opts[:html_attributes]['data-regex_error'] = escape_single_quotes(@opts[:regex_error]) unless @opts[:regex].nil?
    @opts[:html_attributes]['data-max_length'] = @opts[:max_length] unless @opts[:max_length].nil?
    @opts[:html_attributes]['data-min_length'] = @opts[:min_length] unless @opts[:min_length].nil?
    @opts[:html_attributes]['data-max_length_error'] = escape_single_quotes(@opts[:max_length_error]) unless @opts[:max_length].nil?
    @opts[:html_attributes]['data-min_length_error'] = escape_single_quotes(@opts[:min_length_error]) unless @opts[:min_length].nil?
    _add_required_class_if_needed
  end

  def html_id
    "id_#{@name}".to_sym
  end

  def to_html
    _add_frontend_attributes if @form_settings[:frontend_validation]
    value_pairs = @opts[:html_attributes].dup
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

  def set_default!(value)
    @opts[:default] = value
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
    _add_frontend_attributes if @form_settings[:frontend_validation]
    value_pairs = @opts[:html_attributes].dup
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
    @opts[:html_attributes] ||= FormHash.new
    if @post_data
      @opts[:html_attributes][:checked] = :checked
    elsif @validation_mode
      @opts[:html_attributes].delete(:checked)
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

  def set_default!(bool)
    @opts[:html_attributes][:checked] = :checked if bool == true
    @opts[:html_attributes].delete(:checked) if bool == false
  end
end

class ChoiceField < Field
  def initialize(label_text=nil, values=nil, opts={})
    super(label_text, opts)
    @opts[:default_validation_message] ||= "Not an available choice"
    @values = values
  end

  def filled?(datum)
    @values.include?(datum)
  end

  def _is_selected?(v)
    @post_data && @post_data == v || @post_data.nil? && @opts[:default] == v
  end

  def set_default!(value)
    @opts[:default] = value
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
    @opts[:html_attributes] ||= FormHash.new
    @opts[:html_attributes] = @opts[:html_attributes].merge({:id => html_id, :name => usable_name})
    _add_required_class_if_needed
    option_fields = _html_options
    output = wrap_tag(option_fields, :select, @opts[:html_attributes])
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

  def initialize(label_text=nil, values=nil, opts={})
    super(label_text, opts)
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
    _add_required_class_if_needed
    @opts[:html_attributes][:id] = html_id
    wrap_tag(fieldset_legend + self._html_options, :fieldset, @opts[:html_attributes])
  end

  def default_validation(datum)
    unless @values.include?(datum) || datum.nil? || @opts[:accept_any_string]
      self.valid = false
      @errors << @opts[:default_validation_message]
    end
  end

  def single_html_from_value(value)
    value_pairs = @opts[:html_attributes].nil? ? Hash.new : @opts[:html_attributes].dup
    value_pairs.merge!({:type => :radio, :id => self.single_html_id(value), :value => value})
    value_pairs[:name] ||= self.hash_wrapper_name
    value_pairs[:name] ||= self.name
    if !@post_data.nil? && @post_data == value || @post_data.nil? && @opts[:default] == value
      value_pairs[:checked] = :checked 
    end
    "<input #{flatten_attributes value_pairs} />"
  end

  def single_label_tag_from_value(value)
    wrap_tag(value, :label, {:for => single_html_id(value)})
  end

  def single_html_id(value)
    "id_#{@name}_#{value}".downcase
  end

end
