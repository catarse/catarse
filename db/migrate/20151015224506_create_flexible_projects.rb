class CreateFlexibleProjects < ActiveRecord::Migration
  def up
    create_table :flexible_projects do |t|
      t.references :project, null: false
      t.text :state, null: false, default: 'draft'

      t.timestamps
    end

    add_index :flexible_projects, :project_id, unique: true
  end

  def down
    drop_table :flexible_projects
  end
end
