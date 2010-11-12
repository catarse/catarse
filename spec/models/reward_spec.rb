require 'spec_helper'

describe Reward do
  it "should be valid from factory" do
    r = Factory(:reward)
    r.should be_valid
  end
  it "should have a project" do
    r = Factory.build(:reward, :project => nil)
    r.should_not be_valid
  end
  it "should have a minimum value" do
    r = Factory.build(:reward, :minimum_value => nil)
    r.should_not be_valid
  end
  it "should have a greater than 1.00 minimum value" do
    r = Factory.build(:reward)
    r.minimum_value = -0.01
    r.should_not be_valid
    r.minimum_value = 0.99
    r.should_not be_valid
    r.minimum_value = 1.00
    r.should be_valid
    r.minimum_value = 1.01
    r.should be_valid
  end
  it "should have a description" do
    r = Factory.build(:reward, :description => nil)
    r.should_not be_valid
  end
  it "should have maximum backers" do
    r = Factory.build(:reward, :maximum_backers => nil)
    r.should_not be_valid
  end
  it "should have integer maximum backers" do
    r = Factory.build(:reward)
    r.maximum_backers = 10.01
    r.should_not be_valid
    r.maximum_backers = 10
    r.should be_valid
  end
  it "should have maximum backers >= 0" do
    r = Factory.build(:reward)
    r.maximum_backers = -1
    r.should_not be_valid
    r.maximum_backers = 0
    r.should be_valid
    r.maximum_backers = 1
    r.should be_valid
  end
end

