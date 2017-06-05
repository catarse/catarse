# frozen_string_literal: true

class ProjectPostObserver < ActiveRecord::Observer
  observe :project_post

  def after_create(post)
    ProjectPostWorker.perform_async(post.id)
  end
end
