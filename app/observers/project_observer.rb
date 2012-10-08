class ProjectObserver < ActiveRecord::Observer
  observe :project

  def notify_users(project)
    project.backers.confirmed.each do |backer|
      unless backer.can_refund or backer.notified_finish
        if project.successful?
          Notification.create_notification(:backer_project_successful, backer.user, :backer => backer, :project => project, :project_name => project.name)
        else
          Notification.create_notification(:backer_project_unsuccessful, backer.user, :backer => backer, :project => project, :project_name => project.name)
        end
        backer.update_attributes({ notified_finish: true })
      end
    end
    Notification.create_notification( :project_unsuccessful, project.user, :project => project) unless project.successful?
    project.update_attributes finished: true, successful: project.successful?
  end

end
