class ProjectPostWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform post_id
    post = ProjectPost.find post_id
    recipients = case post.recipients
    when 'reward'
      post.project.subscribed_users.who_chose_reward(post.reward_id)
    else
      post.project.subscribed_users
    end

    recipients.find_each(batch_size: 100) do |user|
      post.notify_once(:posts, user, post, {from_email: post.project.user.email, from_name: post.project.user.display_name})
    end
  end
end
