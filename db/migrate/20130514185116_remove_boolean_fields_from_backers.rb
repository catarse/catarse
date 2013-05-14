class RemoveBooleanFieldsFromBackers < ActiveRecord::Migration
  def up
    remove_column :backers, :confirmed
    remove_column :backers, :requested_refund
    remove_column :backers, :refunded
  end

  def down
    add_column :backers, :confirmed, :boolean, default: false
    add_column :backers, :requested_refund, :boolean, default: false
    add_column :backers, :refunded, :boolean, default: false
  end
end
