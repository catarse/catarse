class RemoveDaysToDeliveryFromRewards < ActiveRecord::Migration
  def change
    remove_column :rewards, :days_to_delivery, :integer
  end
end
