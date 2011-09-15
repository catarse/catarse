require 'spec_helper'

describe CuratedPage do
  it "should be valid from factory" do
    cp = Factory(:curated_page)
    cp.should be_valid
  end

  it "should have a name" do
    cp = Factory.build(:curated_page, :name => nil)
    cp.should_not be_valid
  end

  it "should have a logo" do
    cp = Factory.build(:curated_page, :logo => nil)
    cp.should_not be_valid
  end
  
  it "should have a permalink" do
    cp = Factory.build(:curated_page, :name => nil)
    cp.should_not be_valid
  end
end
