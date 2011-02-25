class AddAnonymousToBackers < ActiveRecord::Migration
  def self.up
    add_column :backers, :anonymous, :boolean, :default => false
  end

  def self.down
    remove_column :backers, :anonymous
  end
end
