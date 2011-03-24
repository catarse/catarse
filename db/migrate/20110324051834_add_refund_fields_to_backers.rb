class AddRefundFieldsToBackers < ActiveRecord::Migration
  def self.up
    add_column :backers, :can_refund, :boolean, :default => false
    add_column :backers, :requested_refund, :boolean, :default => false
    add_column :backers, :refunded, :boolean, :default => false
    execute("UPDATE backers SET can_refund = false, requested_refund = false, refunded = false")
  end

  def self.down
    remove_column :backers, :can_refund
    remove_column :backers, :requested_refund
    remove_column :backers, :refunded
  end
end
