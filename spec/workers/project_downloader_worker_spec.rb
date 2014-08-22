require 'spec_helper'

describe ProjectDownloaderWorker do
  let(:project) { create(:project, video_url: nil, goal: 3000) }
  let(:perform_project) { ProjectDownloaderWorker.perform_async(project.id) }

  before do
    CatarseSettings[:minimum_goal_for_video] = 5000
    Sidekiq::Testing.inline!

    project.video_url = 'http://vimeo.com/66698435'

    Project.any_instance.should_receive(:update_video_embed_url).and_call_original
    Project.any_instance.should_receive(:download_video_thumbnail)
  end

  it("should satisfy expectations") { perform_project }
end
