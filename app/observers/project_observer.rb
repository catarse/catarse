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
    notify_admin_project_will_succeed(project) if project.reached_goal?
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

  def from_approved_to_online(project)
    deliver_default_notification_for(project, :project_visible)
    project.update_attributes({
      online_date: DateTime.now,
      audited_user_name: project.user.name,
      audited_user_cpf: project.user.cpf,
      audited_user_moip_login: project.user.moip_login,
      audited_user_phone_number: project.user.phone_number
    })
  end

  def from_online_to_failed(project)
    notify_users(project)

    project.payments.with_state('pending').each do |payment|
      payment.contribution.notify_to_contributor(:pending_contribution_project_unsuccessful)
    end

    request_refund_for_failed_project(project)

    project.notify_owner(:project_unsuccessful, { from_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  private
  def redbooth_user
    User.find_by(email: CatarseSettings[:email_redbooth])
  end

  def notify_redbooth(project, template)
    project.notify_once(template, redbooth_user) if redbooth_user
  end

  def notify_admin_that_project_is_successful(project)
    notify_redbooth project, :redbooth_task
  end

  def notify_admin_project_will_succeed(project)
    notify_redbooth project, :redbooth_task_project_will_succeed
  end

  def notify_admin_that_project_reached_deadline(project)
    project.notify_to_backoffice(:adm_project_deadline, { from_email: CatarseSettings[:email_system] })
  end

  def notify_users(project)
    project.payments.with_state('paid').each do |payment|
      template_name = project.successful? ? :contribution_project_successful : payment.notification_template_for_failed_project
      payment.contribution.notify_to_contributor(template_name)
    end
  end

  def request_refund_for_failed_project(project)
    project.payments.with_state('paid').each do |payment|
      payment.request_refund
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
