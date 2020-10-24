class GrantPermissionsOnCommon < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      grant USAGE on schema common_schema to admin, anonymous, web_user;
    SQL
  end
end
