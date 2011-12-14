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

class String
  def indent(depth=2)
    lines = self.split("\n")
    indent_spaces = String.new
    depth.times { |i| indent_spaces += ' ' }
    lines.join("\n#{indent_spaces}").template "#{indent_spaces}%s"
  end

  def template(tpl)
    return tpl % self
  end
end


