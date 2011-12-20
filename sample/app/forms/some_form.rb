class TextFieldForm < Form
  @@name = TextField.new("Purchase", nil, :required=>true)
  @@cost = TextField.new("Cost", nil, :required=>true)

  def redefine_defaults
    @__settings[:wrapper] = :div
    @__settings[:wrapper_attributes] = {:class => :field}
    @__settings[:hash_wrapper] = :purchase
  end

  def cleaned_cost(cost)
    cost = cost.to_i
    raise FieldValidationError.new("There is a $100 limit.") if cost > 100
    return cost
  end

  def cleaned_name(name)
    raise FieldValidationError.new("You cannot name a puchase 'Chumpy.'") if name == "Chumpy"
    return name
  end

  def cleaned_form(data)
    raise FormValidationError.new("This is right out!") if data[:cost].to_i > 100 && data[:name] == "Chumpy"
    return data
  end

end
