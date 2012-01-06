class AddSuccessfulToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :successful, :boolean, :default => false
    execute 'UPDATE projects SET successful = false'
    execute 'UPDATE projects SET successful = (goal <= (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed)) WHERE finished = true'
  end

  def self.down
    remove_column :projects, :successful
  end
end
