class ProjectObserver < ActiveRecord::Observer
  observe :project

  def after_save(project)
    if project.try(:video_url_changed?)
      ProjectDownloaderWorker.perform_async(project.id)
    end

    if project.try(:online_date_changed?) && project.online_date.present? && project.approved?
      project.remove_scheduled_job('ProjectSchedulerWorker')
      ProjectSchedulerWorker.perform_at(project.online_date, project.id)
    end

    project.expires_fragments(
      'project-funding_period',
      'project-stats',
      'project-about',
      'project-rewards'
    )
  end

  def after_create(project)
    deliver_default_notification_for(project, :project_received)
    InactiveDraftWorker.perform_at(1.day.from_now, project.id)
  end

  def from_draft_to_in_analysis(project)
    project.notify_to_backoffice(:new_draft_project, {
      from_email: project.user.email,
      from_name: project.user.display_name
    }, project.new_draft_recipient)

    deliver_default_notification_for(project, :in_analysis_project)

    project.update_attributes({ sent_to_analysis_at: DateTime.now })
  end

  def from_online_to_waiting_funds(project)
    project.notify_owner(:project_in_waiting_funds, { from_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_successful(project)
    project.notify_owner(:project_success, from_email: CatarseSettings[:email_projects])

    notify_admin_that_project_reached_deadline(project)
    notify_admin_that_project_is_successful(project)
    notify_users(project)
  end

  def from_in_analysis_to_approved(project)
    project.notify_owner(:project_approved, { from_email: CatarseSettings[:email_projects] })
  end

  def notify_admin_that_project_reached_deadline(project)
    project.notify_to_backoffice(:adm_project_deadline, { from_email: CatarseSettings[:email_system] })
  end

  def notify_admin_that_project_is_successful(project)
    redbooth_user = User.find_by(email: CatarseSettings[:email_redbooth])
    project.notify_once(:redbooth_task, redbooth_user) if redbooth_user
  end

  def from_in_analysis_to_rejected(project)
    project.update_attributes({ rejected_at: DateTime.now })
  end

  def from_in_analysis_to_draft(project)
    project.update_attributes({ sent_to_draft_at: DateTime.now })
  end

  def from_approved_to_online(project)
    deliver_default_notification_for(project, :project_visible)
    project.update_attributes({
      online_date: DateTime.now,
      audited_user_name: project.user.full_name,
      audited_user_cpf: project.user.cpf,
      audited_user_moip_login: project.user.moip_login,
      audited_user_phone_number: project.user.phone_number
    })
  end

  def from_online_to_failed(project)
    notify_users(project)

    project.contributions.with_state('waiting_confirmation').each do |contribution|
      contribution.notify_to_contributor(:pending_contribution_project_unsuccessful)
    end

    request_refund_for_failed_project(project)

    project.notify_owner(:project_unsuccessful, { from_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  def notify_users(project)
    project.contributions.with_state('confirmed').each do |contribution|
      unless contribution.notified_finish
        template_name = project.successful? ? :contribution_project_successful : contribution.notification_template_for_failed_project
        contribution.notify_to_contributor(template_name)

        if contribution.credits? && project.failed?
          contribution.notify_to_backoffice(:requested_refund_for_credits)
        end

        contribution.update_attributes({ notified_finish: true })
      end
    end
  end

  private

  def request_refund_for_failed_project(project)
    project.contributions.with_state('confirmed').each do |contribution|
      contribution.request_refund
    end
  end

  def deliver_default_notification_for(project, notification_type)
    project.notify_owner(
      notification_type,
      {
        from_email: CatarseSettings[:email_projects],
        from_name: CatarseSettings[:company_name]
      }
    )
  end
end
