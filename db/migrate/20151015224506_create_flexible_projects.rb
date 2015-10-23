class CreateFlexibleProjects < ActiveRecord::Migration
  def up
    create_table :flexible_projects do |t|
      t.references :project
      t.text :state

      t.timestamps
    end

    add_index :flexible_projects, :project_id, unique: true
  end

  def down
    drop_table :flexible_projects
    remove_index :flexible_projects, :project_id
  end
end
