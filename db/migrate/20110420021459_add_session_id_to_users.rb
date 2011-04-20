class AddSessionIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :session_id, :text
  end

  def self.down
    remove_column :users, :session_id
  end
end
