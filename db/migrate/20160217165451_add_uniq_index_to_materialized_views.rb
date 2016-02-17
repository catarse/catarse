class AddUniqIndexToMaterializedViews < ActiveRecord::Migration
  def up
    execute <<-SQL
set statement_timeout to 0;
CREATE UNIQUE INDEX statistics_uidx ON "1".statistics (total_projects);
CREATE UNIQUE INDEX user_totals_uidx ON "1".user_totals (id);
CREATE UNIQUE INDEX category_totals_uidx ON "1".category_totals (category_id);
    SQL
  end

  def down
    execute <<-SQL
set statement_timeout to 0;
DROP INDEX statistics_uidx;
DROP INDEX user_totals_uidx;
DROP INDEX category_totals_uidx;
    SQL
  end
end
