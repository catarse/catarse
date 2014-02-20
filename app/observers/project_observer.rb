class ProjectObserver < ActiveRecord::Observer
  observe :project

  def after_save(project)
    if project.try(:video_url_changed?)
      ProjectDownloaderWorker.perform_async(project.id)
    end
  end

  def after_create(project)
    deliver_default_notification_for(project, :project_received)
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

    deliver_default_notification_for(project, :in_analysis_project)

    project.update_attributes({ sent_to_analysis_at: DateTime.now })
  end

  def from_online_to_waiting_funds(project)
    Notification.notify_once(
      :project_in_wainting_funds,
      project.user,
      {project_id: project.id},
      {
        project: project,
        origin_email: Configuration[:email_projects]
      }
    )
  end

  def from_waiting_funds_to_successful(project)
    Notification.notify_once(
      :project_success,
      project.user,
      {project_id: project.id},
      {
        project: project,
        origin_email: Configuration[:email_projects]
      }
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
    project.update_attributes({ rejected_at: DateTime.now })
    deliver_default_notification_for(project, :project_rejected)
  end

  def from_in_analysis_to_draft(project)
    project.update_attributes({ sent_to_draft_at: DateTime.now })
  end

  def from_in_analysis_to_online(project)
    deliver_default_notification_for(project, :project_visible)
    project.update_attributes({ online_date: DateTime.now,
                                audited_user_name: project.user.full_name,
                                audited_user_cpf: project.user.cpf,
                                audited_user_moip_login: project.user.moip_login,
                                audited_user_phone_number: project.user.phone_number

    })
  end

  def from_online_to_failed(project)
    notify_users(project)

    project.contributions.with_state('waiting_confirmation').each do |contribution|
      Notification.notify_once(
        :pending_contribution_project_unsuccessful,
        contribution.user,
        {contribution_id: contribution.id},
        {contribution: contribution, project: project }
      )
    end

    Notification.notify_once(
      :project_unsuccessful,
      project.user,
      {project_id: project.id, user_id: project.user.id},
      {
        project: project,
        origin_email: Configuration[:email_projects]
      }
    )
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  def notify_users(project)
    project.contributions.with_state('confirmed').each do |contribution|
      unless contribution.notified_finish
        Notification.notify_once(
          (project.successful? ? :contribution_project_successful : :contribution_project_unsuccessful),
          contribution.user,
          {contribution_id: contribution.id},
          contribution: contribution,
          project: project,
        )
        contribution.update_attributes({ notified_finish: true })
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

  private

  def deliver_default_notification_for(project, notification_type)
    Notification.notify_once(
      project.notification_type(notification_type),
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
end
