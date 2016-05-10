class AddIndexToStatistics < ActiveRecord::Migration
  def change
    execute "create unique index statistics_total_users_idx on \"1\".statistics (total_users)";
  end
end
