class ProjectPostWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform project
    project.subscribed_users.find_each do |user|
      notify_once(:posts, user, project.project_post, {from_email: project.user.email, from_name: project.user.display_name})
    end
  end
end
