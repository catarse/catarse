require 'spec_helper'

describe ProjectsCuratedPage do
  it "should have a project" do
    pcp = Factory.build(:projects_curated_page, :project => nil)
    pcp.should_not be_valid
  end

  it "should have a curated page" do
    pcp = Factory.build(:projects_curated_page, :curated_page => nil)
    pcp.should_not be_valid
  end

  it "should be valid when associated to a project and a curated page" do
    pcp = Factory.build(:projects_curated_page)
    pcp.should be_valid
  end
end
