require 'spec_helper'

describe InactiveDraftWorker do
  let(:project) { create(:project, state: 'draft') }

  before do
    Sidekiq::Testing.inline!
  end

  context "when project is in draft" do
    before do
      Notification.should_receive(:notify_once).with(
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
      project.stub(:draft?).and_return(false)

      Notification.any_instance.should_not_receive(:notify_once).with(
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
