class AddDaysToDeliveryIntoRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :days_to_delivery, :integer
  end
end
