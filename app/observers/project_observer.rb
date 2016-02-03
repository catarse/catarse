class ProjectObserver < ActiveRecord::Observer
  observe :project

  def before_save(project)
    if project.try(:online_days_changed?) || project.try(:expires_at).nil?
      project.update_expires_at
    end

    unless project.permalink.present?
      project.permalink = "#{project.name.parameterize.gsub(/\-/, '_')}_#{SecureRandom.hex(2)}"
    end
  end

  def after_save(project)
    if project.try(:video_url_changed?)
      ProjectDownloaderWorker.perform_async(project.id)
    end
  end

  def from_draft_to_in_analysis(project)
    project.notify_to_backoffice(:new_draft_project, {
      from_email: project.user.email,
      from_name: project.user.display_name
    }, project.new_draft_recipient)

  end

  def from_online_to_waiting_funds(project)
    notify_admin_project_will_succeed(project) if project.reached_goal?
  end

  def from_waiting_funds_to_successful(project)
    notify_admin_that_project_is_successful(project)
    notify_users(project)
  end

  def from_approved_to_online(project)
    project.update_attributes({
      audited_user_name: project.user.name,
      audited_user_cpf: project.user.cpf,
      audited_user_phone_number: project.user.phone_number
    })
  end
  # Flexible pojects can go direct to online from draft
  alias :from_draft_to_online :from_approved_to_online

  def from_online_to_failed(project)
    notify_users(project)
    request_refund_for_failed_project(project)
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
  end

  private
  def notify_admin_that_project_is_successful(project)
    redbooth_user = User.find_by(email: CatarseSettings[:email_redbooth])
    project.notify_once(:redbooth_task, redbooth_user) if redbooth_user
  end

  def notify_admin_project_will_succeed(project)
    zendesk_user = User.find_by(email: CatarseSettings[:email_contact])
    project.notify_once(:project_will_succeed, zendesk_user) if zendesk_user
  end

  def notify_users(project)
    project.payments.with_state('paid').each do |payment|
      template_name = project.successful? ? :contribution_project_successful : payment.notification_template_for_failed_project
      payment.contribution.notify_to_contributor(template_name)
    end
  end

  def request_refund_for_failed_project(project)
    project.payments.with_state('paid').each do |payment|
      payment.direct_refund
    end
  end

end
