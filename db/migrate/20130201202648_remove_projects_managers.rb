class RemoveProjectsManagers < ActiveRecord::Migration[4.2]
  def up
    drop_table :projects_managers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
