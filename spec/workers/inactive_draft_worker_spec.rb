require 'spec_helper'

describe InactiveDraftWorker do

  before do
    Sidekiq::Testing.inline!
  end

  context "when project is in draft" do

    let!(:project) do
      build(:project, state: 'draft')
    end

    it 'notify the owner' do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).to receive(:notify_owner).with(:inactive_draft)
      InactiveDraftWorker.perform_async(project.id)
    end
  end

  context "whe project is not in draft" do

    let!(:project) do
      build(:project)
    end

    it 'does not notify the owner' do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).to_not receive(:notify_owner)
      InactiveDraftWorker.perform_async(project.id)
    end
  end
end
