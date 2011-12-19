class TextFieldForm < Form
  @@purchase_name = TextField.new("Purchase")
  @@purchase_cost = TextField.new("Cost")

  def redefine_defaults
    @__settings[:wrapper] = :div
    @__settings[:wrapper_attributes] = {:class => :field}
  end
end
