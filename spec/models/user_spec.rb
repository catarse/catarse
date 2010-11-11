require 'spec_helper'

describe User do
  it "should be valid from factory" do
    u = Factory(:user)
    u.should be_valid
  end
  it "should validate presence of name" do
    u = Factory.build(:user, :name => nil)
    u.should_not be_valid
  end
  it "should validate presence of email" do
    u = Factory.build(:user, :email => nil)
    u.should_not be_valid
  end
  it "should validate presence of password" do
    u = Factory.build(:user, :password => nil)
    u.should_not be_valid
  end
  it "should validate presence of password_confirmation" do
    u = Factory.build(:user, :password_confirmation => nil)
    u.should_not be_valid
  end
  it "should validate incorrect password_confirmation" do
    u = Factory.build(:user, :password => "foo123", :password_confirmation => "bar123")
    u.should_not be_valid
  end
  it "should validate correct password_confirmation" do
    u = Factory.build(:user, :password => "foo123", :password_confirmation => "foo123")
    u.should be_valid
  end
end

