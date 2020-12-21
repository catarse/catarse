class RemoveDaysToDeliveryFromRewards < ActiveRecord::Migration[4.2]
  def change
    remove_column :rewards, :days_to_delivery, :integer
  end
end
