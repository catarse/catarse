class FixContributionDetailsPermissions < ActiveRecord::Migration
  def change
    execute <<-SQL
    grant select on contribution_details to admin, web_user, anonymous;
    SQL
  end
end
