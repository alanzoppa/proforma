$: << File.dirname(__FILE__)

require 'test_module'
require '../lib/proforma'


describe "A Form with a TextField" do
  before do
    class TextFieldForm < Form
      @@text_field = TextField.new(label_text="Herp some derps", attributes=nil, help_text=nil, required='true')
    end
    @text_form = TextFieldForm.new
    @text_field = @text_form.fields[0]

    class DefaultAttributesForm < Form
      def redefine_defaults
        @__settings[:wrapper] = :span
        @__settings[:wrapper_attributes] = {:class => :some_herps}
      end

      @@text_field = TextField.new("Herp some derps")
    end

    @default_attributes_form = DefaultAttributesForm.new
    @default_attributes_field = @default_attributes_form.fields[0]
    @validated_form = DefaultAttributesForm.new({:text_field => "Herp most of the derps"})
  end

  it "should not complain if the text field is filled" do
    print @validated_form.get_field :text_field
    @validated_form.is_valid?.should be_true
  end
end
