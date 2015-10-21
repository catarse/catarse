class DropFlexibleTableAndAddProjectType < ActiveRecord::Migration
  def up
    drop_table :flexible_projects
    add_column :projects, :project_type, :text, null: false, default: 'all_or_nothing'
    add_index :projects, :project_type
  end

  def down
    remove_column :projects, :project_type
    remove_index :projects, :project_type
    create_table :flexible_projects do |t|
      t.references :project

      t.timestamps
    end
  end
end
