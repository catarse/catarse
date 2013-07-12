class AddDaysToDeliveryIntoRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :days_to_delivery, :integer
  end
end
