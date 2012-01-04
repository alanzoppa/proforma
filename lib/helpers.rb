def symbolize string
  string.to_s.strip.gsub(/ /, '_').downcase.to_sym
end

def flatten_attributes(hash=nil)
  hash.to_a.map do |key,value|
    value = value.strip if value.class == String
    "#{key}=\"#{escape_double_quotes value.to_s}\""
  end.join ' '
end

def wrap_tag(string, with=:p, attributes=nil)
  with_open = attributes.nil? ? with : "#{with} #{flatten_attributes(attributes)}"
  return "<#{with_open}>#{string}</#{with}>"
end

def escape_single_quotes(str)
  str.gsub("'", "\\\\'")
end

def escape_double_quotes(str)
  str.gsub('"', '\\\\"')
end
