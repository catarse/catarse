class MigrateNotificationsToContributionNotifications < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO contribution_notifications
    (user_id, contribution_id, from_email, from_name, template_name, locale, sent_at, created_at, updated_at)
    SELECT
      user_id, contribution_id, origin_email, origin_name, template_name, locale, updated_at, created_at, updated_at
    FROM
      notifications
    WHERE
      template_name IN (
      'payment_slip',
      'refund_completed_slip',
      'refund_completed',
      'invalid_payment',
      'requested_refund_slip',
      'requested_refund',
      'contribution_canceled_slip',
      'contribution_canceled',
      'confirm_contribution',
      'contribution_confirmed_after_project_was_closed',
      'pending_payment',
      'pending_contribution_project_unsuccessful',
      'contribution_project_successful',
      'contribution_project_unsuccessful',
      'processing_payment',
      'slip_payment_canceled'
      ) AND contribution_id IS NOT NULL;
    "
  end
end
