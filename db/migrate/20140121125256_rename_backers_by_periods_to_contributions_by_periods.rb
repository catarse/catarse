class RenameBackersByPeriodsToContributionsByPeriods < ActiveRecord::Migration
  def up
    execute "ALTER VIEW backers_by_periods RENAME TO contributions_by_periods"
  end

  def down
    execute "ALTER VIEW contributions_by_periods RENAME TO backers_by_periods"
  end
end
