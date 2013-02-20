require 'spec_helper'

describe Category do
  it "should be valid from factory" do
    c = FactoryGirl.create(:category)
    c.should be_valid
  end
  it "should have a name" do
    c = FactoryGirl.build(:category, :name_pt => nil)
    c.should_not be_valid
  end
  it "should have an unique name" do
    c = FactoryGirl.create(:category, :name_pt => "foo")
    c.should be_valid
    c2 = FactoryGirl.build(:category, :name_pt => "foo")
    c2.should_not be_valid
  end
end
