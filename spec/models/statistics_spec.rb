require 'rails_helper'

RSpec.describe Statistics, type: :model do
  before do
    create(:project, state: 'successful')
    create(:project, state: 'draft')
    project = create(:project, state: 'online')
    create(:contribution, state: 'confirmed', project: project )
    create(:contribution, project: project)
  end

  describe "#total_users" do
    subject{ Statistics.first.total_users }
    it{ is_expected.to eq(User.count) }
  end

  describe "#total_contributions" do
    subject{ Statistics.first.total_contributions }
    it{ is_expected.to eq(Contribution.with_state('confirmed').count) }
  end

  describe "#total_contributed" do
    subject{ Statistics.first.total_contributed}
    it{ is_expected.to eq(Contribution.with_state('confirmed').sum(:value)) }
  end

  describe "#total_projects" do
    subject{ Statistics.first.total_projects }
    it{ is_expected.to eq(Project.visible.count) }
  end

  describe "#total_projects_success" do
    subject{ Statistics.first.total_projects_success }
    it{ is_expected.to eq(Project.successful.count) }
  end

  describe "#total_projects_online" do
    subject{ Statistics.first.total_projects_online }
    it{ is_expected.to eq(Project.with_state('online').count) }
  end
end
