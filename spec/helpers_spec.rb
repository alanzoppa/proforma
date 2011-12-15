$: << File.dirname(__FILE__)

$test_env = true

require "../lib/proforma"
require "../lib/fields"


describe "the symbolize method" do
  it "should replace spaces with underscores" do
    symbolize("foo bar baz").should == :foo_bar_baz
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


describe "the indent method" do
  before do
    @string = "Blinky,\nPinky,\nInky,\nClyde"
  end


  it "should indent two lines by default" do
    indent(@string).should == "  Blinky,\n  Pinky,\n  Inky,\n  Clyde"
  end

  it "should indent by n lines" do
    indent(@string,4).should == "    Blinky,\n    Pinky,\n    Inky,\n    Clyde"
  end

end
