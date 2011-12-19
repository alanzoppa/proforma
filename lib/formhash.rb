class FormHash < Hash
  # This is a small tweak to Hashes
  # Keys will be coerced to strings when creating or accessing.
  # In a breath, it's a hash that only uses symbol keys internally, like so
  #
  # @fh = FormHash.import({:spam => 123, :eggs => 456})
  # @fh['spam'].should == @fh[:spam]

  def []=(key, value)
    raise ArgumentError.new("Use symbols in a FormHash. Strings will be coereced to symbols") unless [Symbol, String].include? key.class
    key = key.to_sym
    super
  end

  def [](key)
    key = key.to_sym
    super
  end

  def self.import(regular_hash = nil)
    if regular_hash.class.ancestors.include?(Hash)
      h = FormHash.new
      regular_hash.each { |k,v| h[k] = v }
      return h
    end
    raise ArgumentError.new("You can only import a hash")
  end
end
