class AddHomePageToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :home_page, :boolean, :default => false
    execute("UPDATE projects SET home_page = false")
    execute("UPDATE projects SET home_page = true WHERE recommended")
  end

  def self.down
    remove_column :projects, :home_page
  end
end

