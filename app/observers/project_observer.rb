class ProjectObserver < ActiveRecord::Observer
  observe :project

  def before_save(project)
    #Notification.create_notification(:project_visible, project.user, project: project) if (project.visible_was == false) && (project.visible == true)
    project.download_video_thumbnail if project.video_url.present? && project.video_url_changed?
  end

  def after_create(project)
    if (user = User.where(email: Configuration[:email_projects]).first)
      Notification.create_notification_once(:new_draft_project,
                                            user,
                                            {project_id: project.id},
                                            {project: project, project_name: project.name})
    end

    Notification.create_notification_once(:project_received, 
                                          project.user,
                                          {project_id: project.id},
                                          {project: project, project_name: project.name})
  end

  def notify_owner_that_project_is_rejected(project)
    Notification.create_notification_once(:project_rejected,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_owner_that_project_is_online(project)
    Notification.create_notification_once(:project_visible,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_users(project)
    project.backers.confirmed.each do |backer|
      unless backer.can_refund? or backer.notified_finish
        if project.successful?
          Notification.create_notification_once(
            :backer_project_successful,
            backer.user,
            {project_id: project.id, user_id: backer.user.id},
            backer: backer,
            project: project,
            project_name: project.name)
        else
          Notification.create_notification_once(
            :backer_project_unsuccessful,
            backer.user,
            {project_id: project.id, user_id: backer.user.id},
            backer: backer,
            project: project,
            project_name: project.name)
        end
        backer.update_attributes({ notified_finish: true })
      end
    end
    Notification.create_notification_once(:project_unsuccessful,
      project.user,
      {project_id: project.id, user_id: project.user.id},
      project: project) unless project.successful?
    project.update_attributes finished: true, successful: project.successful?
  end

end
