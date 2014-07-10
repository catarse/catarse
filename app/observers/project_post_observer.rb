class ProjectPostObserver < ActiveRecord::Observer
  observe :project_post

  def after_create(post)
    post.notify_contributors
  end
end
