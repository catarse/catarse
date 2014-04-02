class RemoveProjectsByPeriod < ActiveRecord::Migration
  def change
    execute "
    DROP VIEW projects_by_periods;
    "
  end
end
