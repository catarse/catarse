class ChangeObjectIdToSubscriptionId < ActiveRecord::Migration[4.2]
  def change
    rename_column :credit_cards, :object_id, :subscription_id
  end
end
