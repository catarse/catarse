class AlterProjectsToUseProjectsSites < ActiveRecord::Migration
  def self.up
    execute 'INSERT INTO projects_sites (project_id, site_id, visible, rejected, recommended, home_page, "order") SELECT id, 1, visible, rejected, recommended, home_page, "order" FROM projects'
    remove_column :projects, :visible
    remove_column :projects, :rejected
    remove_column :projects, :recommended
    remove_column :projects, :home_page
    remove_column :projects, :order
  end

  def self.down
    add_column :projects, :visible, :boolean, :default => false
    add_column :projects, :rejected, :boolean, :default => false
    add_column :projects, :recommended, :boolean, :default => false
    add_column :projects, :home_page, :boolean, :default => false
    add_column :projects, :order, :integer
    execute "UPDATE projects SET visible = (SELECT visible FROM projects_sites WHERE site_id = 1 AND project_id = projects.id)"
    execute "UPDATE projects SET rejected = (SELECT rejected FROM projects_sites WHERE site_id = 1 AND project_id = projects.id)"
    execute "UPDATE projects SET recommended = (SELECT recommended FROM projects_sites WHERE site_id = 1 AND project_id = projects.id)"
    execute "UPDATE projects SET home_page = (SELECT home_page FROM projects_sites WHERE site_id = 1 AND project_id = projects.id)"
    execute 'UPDATE projects SET "order" = (SELECT "order" FROM projects_sites WHERE site_id = 1 AND project_id = projects.id)'
    execute "DELETE FROM projects_sites"
  end
end
