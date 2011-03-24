class AddCreditsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :credits, :decimal, :default => 0
    execute("UPDATE users SET credits = 0")
  end

  def self.down
    remove_column :users, :credits
  end
end
