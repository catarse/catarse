class AddNotifiedFinishToBackers < ActiveRecord::Migration
  def self.up
    add_column :backers, :notified_finish, :boolean, :default => false
    execute("UPDATE backers SET notified_finish = false")
    execute("UPDATE backers SET notified_finish = true WHERE project_id IN (SELECT id FROM projects WHERE finished)")
  end

  def self.down
    remove_column :backers, :notified_finish
  end
end
