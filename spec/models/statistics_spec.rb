require 'spec_helper'

describe Statistics do
  before do
    Notification.stubs(:create_notification)
    Factory(:backer, :confirmed => true)
    Factory(:backer, :confirmed => false)
    Factory(:project, :visible => true, :successful => true)
    Factory(:project, :visible => false, :successful => true)
    Factory(:project, :visible => true, :successful => false)
    Factory(:project, :visible => false, :successful => false)
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
    it{ should == Project.visible.successful.count }
  end

  describe "#total_projects_online" do
    subject{ Statistics.first.total_projects_online }
    it{ should == Project.visible.not_expired.count }
  end
end
