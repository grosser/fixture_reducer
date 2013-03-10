require "spec_helper"

describe FixtureReducer do
  it "has a VERSION" do
    FixtureReducer::VERSION.should =~ /^[\.\da-z]+$/
  end
end
