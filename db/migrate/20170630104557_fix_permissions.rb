class FixPermissions < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
grant SELECT on contribution_notifications to web_user, admin;
    SQL

  end
end
