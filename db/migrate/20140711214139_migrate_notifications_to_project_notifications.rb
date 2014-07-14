class MigrateNotificationsToProjectNotifications < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO project_notifications
    (user_id, project_id, from_email, from_name, template_name, locale, sent_at, created_at, updated_at)
    SELECT
      user_id, project_id, origin_email, origin_name, template_name, locale, updated_at, created_at, updated_at
    FROM
      notifications
    WHERE
      template_name IN (
      'verify_moip_account',
      'project_received',
      'project_received_channel',
      'new_draft_project',
      'in_analysis_project',
      'in_analysis_project_channel',
      'project_in_waiting_funds',
      'project_success',
      'adm_project_deadline',
      'redbooth_task',
      'project_rejected',
      'project_rejected_channel',
      'project_visible',
      'project_visible_channel',
      'project_unsuccessful',
      'project_success',
      'inactive_draft'
      ) AND project_id IS NOT NULL;
    "
  end
end
