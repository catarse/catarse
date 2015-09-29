class FixesStatisticsToConcurrencyRefresh < ActiveRecord::Migration
  def up
    execute <<-SQL
      create unique index statistics_total_users_idx on "1".statistics (total_users);
    SQL
  end

  def down
    execute <<-SQL
      drop index statistics_total_users_idx;
    SQL
  end
end
