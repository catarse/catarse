require 'spec_helper'

describe User do
  it "should be valid from factory" do
    u = Factory(:user)
    u.should be_valid
  end
  it "should have a provider" do
    u = Factory.build(:user, :provider => nil)
    u.should_not be_valid
  end
  it "should have an uid" do
    u = Factory.build(:user, :uid => nil)
    u.should_not be_valid
  end
  it "should not have duplicate provider and uid" do
    u = Factory.build(:user, :provider => "twitter", :uid => "123456")
    u.should be_valid
    u.save
    u = Factory.build(:user, :provider => "twitter", :uid => "123456")
    u.should_not be_valid
  end
  it "should allow empty email" do
    u = Factory.build(:user)
    u.email = ""
    u.should be_valid
    u.email = nil
    u.should be_valid
  end
  it "should check email format" do
    u = Factory.build(:user)
    u.email = "foo"
    u.should_not be_valid
    u.email = "foo@bar"
    u.should_not be_valid
    u.email = "foo@bar.com"
    u.should be_valid
  end
end

