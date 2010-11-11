require 'spec_helper'

describe Category do
  it "should be valid from factory" do
    c = Factory(:category)
    c.should be_valid
  end
  it "should validate presence of name" do
    c = Factory.build(:category, :name => nil)
    c.should_not be_valid
  end
  it "should validate uniqueness of name" do
    c = Factory(:category, :name => "foo")
    c.should be_valid
    c2 = Factory.build(:category, :name => "foo")
    c2.should_not be_valid
  end
end

