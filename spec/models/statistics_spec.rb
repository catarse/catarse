require 'spec_helper'

describe Statistics do
  before do
    create(:project, state: 'successful')
    create(:project, state: 'draft')
    project = create(:project, state: 'online')
    create(:contribution, state: 'confirmed', project: project )
    create(:contribution, project: project)
  end

  describe "#total_users" do
    subject{ Statistics.first.total_users }
    it{ should == User.count }
  end

  describe "#total_contributions" do
    subject{ Statistics.first.total_contributions }
    it{ should == Contribution.with_state('confirmed').count }
  end

  describe "#total_contributions" do
    subject{ Statistics.first.total_contributions }
    it{ should == User.contributions.count }
  end

  describe "#total_contributed" do
    subject{ Statistics.first.total_contributed}
    it{ should == Contribution.with_state('confirmed').sum(:value) }
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
    it{ should == Project.with_state('online').count }
  end
end
