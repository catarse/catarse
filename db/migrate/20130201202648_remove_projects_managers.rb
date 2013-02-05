class RemoveProjectsManagers < ActiveRecord::Migration
  def up
    drop_table :projects_managers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
