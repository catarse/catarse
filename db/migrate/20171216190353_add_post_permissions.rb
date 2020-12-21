class AddPostPermissions < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    grant select on rewards to admin, web_user, anonymous;
    grant select on common_schema.subscriptions to admin, web_user, anonymous;
    SQL
  end
end
