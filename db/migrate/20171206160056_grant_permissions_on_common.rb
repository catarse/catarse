class GrantPermissionsOnCommon < ActiveRecord::Migration
  def change
    execute <<-SQL
      grant USAGE on schema common_schema to admin, anonymous, web_user;
    SQL
  end
end
