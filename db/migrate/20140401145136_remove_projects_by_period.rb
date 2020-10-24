class RemoveProjectsByPeriod < ActiveRecord::Migration[4.2]
  def change
    execute "
    DROP VIEW projects_by_periods;
    "
  end
end
