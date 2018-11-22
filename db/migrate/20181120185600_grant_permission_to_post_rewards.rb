class GrantPermissionToPostRewards < ActiveRecord::Migration
  def change
    execute <<-SQL
      GRANT SELECT ON TABLE post_rewards TO admin, web_user, anonymous;
    SQL
  end
end
