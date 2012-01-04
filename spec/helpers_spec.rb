$: << File.dirname(__FILE__)

$test_env = true

require "../lib/proforma"
require "../lib/fields"


describe "the symbolize method" do
  it "should replace spaces with underscores" do
    symbolize("foo bar baz").should == :foo_bar_baz
  end

  it "should strip spaces" do
    symbolize(" foo bar baz  ").should == :foo_bar_baz
  end
end

describe "the wrap_tag method" do
  it "should wrap strings with <p> tags by default" do
    wrap_tag("derp").should == "<p>derp</p>"
  end

  it "should accept an arbitrary symbol or string to replace p" do
    wrap_tag("derp", with=:span).should == "<span>derp</span>"
  end
end

describe "the flatten_attributes method" do
  it "should strip spaces from string values" do
    flatten_attributes({:foo => " bar   "}).should == "foo=\"bar\""
  end
end


describe "the escape_single_quotes method" do
  it "should escape single quotes" do
    escape_single_quotes("something ''' foo ' ba'ar").should == "something \\'\\'\\' foo \\' ba\\'ar"
  end

end
