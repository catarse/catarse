class AddCreditsToBacker < ActiveRecord::Migration
  def self.up
    add_column :backers, :credits, :boolean, :default => false
    execute("UPDATE backers SET credits = false")
  end

  def self.down
    remove_column :backers, :credits
  end
end
