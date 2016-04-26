class AddUniqueIndexToCategoryTotals < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute %Q{
CREATE UNIQUE INDEX CONCURRENTLY category_totals_idx ON "1".category_totals(category_id);
    }
  end

  def down
    execute %Q{
DROP INDEX category_totals_idx;
    }
  end
end
