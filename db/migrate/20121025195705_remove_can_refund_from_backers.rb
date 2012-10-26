class RemoveCanRefundFromBackers < ActiveRecord::Migration
  def up
    remove_column :backers, :can_refund
  end

  def down
    add_column :backers, :can_refund, :boolean
  end
end
