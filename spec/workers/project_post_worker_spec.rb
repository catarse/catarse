require 'spec_helper'

describe ProjectPostWorker do
  let(:perform_post) { ProjectPostWorker.perform_async(@post.id) }

  before do
    Sidekiq::Testing.inline!
    @project = create(:project)
    contribution = create(:contribution, state: 'confirmed', project: @project)
    create(:contribution, state: 'confirmed', project: @project, user: contribution.user)
    @project.reload
    ActionMailer::Base.deliveries = []
    @post = ProjectPost.create!(user: @project.user, project: @project, title: "title", comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png")
    ProjectPostNotification.should_receive(:notify_once).with(
        :posts,
        contribution.user,
        @post,
        {
          from_email: @post.project.user.email,
          from_name: @post.project.user.display_name
        }
      ).once.and_call_original
  end

  it("should satisfy expectations") { perform_post }
end
