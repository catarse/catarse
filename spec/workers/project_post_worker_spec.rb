require 'rails_helper'

RSpec.describe ProjectPostWorker do
  let(:perform_post) { ProjectPostWorker.perform_async(@post.id) }

  before do
    Sidekiq::Testing.inline!
    @project = create(:project)
    contribution = create(:confirmed_contribution, project: @project)
    create(:confirmed_contribution, project: @project, user: contribution.user)
    @project.reload
    ActionMailer::Base.deliveries = []
    @post = ProjectPost.create!(user: @project.user, project: @project, title: "title", comment_html: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png")
    expect(ProjectPostNotification).to receive(:notify_once).with(
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
