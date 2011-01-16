class AddOrderToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :order, :integer
  end

  def self.down
    remove_column :projects, :order
  end
end
