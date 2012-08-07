class RenameBackerTotalsToProjectTotals < ActiveRecord::Migration
  def up
    execute "ALTER VIEW backer_totals RENAME TO project_totals"
  end

  def down
    execute "ALTER VIEW projects_totals RENAME TO backer_totals"
  end
end
