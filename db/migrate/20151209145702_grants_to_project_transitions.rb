class GrantsToProjectTransitions < ActiveRecord::Migration
  def up
    execute <<-SQL
GRANT select ON "1".project_transitions TO admin, web_user, anonymous;
    SQL
  end

  def down
    execute <<-SQL
REVOKE select ON "1".project_transitions FROM admin, web_user, anonymous;
    SQL
  end
end
