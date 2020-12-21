class AddUniqIndexToStatisticsView < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      set statement_timeout to 0;
      CREATE UNIQUE INDEX statistics_uidx ON "1".statistics (total_projects);
    SQL
  end

  def down
    execute <<-SQL
      set statement_timeout to 0;
      DROP INDEX statistics_uidx;
    SQL
  end
end
