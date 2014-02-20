class ContributionObserver < ActiveRecord::Observer
  observe :contribution

  def after_create(contribution)
    contribution.define_key
    PendingContributionWorker.perform_at(1.hour.from_now, contribution.id)
  end

  def before_save(contribution)
    notify_confirmation(contribution) if contribution.confirmed? && contribution.confirmed_at.nil?
    notify_payment_slip(contribution) if contribution.payment_choice_was.nil? && contribution.payment_choice == 'BoletoBancario'
  end

  def after_save(contribution)
    if contribution.project.reached_goal?
      Notification.notify_once(
        :project_success,
        contribution.project.user,
        {project_id: contribution.project.id},
        project: contribution.project
      )
    end
  end

  def from_requested_refund_to_refunded(contribution)
    contribution.notify_to_contributor((contribution.slip_payment? ? :refund_completed_slip : :refund_completed))
  end
  alias :from_confirmed_to_refunded :from_requested_refund_to_refunded

  def from_confirmed_to_requested_refund(contribution)
    user = User.find_by(email: Configuration[:email_payments])
    if user.present?
      Notification.notify(:refund_request, user, {contribution: contribution, origin_email: contribution.user.email, origin_name: contribution.user.name})
    end

    contribution.notify_to_contributor((contribution.slip_payment? ? :requested_refund_slip : :requested_refund))
  end

  def from_confirmed_to_canceled(contribution)
    user = User.where(email: Configuration[:email_payments]).first
    if user.present?
      Notification.notify_once(
        :contribution_canceled_after_confirmed,
        user,
        {contribution_id: contribution.id},
        contribution: contribution
      )
    end

    contribution.notify_to_contributor((contribution.slip_payment? ? :contribution_canceled_slip : :contribution_canceled))
  end

  private
  def notify_confirmation(contribution)
    contribution.confirmed_at = Time.now
    Notification.notify_once(
      :confirm_contribution,
      contribution.user,
      {contribution_id: contribution.id},
      contribution: contribution,
      project: contribution.project
    )

    if (Time.now > contribution.project.expires_at  + 7.days) && (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.notify_once(
        :contribution_confirmed_after_project_was_closed,
        user,
        {contribution_id: contribution.id},
        contribution: contribution,
        project: contribution.project
      )
    end
  end

  def notify_payment_slip(contribution)
    Notification.notify_once(
      :payment_slip,
      contribution.user,
      {contribution_id: contribution.id},
      contribution: contribution,
      project: contribution.project
    )
  end
end
