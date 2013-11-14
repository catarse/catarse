class ProjectObserver < ActiveRecord::Observer
  observe :project

  def after_validation(project)
    if project.video_url.present? && project.video_url_changed?
      project.download_video_thumbnail
      project.update_video_embed_url
    end
  end

  def after_create(project)
    Notification.notify_once(
      project.notification_type(:project_received),
      project.user,
      {project_id: project.id, channel_id: project.last_channel.try(:id)},
      {
        project: project, 
        channel: project.last_channel, 
        origin_email: project.last_channel.try(:email) || Configuration[:email_projects], 
        origin_name: project.last_channel.try(:name) || Configuration[:company_name]
      }
    )
  end

  def from_draft_to_in_analysis(project)
    if (user = project.new_draft_recipient)
      Notification.notify_once(
        project.notification_type(:new_draft_project),
        user,
        {project_id: project.id, channel_id: project.last_channel.try(:id)},
        {
          project: project, 
          channel: project.last_channel,
          origin_email: project.user.email, 
          origin_name: project.user.display_name
        }
      )
    end

    Notification.notify_once(
      project.notification_type(:in_analysis_project), 
      project.user, 
      {project_id: project.id, channel_id: project.last_channel.try(:id)}, 
      {
        project: project, 
        channel: project.last_channel, 
        origin_email: project.last_channel.try(:email) || Configuration[:email_projects], 
        origin_name: project.last_channel.try(:name) || Configuration[:company_name]
      }
    )
  end

  def from_online_to_waiting_funds(project)
    Notification.notify_once(
      :project_in_wainting_funds,
      project.user,
      {project_id: project.id},
      project: project
    )
  end

  def from_waiting_funds_to_successful(project)
    Notification.notify_once(
      :project_success,
      project.user,
      {project_id: project.id},
      {project: project}
    )
    notify_admin_that_project_reached_deadline(project)
    notify_users(project)
  end

  def notify_admin_that_project_reached_deadline(project)
    if (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.notify_once(
        :adm_project_deadline,
        user,
        {project_id: project.id},
        project: project,
        origin_email: Configuration[:email_system],
        project: project
      )
    end
  end

  def from_in_analysis_to_rejected(project)
    Notification.notify_once(
      project.notification_type(:project_rejected),
      project.user,
      {project_id: project.id, channel_id: project.last_channel.try(:id)},
      {
        project: project, 
        channel: project.last_channel, 
        origin_email: project.last_channel.try(:email) || Configuration[:email_projects], 
        origin_name: project.last_channel.try(:name) || Configuration[:company_name]
      }
    )
  end

  def from_in_analysis_to_online(project)
    Notification.notify_once(
      project.notification_type(:project_visible),
      project.user,
      {project_id: project.id, channel_id: project.last_channel.try(:id)},
      {
        project: project, 
        channel: project.last_channel, 
        origin_email: project.last_channel.try(:email) || Configuration[:email_projects], 
        origin_name: project.last_channel.try(:name) || Configuration[:company_name]
      }
    )
  end

  def from_online_to_failed(project)
    notify_users(project)

    project.backers.with_state('waiting_confirmation').each do |backer|
      Notification.notify_once(
        :pending_backer_project_unsuccessful,
        backer.user,
        {backer_id: backer.id},
        {backer: backer, project: project }
      )
    end

    Notification.notify_once(
      :project_unsuccessful,
      project.user,
      {project_id: project.id, user_id: project.user.id},
      {project: project}
    )
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  def notify_users(project)
    project.backers.with_state('confirmed').each do |backer|
      unless backer.notified_finish
        Notification.notify_once(
          (project.successful? ? :backer_project_successful : :backer_project_unsuccessful),
          backer.user,
          {backer_id: backer.id},
          backer: backer,
          project: project,
        )
        backer.update_attributes({ notified_finish: true })
      end
    end
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
