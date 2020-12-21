class AddShippingOptionsToRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :shipping_options, :text
  end
end
