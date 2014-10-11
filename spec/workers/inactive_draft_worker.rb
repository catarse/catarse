require 'rails_helper'

describe InactiveDraftWorker do
  let(:project) { create(:project, state: 'draft') }

  before do
    Sidekiq::Testing.inline!
  end

  context "when project is in draft" do
    before do
      expect(Notification).to receive(:notify_once).with(
        :inactive_draft,
        project.user,
        { project_id: project.id, channel_id: nil },
        project: project
      )
    end

    it "should create a inactive draft notification" do
      InactiveDraftWorker.perform_async(project.id)
    end
  end

  context "whe contribution is not in draft" do
    before do
      allow(project).to receive(:draft?).and_return(false)

      expect_any_instance_of(Notification).not_to receive(:notify_once).with(
        :inactive_draft,
        project.user,
        { project_id: project.id },
        project: project
      )
    end

    it "should not create a inactive draft notification" do
      InactiveDraftWorker.perform_async(project.id)
    end
  end


end
