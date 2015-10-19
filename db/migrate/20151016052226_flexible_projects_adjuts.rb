class FlexibleProjectsAdjuts < ActiveRecord::Migration
  def up
    change_column_null :projects, :category_id, true
    add_index :flexible_projects, :project_id, unique: true
  end

  def down
    change_column_null :projects, :category_id, false
    remove_index :flexible_projects, :project_id
  end
end
