require 'spec_helper'

describe Statistics do
  before do
    Factory(:project, state: 'successful')
    Factory(:project, state: 'draft') 
    project = Factory(:project, state: 'online')
    Factory(:backer, confirmed: true, project: project )
    Factory(:backer, confirmed: false, project: project)
  end

  describe "#total_users" do
    subject{ Statistics.first.total_users }
    it{ should == User.primary.count }
  end

  describe "#total_backs" do
    subject{ Statistics.first.total_backs }
    it{ should == Backer.confirmed.count }
  end

  describe "#total_backers" do
    subject{ Statistics.first.total_backers }
    it{ should == User.backers.count }
  end

  describe "#total_backed" do
    subject{ Statistics.first.total_backed }
    it{ should == Backer.confirmed.sum(:value) }
  end

  describe "#total_projects" do
    subject{ Statistics.first.total_projects }
    it{ should == Project.visible.count }
  end

  describe "#total_projects_success" do
    subject{ Statistics.first.total_projects_success }
    it{ should == Project.successful.count }
  end

  describe "#total_projects_online" do
    subject{ Statistics.first.total_projects_online }
    it{ should == Project.online.count }
  end
end
