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

# == Schema Information
#
# Table name: curated_pages
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  description  :string(255)
#  analytics_id :string(255)
#  logo         :string(255)
#  video_url    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  permalink    :string(255)
#  site_id      :integer
#

