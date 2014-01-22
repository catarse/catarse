class MigrateNotificationsTemplateNameToContribution < ActiveRecord::Migration
  TEMPLATE_NAMES = [ [:backer_confirmed_after_project_was_closed, :contribution_confirmed_after_project_was_closed],
                     [:backer_project_successful, :contribution_project_successful],
                     [:backer_project_unsuccessful, :contribution_project_unsuccessful],
                     [:confirm_backer, :confirm_contribution],
                     [:pending_backer_project_unsuccessful, :pending_contribution_project_unsuccessful],
                     [:project_owner_backer_confirmed, :project_owner_contribution_confirmed],
                     [:backer_canceled_after_confirmed, :contribution_canceled_after_confirmed] ]
  def up
    case_conditions = TEMPLATE_NAMES.map do |names|
      "WHEN '#{names[0]}' THEN '#{names[1]}'"
    end.join(" ")
    old_values = "'#{TEMPLATE_NAMES.map(&:first).join("','")}'"
    execute "UPDATE notifications SET template_name = CASE template_name #{case_conditions} END WHERE template_name IN (#{old_values})"
  end

  def down
    case_conditions = TEMPLATE_NAMES.map do |names|
      "WHEN '#{names[1]}' THEN '#{names[0]}'"
    end.join(" ")
    new_values = "'#{TEMPLATE_NAMES.map(&:last).join("','")}'"
    execute "UPDATE notifications SET template_name = CASE template_name #{case_conditions} END WHERE template_name IN (#{new_values})"
  end
end
