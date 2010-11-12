require 'spec_helper'

describe Backer do
  it "should be valid from factory" do
    b = Factory(:backer)
    b.should be_valid
  end
  it "should have a project" do
    b = Factory.build(:backer, :project => nil)
    b.should_not be_valid
  end
  it "should have a user" do
    b = Factory.build(:backer, :user => nil)
    b.should_not be_valid
  end
  it "should have a value" do
    b = Factory.build(:backer, :value => nil)
    b.should_not be_valid
  end
  it "should have positive value" do
    b = Factory.build(:backer)
    b.value = -0.01
    b.should_not be_valid
    b.value = 0.00
    b.should_not be_valid
    b.value = 0.01
    b.should be_valid
  end
end

