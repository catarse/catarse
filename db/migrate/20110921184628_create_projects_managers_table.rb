class CreateProjectsManagersTable < ActiveRecord::Migration
  def self.up
    create_table :projects_managers, :id => false do |t|
      t.integer :user_id
      t.integer :project_id
    end
  end

  def self.down
    drop_table :projects_managers
  end
end
