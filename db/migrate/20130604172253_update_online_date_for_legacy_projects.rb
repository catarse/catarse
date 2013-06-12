class UpdateOnlineDateForLegacyProjects < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE projects
        SET online_days = 60, online_date = (expires_at - interval '60 days')
        WHERE online_days = 0 AND online_date IS NULL;
    SQL
  end

end
