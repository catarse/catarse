class FlexibleProjectObserver < ActiveRecord::Observer
  observe :flexible_project

  def from_online_to_waiting_funds(flexible_project)
    flexible_project.notify_owner(:project_in_waiting_funds, {
      from_email: CatarseSettings[:email_projects]
    })

    notify_admin_project_will_succeed(flexible_project)
  end

  def from_waiting_funds_to_successful(flexible_project)
    flexible_project.notify_owner(:project_success, {
      from_email: CatarseSettings[:email_projects]
    })

    notify_admin_that_project_is_successful(flexible_project)
    notify_users(flexible_project)
  end
  alias :from_online_to_successful :from_waiting_funds_to_successful

  def from_draft_to_online(flexible_project)
    project = flexible_project.project

    deliver_default_notification_for(flexible_project, :project_visible)

    project.update_attributes({
      audited_user_name: project.user.name,
      audited_user_cpf: project.user.cpf,
      audited_user_phone_number: project.user.phone_number
    })
  end

  private
  def notify_admin_that_project_is_successful(flexible_project)
    redbooth_user = User.find_by(email: CatarseSettings[:email_redbooth])
    flexible_project.notify_once(:redbooth_task, redbooth_user) if redbooth_user
  end

  def notify_admin_project_will_succeed(flexible_project)
    zendesk_user = User.find_by(email: CatarseSettings[:email_contact])
    flexible_project.notify_once(:project_will_succeed, zendesk_user) if zendesk_user
  end

  def notify_users(flexible_project)
    flexible_project.payments.with_state('paid').each do |payment|
      payment.contribution.
        notify_to_contributor(:contribution_project_successful)
    end
  end

  def deliver_default_notification_for(flexible_project, notification_type)
    flexible_project.notify_owner(
      notification_type,
      {
        from_email: CatarseSettings[:email_projects],
        from_name: CatarseSettings[:company_name]
      }
    )
  end
end
