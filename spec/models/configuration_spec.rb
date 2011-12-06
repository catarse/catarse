require 'spec_helper'

describe Configuration do
  it "should be valid from factory" do
    r = Factory(:configuration)
    r.should be_valid
  end
  it "should have a name" do
    r = Factory.build(:configuration, :name => nil)
    r.should_not be_valid
  end
end
