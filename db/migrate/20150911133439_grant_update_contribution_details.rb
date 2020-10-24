class GrantUpdateContributionDetails < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
    GRANT update ON "1".contribution_details TO admin;
    SQL
  end

  def down
    execute <<-SQL
    REVOKE update ON "1".contribution_details FROM admin;
    SQL
  end
end
