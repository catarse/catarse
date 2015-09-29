class ProjectPostWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform post_id
    post = ProjectPost.find post_id
    post.project.subscribed_users.find_each(batch_size: 100) do |user|
      post.notify_once(:posts, user, post, {from_email: post.project.user.email, from_name: post.project.user.display_name})
    end
  end
end
