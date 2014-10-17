require 'rails_helper'

RSpec.describe ProjectDownloaderWorker do
  let(:project) { create(:project, video_url: nil, goal: 3000) }
  let(:perform_project) { ProjectDownloaderWorker.perform_async(project.id) }

  before do
    CatarseSettings[:minimum_goal_for_video] = 5000
    Sidekiq::Testing.inline!

    project.video_url = 'http://vimeo.com/66698435'

    expect_any_instance_of(Project).to receive(:update_video_embed_url).and_call_original
    expect_any_instance_of(Project).to receive(:download_video_thumbnail)
  end

  it("should satisfy expectations") { perform_project }
end
