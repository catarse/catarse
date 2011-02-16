require 'spec_helper'

describe Reward do
  it "should be valid from factory" do
    r = Factory(:reward)
    r.should be_valid
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
  it "should have integer maximum backers" do
    r = Factory.build(:reward)
    r.maximum_backers = 10.01
    r.should_not be_valid
    r.maximum_backers = 10
    r.should be_valid
  end
  it "should have maximum backers > 0" do
    r = Factory.build(:reward)
    r.maximum_backers = -1
    r.should_not be_valid
    r.maximum_backers = 0
    r.should_not be_valid
    r.maximum_backers = 1
    r.should be_valid
  end
  it "should be sold_out? if maximum_backers was reached" do
    r = Factory(:reward, :maximum_backers => nil)
    r.sold_out?.should be_false
    r = Factory(:reward, :maximum_backers => 10)
    9.times { Factory(:backer, :project_id => r.project_id, :reward_id => r.id) }
    r.sold_out?.should be_false
    Factory(:backer, :project_id => r.project_id, :reward_id => r.id)
    r.sold_out?.should be_true
  end
  it "should say the remaining spots" do
    r = Factory(:reward, :maximum_backers => nil)
    r.remaining.should be_nil
    r = Factory(:reward, :maximum_backers => 10)
    r.remaining.should == 10
    5.times { Factory(:backer, :project_id => r.project_id, :reward_id => r.id) }
    r.remaining.should == 5
    5.times { Factory(:backer, :project_id => r.project_id, :reward_id => r.id) }
    r.remaining.should == 0
  end
end

