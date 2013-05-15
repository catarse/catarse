require 'spec_helper'

describe ProjectTotal do
  before do
    @project_id = FactoryGirl.create(:backer, :value => 10.0, :state => 'pending').project_id
    FactoryGirl.create(:backer, :value => 10.0, :state => 'confirmed', :project_id => @project_id)
  end

  describe "#pledged" do
    subject{ ProjectTotal.where(:project_id => @project_id).first.pledged }
    it{ should == 10 }
  end

  describe "#total_backers" do
    subject{ ProjectTotal.where(:project_id => @project_id).first.total_backers }
    it{ should == 1 }
  end
end
