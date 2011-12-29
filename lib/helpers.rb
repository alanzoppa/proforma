def symbolize string
  string.to_s.gsub(/ /, '_').downcase.to_sym
end

def flatten_attributes(hash=nil)
  hash.to_a.map {|key,value| "#{key}='#{value}'"}.join ' '
end

def wrap_tag(string, with=:p, attributes=nil)
  with_open = attributes.nil? ? with : "#{with} #{flatten_attributes(attributes)}"
  return "<#{with_open}>#{string}</#{with}>"
end
