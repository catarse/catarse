require 'rails_helper'

RSpec.describe FlexibleProjectMachine, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: project_state) }
  let!(:project_account) { create(:project_account, project: project) }

  describe "state_machine" do
    subject { project.state_machine }

    context "should starts in draft" do
      it do
        expect(subject.current_state).to eq("draft")
      end
    end

  end
end
