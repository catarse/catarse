class AddPermalinkIntoProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :permalink, :string
    add_index :projects, :permalink, :unique => true
  end

  def self.down
    remove_column :projects, :permalink
  end
end
