class AddShippingToContribution < ActiveRecord::Migration
  def change
    add_reference :contributions, :shipping_fee, index: true, foreign_key: true
  end
end
