class AddShippingToContribution < ActiveRecord::Migration[4.2]
  def change
    add_reference :contributions, :shipping_fee, index: true, foreign_key: true
  end
end
