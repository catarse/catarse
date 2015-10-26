require 'rails_helper'

RSpec.describe FlexibleProject, type: :model do
  let(:project) { create(:project, permalink: 'foo', state: 'draft', expires_at: nil) }
  let(:flexible_project) { create(:flexible_project, project: project) }

  describe "associations" do
    it{ is_expected.to belong_to :project }
    it{ is_expected.to have_many :transitions }
  end

  describe "validations" do
    subject { flexible_project }
    it{ is_expected.to validate_presence_of :project_id }
    it{ is_expected.to validate_uniqueness_of :project_id }
    it{ is_expected.to validate_length_of(:name).is_at_most(Project::NAME_MAXLENGTH) }
  end

  describe "#state_machine" do
    subject { flexible_project.state_machine }

    it { is_expected.to be_an_instance_of(FlexibleProjectMachine) }
  end
end
