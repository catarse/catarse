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
  it "should validate password_confirmation" do
    u = Factory.build(:user)
    u.password = "foo123"
    u.password_confirmation = "bar123"
    u.should_not be_valid
    u.password_confirmation = "foo123"
    u.should be_valid
  end
  it "should validate email format" do
    u = Factory.build(:user)
    u.email = "foo"
    u.should_not be_valid
    u.email = "foo@bar"
    u.should_not be_valid
    u.email = "foo@bar.com"
    u.should be_valid
  end
  it "should validate uniqueness of email" do
    u = Factory(:user, :email => "foo@bar.com")
    u.should be_valid
    u2 = Factory.build(:user, :email => "foo@bar.com")
    u2.should_not be_valid
  end
end

