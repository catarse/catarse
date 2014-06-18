class ProjectObserver < ActiveRecord::Observer
  observe :project

  def after_save(project)
    if project.try(:video_url_changed?)
      ProjectDownloaderWorker.perform_async(project.id)
    end

    if project.try(:online_date_changed?) && project.online_date.present? && project.in_analysis?
      project.remove_scheduled_job('ProjectSchedulerWorker')
      ProjectSchedulerWorker.perform_at(project.online_date, project.id)
    end
  end

  def after_create(project)
    deliver_default_notification_for(project, :project_received)
    InactiveDraftWorker.perform_at(2.day.from_now, project.id)
  end

  def from_draft_to_in_analysis(project)
    project.notify_to_backoffice(:new_draft_project, {
      origin_email: project.user.email,
      origin_name: project.user.display_name
    }, project.new_draft_recipient)

    deliver_default_notification_for(project, :in_analysis_project)

    project.update_attributes({ sent_to_analysis_at: DateTime.now })
  end

  def from_online_to_waiting_funds(project)
    project.notify_owner(:project_in_wainting_funds, { origin_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_successful(project)
    project.notify_owner(:project_success, origin_email: CatarseSettings[:email_projects])

    notify_admin_that_project_reached_deadline(project)
    notify_users(project)
  end

  def notify_admin_that_project_reached_deadline(project)
    project.notify_to_backoffice(:adm_project_deadline, { origin_email: CatarseSettings[:email_system] })
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
      contribution.notify_to_contributor(:pending_contribution_project_unsuccessful, { project: project })
    end

    project.notify_owner(:project_unsuccessful, { origin_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  def notify_users(project)
    project.contributions.with_state('confirmed').each do |contribution|
      unless contribution.notified_finish
        template_name = (project.successful? ? :contribution_project_successful : :contribution_project_unsuccessful)

        contribution.notify_to_contributor(template_name, { project: project })
        contribution.update_attributes({ notified_finish: true })
      end
    end
  end

  private

  def deliver_default_notification_for(project, notification_type)
    template_name = project.notification_type(notification_type)

    project.notify_owner(template_name, {
      channel: project.last_channel,
      origin_email: project.last_channel.try(:email) || CatarseSettings[:email_projects],
      origin_name: project.last_channel.try(:name) || CatarseSettings[:company_name]
    })
  end
end
