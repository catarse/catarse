class ProjectObserver < ActiveRecord::Observer
  observe :project

  def before_save(project)
    Notification.notify_project_owner(project, :project_success) if project.finished && project.successful?
  end
end
