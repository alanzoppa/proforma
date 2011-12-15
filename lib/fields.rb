$: << File.dirname(__FILE__)
require '../spec/test_module' if $test_env
require 'helpers'
require 'exceptions'
require 'validation'

class Field
  include TestModule if $test_env
  include FieldValidation
  attr_accessor :type, :label_text, :name, :help_text, :html_id, :errors, :pretty_print, :required, :valid

  def initialize(label_text=nil, attributes=nil, opts={})
    opts ||= {}
    opts = ({ :help_text => nil, :required => false }).merge(opts)
    @help_text, @required = opts[:help_text], opts[:required]
    @type = self.class.to_s.gsub(/Field$/, '').downcase
    @valid = true
    @label_text, @attributes, = label_text, attributes
  end

  def html_id
    "id_#{@name}".to_sym
  end

  def to_html
    value_pairs = @attributes.nil? ? Hash.new : @attributes.dup
    value_pairs[:type] = @type
    value_pairs[:name] = self.name
    value_pairs[:id] = self.html_id
    return "<input #{flatten_attributes value_pairs} />"
  end

  def label_tag
    wrap_tag(label_text, :label, {:for => html_id})
  end

  def to_labeled_html
    label_tag + to_html
  end

  def complain_about_invalid_data(datum)
    raise ArgumentError.new("A #{self.class} expects a #{String} as validation input") unless datum.class == String
  end

  def filled?(datum)
    #If this returns true, the field is filled
    !datum.nil? && !datum.empty?
  end

end

class TextField < Field
end

class CheckboxField < Field
  def to_labeled_html
    to_html + label_tag
  end

  def complain_about_invalid_data(datum)
    raise ArgumentError.new("#{self.class} validation data must be a boolean") unless [TrueClass, FalseClass].include?(datum.class)
  end

  def filled?(datum)
    return false if datum.nil?
    return false if datum.class == FalseClass
    return true if datum.class == TrueClass
  end
end

class ChoiceField < Field
  def initialize(label_text=nil, values=nil, attributes=nil, opts={})
    super(label_text, attributes, opts)
    @values = values
  end

  def filled?(datum)
    @values.include?(datum)
  end

  def _html_options
    html_options = @values.map { |v|
      tag = wrap_tag(v, :option, {:value => v})
      tag = tag.template("\n  %s") if @pretty_print
    }.join
  end

  def to_html
    option_fields = _html_options
    option_fields = option_fields.template("%s\n") if @pretty_print
    output = wrap_tag(option_fields, :select, {:id => html_id, :name => @name})
    output = output.indent(0).template("\n%s") if @pretty_print
    return output
  end
end

class RadioField < Field
  def initialize(value=nil, attributes = Hash.new, opts={})
    super(label_text=nil, attributes=attributes, opts=opts)
    @label_text, @value = value, value
    @attributes[:value] = @value.downcase
  end

  def html_id
    "id_#{@name}_#{@value}".downcase
  end

  def to_labeled_html
    output = to_html + label_tag
    output = output.indent.template("%s\n") if @pretty_print
    return output
  end
end

class RadioChoiceField < Field
  attr_accessor :fields

  def initialize(label_text=nil, values=nil, attributes=nil, opts={})
    super(label_text, attributes, opts)
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
    @fields.each {|field| field.name = name }
  end

  def _html_options
    @fields.map { |v|
      @pretty_print ? v.to_labeled_html.indent.template("%s\n") : v.to_labeled_html 
    }.join
  end

  def fieldset_legend
    tag = wrap_tag(label_text, :legend)
    @pretty_print ? tag.indent.template("\n%s\n") : tag
  end

  def to_html
    ( @pretty_print ? "\n" : "" ) + wrap_tag(fieldset_legend + self._html_options, :fieldset, {:id => html_id})
  end
end
