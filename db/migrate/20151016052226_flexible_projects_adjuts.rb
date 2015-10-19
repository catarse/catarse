class FlexibleProjectsAdjuts < ActiveRecord::Migration
  def up
    add_index :flexible_projects, :project_id, unique: true
  end

  def down
    remove_index :flexible_projects, :project_id
  end
end
