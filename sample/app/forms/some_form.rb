class TextFieldForm < Form
  @@name = TextField.new("Purchase", nil, :required=>true)
  @@cost = TextField.new("Cost", nil, :required=>true)

  def redefine_defaults
    @__settings[:wrapper] = :div
    @__settings[:wrapper_attributes] = {:class => :field}
    @__settings[:hash_wrapper] = :purchase
  end
end
