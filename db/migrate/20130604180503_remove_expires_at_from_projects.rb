class RemoveExpiresAtFromProjects < ActiveRecord::Migration
  def up
    execute "
    ALTER TABLE projects DROP IF EXISTS expires_at;
    "
  end

  def down
    add_column :projects, :expires_at, :datetime
  end
end
