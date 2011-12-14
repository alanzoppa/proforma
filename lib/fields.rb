$: << File.dirname(__FILE__)
require '../spec/test_module' if $test_env
require 'helpers'
require 'exceptions'
require 'validation'

class Field
  include TestModule if $test_env
  include FieldValidation
  attr_accessor :type, :label_text, :name, :help_text, :html_id, :errors, :pretty_print, :required, :valid

  def initialize(label_text=nil, attributes=nil, help_text=nil, required='false')
    @label_text, @attributes, @help_text, @required = label_text, attributes, help_text, required
    @type = self.class.to_s.gsub(/Field$/, '').downcase
    @valid = true
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

end

class TextField < Field
end

class CheckboxField < Field
  def to_labeled_html
    to_html + label_tag
  end
end

class ChoiceField < Field
  def initialize(label_text, values, attributes = Hash.new)
    @label_text, @values, @attributes = label_text, values, attributes
  end

  def _html_options
    html_options = @values.map { |v|
      tag = wrap_tag(v, :option, {:value => symbolize(v)})
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
  def initialize(value, attributes = Hash.new)
    @value, @attributes, @type = value, attributes, :radio
    @attributes[:value] = @value.downcase
    @label_text = @value
    @type = :radio
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

  def initialize(label_text, values, attributes = Array.new)
    @label_text, @values, @attributes = label_text, values, attributes
    @fields = values.map { |value| RadioField.new(value) }
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
