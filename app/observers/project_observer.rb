class ProjectObserver < ActiveRecord::Observer
  observe :project

  def after_validation(project)
    if project.video_url.present? && project.video_url_changed?
      project.download_video_thumbnail
      project.update_video_embed_url
    end
  end

  def after_create(project)
    if (user = project.new_draft_recipient)
      Notification.create_notification_once(project.new_draft_project_notification_type,
                                            user,
                                            {project_id: project.id},
                                            {project: project, project_name: project.name, from: project.user.email, display_name: project.user.display_name}
                                           )
    end

    Notification.create_notification_once(project.new_project_received_notification_type,
                                          project.user,
                                          {project_id: project.id},
                                          {project: project, project_name: project.name})
  end

  def notify_owner_that_project_is_waiting_funds(project)
    Notification.create_notification_once(:project_in_wainting_funds,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_owner_that_project_is_successful(project)
    Notification.create_notification_once(:project_success,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_admin_that_project_reached_deadline(project)
    if (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.create_notification_once(:adm_project_deadline,
        user,
        {project_id: project.id},
        project: project,
        from: ::Configuration[:email_system],
        project_name: project.name)
    end
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
    project.backers.with_state('confirmed').each do |backer|
      unless backer.notified_finish
        Notification.create_notification_once(
          (project.successful? ? :backer_project_successful : :backer_project_unsuccessful),
          backer.user,
          {backer_id: backer.id},
          backer: backer,
          project: project,
          project_name: project.name)
        backer.update_attributes({ notified_finish: true })
      end
    end

    if project.failed?
      project.backers.with_state('waiting_confirmation').each do |backer|
        Notification.create_notification_once(
          :pending_backer_project_unsuccessful,
          backer.user,
          {backer_id: backer.id},
          {backer: backer, project: project, project_name: project.name })
      end
    end

    Notification.create_notification_once(:project_unsuccessful,
      project.user,
      {project_id: project.id, user_id: project.user.id},
      project: project) unless project.successful?

  end

  def sync_with_mailchimp(project)
    begin
      user = project.user
      mailchimp_params = { EMAIL: user.email, FNAME: user.name, CITY: user.address_city, STATE: user.address_state }

      if project.successful?
        CatarseMailchimp::API.subscribe(mailchimp_params, Configuration[:mailchimp_successful_projects_list])
      end

      if project.failed?
        CatarseMailchimp::API.subscribe(mailchimp_params, Configuration[:mailchimp_failed_projects_list])
      end
    rescue Exception => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end

end
