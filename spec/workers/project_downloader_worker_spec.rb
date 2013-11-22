require 'spec_helper'

describe ProjectDownloaderWorker do
  let(:project) { create(:project, video_url: nil) }
  let(:perform_project) { ProjectDownloaderWorker.perform_async(project.id) }

  before do
    Sidekiq::Testing.inline!

    project.video_url = 'http://vimeo.com/66698435'

    Project.any_instance.should_receive(:update_video_embed_url).and_call_original
    Project.any_instance.should_receive(:download_video_thumbnail)
  end

  it("should satisfy expectations") { perform_project }
end
