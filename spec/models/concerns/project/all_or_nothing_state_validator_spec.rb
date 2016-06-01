require 'rails_helper'

RSpec.describe Project::AllOrNothingStateValidator, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: project_state) }
  let!(:project_account) { create(:project_account, project: project) }

  context "when project is going to online to end state" do
    subject { project }

    context "online validation" do
      let(:project_state) { 'online' }

      it { is_expected.to validate_presence_of :city }
      it { is_expected.to validate_length_of(:name).is_at_most(Project::NAME_MAXLENGTH) }
    end

    Project::ON_ANALYSIS_TO_END_STATES.each do |state| 
      context "#{state} project validations" do
        let(:project_state) { state }

        it { is_expected.to validate_presence_of :goal }
        it { is_expected.to validate_presence_of :online_days }
      end
    end
  end
end
