class TextFieldForm < Form
  @@name = TextField.new("Purchase")
  @@cost = TextField.new("Cost")

  def redefine_defaults
    @__settings[:wrapper] = :div
    @__settings[:wrapper_attributes] = {:class => :field}
    @__settings[:hash_wrapper] = :purchase
  end
end
