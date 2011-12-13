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


describe "the monkey patch indent method" do
  before do
    @string = "Blinky,\nPinky,\nInky,\nClyde"
  end


  it "should indent two lines by default" do
    @string.indent.should == "  Blinky,\n  Pinky,\n  Inky,\n  Clyde"
  end

  it "should indent by n lines" do
    @string.indent(4).should == "    Blinky,\n    Pinky,\n    Inky,\n    Clyde"
  end

end

describe "the template monkey patch" do
  before do
    @byron = "I would to heaven that I were so much clay\nAs I am bone, blood, marrow, passion, feeling"
  end

  it "should interpolate an arbitrary string" do
    @byron.template("\n%s\n").should == "\nI would to heaven that I were so much clay\nAs I am bone, blood, marrow, passion, feeling\n"
    @byron.template("%s\n").should == "I would to heaven that I were so much clay\nAs I am bone, blood, marrow, passion, feeling\n"
    @byron.template("\n%s").should == "\nI would to heaven that I were so much clay\nAs I am bone, blood, marrow, passion, feeling"
  end
end
