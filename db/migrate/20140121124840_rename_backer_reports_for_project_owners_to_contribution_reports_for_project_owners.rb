class RenameBackerReportsForProjectOwnersToContributionReportsForProjectOwners < ActiveRecord::Migration
  def up
    execute "ALTER VIEW backer_reports_for_project_owners RENAME TO contribution_reports_for_project_owners"
  end

  def down
    execute "ALTER VIEW contribution_reports_for_project_owners RENAME TO backer_reports_for_project_owners"
  end
end
