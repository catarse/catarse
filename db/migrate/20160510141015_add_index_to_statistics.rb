class AddIndexToStatistics < ActiveRecord::Migration[4.2]
  def change
    execute "create unique index statistics_total_users_idx on \"1\".statistics (total_users)";
  end
end
