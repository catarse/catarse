require 'rails_helper'

RSpec.describe Project::FlexibleHandler, type: :model do
  describe '#is_flexible?' do
    let(:draft_project) { create(:project, state: 'draft') }
    subject { draft_project.is_flexible? }

    context "when project has an flexible project" do
      before do
        create(:flexible_project, project: draft_project)
      end

      it { is_expected.to eq(true) }
    end

    context "when project does not have an flexible project" do
      it { is_expected.to eq(false) }
    end

    context "when project goes online and attach a flexible project" do
      it { is_expected.to eq(false) }
    end
  end
end
