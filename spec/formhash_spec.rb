$: << File.dirname(__FILE__)
require '../lib/formhash.rb'

describe "A FormHash" do

  before do
    @fh = FormHash.import({:spam => 123, :eggs => 456})
  end

  it "should coerce string keys to symbols" do
    f = FormHash.new
    f['key'] = "value"
    f.keys.should == [:key]
  end

  it "should convert a Hash to a FormHash" do
    hash = {'foo' => 'foo', 'bar' => 'bar'}
    FormHash.import(hash).should == {:foo => 'foo', :bar => 'bar'}
  end

  it "should complain if you try to use something other than a symbol or string as a key" do
    lambda { FormHash.import({1 => "foo"}) }.should raise_error(ArgumentError, "Use symbols in a FormHash. Strings will be coereced to symbols")
    lambda { FormHash.import({1.1 => "foo"}) }.should raise_error(ArgumentError, "Use symbols in a FormHash. Strings will be coereced to symbols")
  end

  it "should complain if you try to import something other than a hash" do
    lambda { FormHash.import("a string") }.should raise_error(ArgumentError, "You can only import a hash")
    lambda { FormHash.import(12345) }.should raise_error(ArgumentError, "You can only import a hash")
  end

  it "should still be possible to access keys with equivelant strings" do
    @fh['spam'].should == 123
    @fh[:spam].should == 123
    @fh['eggs'].should == 456
    @fh[:eggs].should == 456
  end

  it "should considser keys accessed with strings or symbols the same object" do
    @fh['spam'].should == @fh[:spam]
    @fh['eggs'].should == @fh[:eggs]
  end

end
