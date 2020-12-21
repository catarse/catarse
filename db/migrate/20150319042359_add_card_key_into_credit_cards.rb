class AddCardKeyIntoCreditCards < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_cards, :card_key, :text
    change_column_null :credit_cards, :subscription_id, true
  end
end
