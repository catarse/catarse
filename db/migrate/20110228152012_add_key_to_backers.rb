class AddKeyToBackers < ActiveRecord::Migration
  def self.up
    add_column :backers, :key, :text
    execute("UPDATE backers SET key = id")
  end

  def self.down
    remove_column :backers, :key
  end
end
