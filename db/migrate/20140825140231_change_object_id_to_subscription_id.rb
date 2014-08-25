class ChangeObjectIdToSubscriptionId < ActiveRecord::Migration
  def change
    rename_column :credit_cards, :object_id, :subscription_id
  end
end
