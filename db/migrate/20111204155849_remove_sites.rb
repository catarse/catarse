class RemoveSites < ActiveRecord::Migration
  def self.up
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
    drop_table :projects_sites
    remove_column :notifications, :site_id
    remove_column :projects, :site_id
    remove_column :backers, :site_id
    remove_column :users, :site_id
    remove_column :users, :session_id
    remove_column :curated_pages, :site_id
    drop_table :sites
  end

  def self.down
    # I wont write it because I think we wont need it, but if we really need this we can create a down by copying what we did when we created the sites structure
  end
end
